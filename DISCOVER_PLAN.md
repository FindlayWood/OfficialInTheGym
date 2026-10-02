# DISCOVER tab — plan

The agreed design for rebuilding DISCOVER on Firestore as its own framework, **DiscoverKit**. Nothing
here is built yet. Work is split into steps, each listing what changes in this repository (**App**)
and in `InTheGym-CloudFunctions` (**Cloud**). The admin app is out of scope for now — moderation
writes to a queue it will read later.

**Account deletion is a separate feature** and not part of this plan. Discover's only obligation to
it is `deleteDiscoverData(uid)` (step 8), which that feature will call.

---

## Decisions

| Area | Decision |
|---|---|
| Framework | **DiscoverKit**, built like StatsKit / AccountCreationKit / LoginKit. Firestore only — nothing from the RTDB. |
| Model ownership | **DiscoverKit defines every model it needs and imports nothing from MyDayKit.** Behaviour another framework already owns is reached through a protocol DiscoverKit declares and the composition root implements. |
| Ratings | **1–10, no text.** Exercises and workouts only. One per user. You cannot rate your own workout. |
| Comments | Exercises, workouts and clips. One level of replies via `parentId`. **No editing.** Deleting your own comment is a soft delete. |
| Likes | On comments, and on clips. |
| Clips | **No ratings and no tags.** A clip belongs to one exercise — it is a user doing that exercise — and is found through it. Comments and likes only. |
| Exercise tags | Anyone can vote a tag onto an exercise. Ranked by voter count. Visible from **3 voters**. |
| Workout tags | **Hybrid.** The author's tags are always visible and count as the author's vote. Other users may vote tags onto *public* workouts; a community tag is visible from **3 voters**. Ranked by voter count within a tag. |
| Tag directory | **One tree, `Tags/{tag}`**, shared by exercises and workouts. Replaces `TaggedWorkoutTemplates`. |
| Comment authors | Store `authorId` only. Profiles resolved at display time — batched and cached. |
| Legacy RTDB data | **Not migrated.** Discover starts empty. |
| Moderation | `status` on every comment and card, reports that auto-hide at **3 reports or 1 admin report**, blocking, a tag word blocklist, an `admin` custom claim. Review UI deferred to the admin app. |
| Account deletion | Everything the user created goes. A comment with replies becomes an anonymous placeholder; everything else is hard-deleted. |

---

## Data model

```
Exercises/{exerciseId}                              seed / admin (exists)
  Ratings/{uid}                                     rating, authorId, createdAt, updatedAt
  Comments/{commentId}                              authorId, text, parentId|null, status,
                                                    likeCount, replyCount, createdAt
    Likes/{uid}                                     authorId, createdAt
  TagVotes/{uid}                                    authorId, tags: [String], updatedAt

WorkoutTemplates/{templateId}                       author (exists) — author's tags stay here
  Ratings/{uid}
  Comments/{commentId}
    Likes/{uid}
  TagVotes/{uid}                                    community votes only — never the author's

Clips/{clipId}                                      author (replaces TestClips)
  Comments/{commentId}
    Likes/{uid}
  Likes/{uid}

DiscoverExercises/{exerciseId}                      SERVER — card
DiscoverWorkouts/{templateId}                       SERVER — card
DiscoverClips/{clipId}                              SERVER — card

Tags/{tag}                                          SERVER — tag, exerciseCount, workoutCount,
                                                    totalCount, lastUsedAt, status
  Exercises/{exerciseId}                            SERVER — card + voteCount
  WorkoutTemplates/{templateId}                     SERVER — card + voteCount

Reports/{reporterId_targetHash}                     client — reporterId, targetPath, reason, createdAt
ModerationQueue/{targetHash}                        SERVER — targetPath, reportCount, status, updatedAt
Users/{uid}/BlockedUsers/{blockedUid}               client — createdAt
```

### Cards

| Card | Projection | Aggregates |
|---|---|---|
| `DiscoverExercises` | name, category | ratingCount, ratingSum, score, commentCount, tagCounts `{tag: n}`, visibleTags |
| `DiscoverWorkouts` | title, createdBy, exerciseCount, createdAt, isPublic, status | ratingCount, ratingSum, score, commentCount, tagCounts, visibleTags |
| `DiscoverClips` | exerciseId, exerciseName, thumbnailURL, videoURL, duration, createdBy, uploadedAt, isPublic, status | likeCount, commentCount, viewCount, fullViewCount |

### Who writes what

- **Clients write only their own**: `Ratings/{uid}`, `Likes/{uid}`, `TagVotes/{uid}`, their comments,
  their reports, their blocks — and, as today, the subjects they author.
- **Functions write everything else**: every card, every count, every `Tags` document,
  `ModerationQueue`, and every `status` change other than an author removing their own comment.
- **Counts never live on the subject document.** `FirestoreTopLevelWorkoutTemplateUploader` writes
  with `setData(from:)` and no merge, as do the clip uploader and the seed script's REST `PATCH`, so
  a count stored on the subject is wiped the next time its owner saves it. Cards are the one place
  aggregates live.
- **Cards are merged, never replaced.** Several triggers write one card — the subject trigger writes
  projection fields, the engagement triggers increment counts — so every card write is
  `set(…, {merge: true})` touching only the fields that trigger owns.

### Rules of the model

- **A rating's document id is the rater's uid**, so one rating per user is structural and re-rating
  is an idempotent overwrite. `authorId` is stored as a field as well, because a collection-group
  query cannot filter on document id.
- **Store `ratingSum` and `ratingCount`, never an average.** The average is derived on the client in
  one place. `score` is a server-computed Bayesian average used only for ordering:
  `(C·m + sum) / (C + count)`, starting at **m = 5.5, C = 5**, so one 10 cannot outrank fifty 9s.
- **`parentId` is written as an explicit `null`** on top-level comments. Firestore cannot query for
  a missing field.
- **Tag counts on `Tags/{tag}` count subjects on which the tag is visible**, never raw votes, so a
  tag used once never reaches the directory. **Private workouts never count** — a private template's
  tag (`johnsrehab`) would otherwise surface in the public directory while its workout does not.
- **`Tags/{tag}` documents are never deleted**, for the reason `ApplyTagIndexPlan` already gives:
  deleting on last removal races another subject adding the tag.
- **Private cards are kept with `isPublic: false`**, not deleted, so their counts survive a template
  going public again. Queries filter on `isPublic` and `status`.

---

## Rollout checklist

The manual steps that take built work live — nothing here is done by committing. **In order**;
tick each one as it is done. Rules and indexes are entered in the Firebase console (they are not
deployed from either repository); the exact text is under each step below.

**Step 1 — Groundwork**
- [ ] Console rules: allow clients to create and read `Clips/{clipId}` (the app no longer writes
      `TestClips`; uploads are denied until this exists)
- [ ] `python MigrateTestClips.py` — dry run, check the list
- [ ] `python MigrateTestClips.py --write` — copy `TestClips` into `Clips`
- [ ] `python SetAdminClaim.py findlaywood1@gmail.com` — grant the `admin` claim
- [ ] Deploy functions from the `discover` branch — shared tag validation starts dropping blocked
      tags from the workout tag index
- [ ] Once the copy is checked, delete `TestClips` by hand

**Step 2 — Cards**
- [ ] Console rules: `DiscoverExercises`, `DiscoverWorkouts`, `DiscoverClips` (read-only) and the
      full `Clips` rule
- [ ] Console indexes: the three composite indexes for the card queries
- [ ] Deploy functions — `discoverExerciseCard`, `discoverWorkoutCard`, `discoverClipCard`,
      `rebuildDiscoverCards`, and `recordClipWatch` writing counts to the card
- [ ] `python RebuildDiscoverCards.py findlaywood1@gmail.com all` — backfill every card
- [ ] Spot-check a few documents in each `Discover*` collection

**Step 3 — Ratings**
- [ ] Console rules: `Exercises/{id}/Ratings/{userId}` and `WorkoutTemplates/{id}/Ratings/{userId}`
- [ ] Deploy functions — `discoverExerciseRatings`, `discoverWorkoutRatings`
- [ ] Rate an exercise and a public workout in the app; check `ratingCount` / `ratingSum` / `score`
      land on their cards, and that rating again changes the sum without changing the count

**Step 4 — Comments and likes**
- [ ] Console rules: comments and comment likes under `Exercises`, `WorkoutTemplates` and `Clips`,
      and `Clips/{id}/Likes`
- [ ] Console indexes: the two `Comments` composite indexes
- [ ] Deploy functions — the three `…Comments`, the three `…CommentLikes`, and `discoverClipLikes`
- [ ] Post, reply, like and delete a comment in the app; check `commentCount`, `replyCount` and
      `likeCount` settle, and that a deleted comment with replies reads "Comment removed"
- [ ] Play a clip, like it, leave; check `likeCount` and `viewCount` on its card
- [ ] **Do not release comments to users until step 6 (report and block) is rolled out**

**Step 5 — Tags**
- [ ] Console rules: `TagVotes` under `Exercises` and `WorkoutTemplates`, and read-only `Tags`
- [ ] Console indexes: the two `Tags` composite indexes and the two collection-group `subjectId`
      exemptions — **tag syncs fail without the exemptions**
- [ ] Deploy functions — the four tag triggers, the updated `rebuildDiscoverCards`; **confirm the
      deletion of `onWorkoutTemplateWritten`** when the deploy asks
- [ ] `python SeedExerciseTags.py` — dry run, check the derived tags read sensibly
- [ ] `python SeedExerciseTags.py --write`
- [ ] `python RebuildDiscoverCards.py findlaywood1@gmail.com workout-tags` — index every template's
      existing author tags (and `exercise-tags` too, if seeding ran before the deploy)
- [ ] Check `Tags` in the console, and the home screen's Tags section
- [ ] Vote a tag on an exercise: it shows to you outlined, not to others, until three people agree
- [ ] Delete the old `TaggedWorkoutTemplates` collection by hand

**Step 6 — Moderation**
- [ ] Console rules: `Reports`, `ModerationQueue`, `Users/{uid}/BlockedUsers`, and the admin
      status-change additions
- [ ] Deploy functions — `discoverReportFiled`, and the updated tag sync (hidden cards and tags)
- [ ] With three test accounts, report one comment: hidden after the third, `ModerationQueue` entry
      `hidden`, the card's `commentCount` drops
- [ ] Report with the admin account: hidden at once, `adminReported: true`
- [ ] Report a tag as admin: gone from the directory and from every subject's tag chips
- [ ] Block a user: their comments and clips disappear; unblock from Blocked Users brings them back
- [ ] **Once this is rolled out, comments (step 4) may reach real users**

**Step 7 — Workout and exercise pages**
- [ ] Console index: `DiscoverClips` on `exerciseId`, `isPublic`, `status`, `uploadedAt` ↓
- [ ] Open a public workout: exercises and author show; Save to Library → it appears in MyDay's
      library at once, private, and the page reads "Saved" on the next visit
- [ ] Edit the original as its author; the saved copy does not change
- [ ] Open an exercise with public clips: the strip shows them, newest first

**Step 8 — `deleteDiscoverData`**
- [ ] Console indexes: collection-group `authorId` exemptions on `Ratings`, `Comments`, `Likes`,
      `TagVotes` — **without them the deletion's queries fail**
- [ ] Nothing to deploy on its own — it ships with, and is called by, the account-deletion feature

**Step 9 — Tab wiring**
- [ ] Steps 1–7's rules, indexes and deploys are all live before this build ships — DISCOVER now
      reads nothing from the Realtime Database, so an unrolled step is a broken screen
- [ ] Emulator: `npm run build` in the functions, then `python Emulator/SeedDiscover.py`, then the
      InTheGym-EM scheme signed in as `demo@inthegym.test` — every DISCOVER screen has data
- [ ] Coach account: DISCOVER works and workout pages show no Save to Library

## Steps

### Step 1 — Groundwork — built, not rolled out

**Rules and indexes are not deployed from either repository.** `firestore.rules` in
`InTheGym-CloudFunctions` is not what is live, and its `firebase.json` has no `firestore` section,
so `firestore.indexes.json` is not deployed either. Both are managed in the Firebase console. So
**each later step carries the rules and indexes for the paths it introduces**, written out for the
console, rather than step 1 writing them all ahead of the queries that need them. The rules each
step must express:
- owner-only writes on `Ratings/{uid}`, `Likes/{uid}`, `TagVotes/{uid}`, `BlockedUsers`;
- no rating your own workout; tag votes only on a public workout, never your own;
- `rating` an integer 1–10; `TagVotes.tags` bounded in length;
- comments created only with `status == "visible"` and `authorId == request.auth.uid`; the only
  change an author may make is `visible → removed` with `text` cleared;
- cards, counts, `Tags`, `ModerationQueue` and all other `status` changes server-only;
- `request.auth.token.admin == true` identifies an admin.

Indexes: card queries (`isPublic + status + score`, `isPublic + status + createdAt`), comment lists
(`status + parentId + createdAt`), and collection-group `authorId` on `Ratings`, `Comments`, `Likes`,
`TagVotes` (step 8).

Done:
- **Cloud** — `src/Tags/TagRejection.ts` is the one server-side definition of a valid tag
  (`^[a-z0-9]+$`, at most `MAX_TAG_LENGTH` = 32, not blocked), with `src/Tags/TagBlocklist.ts`
  holding a fragment list and a whole-tag list. `indexedTags` now goes through it; the tag-vote
  pipeline will too. Unit tests in `test/Tags/`.
- **App** — clip documents are written to and read from `Clips` (`FirestoreMetadataDecorator`,
  `FirestoreClipLoader`); Storage paths unchanged. `Clip.thumbnailURL` is optional.
  `WorkoutTag.normalized` caps at `WorkoutTag.maxLength` = 32, **in step with `MAX_TAG_LENGTH`**.
- **Scripts** — `SetAdminClaim.py` grants / revokes the `admin` claim; `MigrateTestClips.py` copies
  `TestClips` into `Clips` with a merge (dry run by default).

### Step 2 — Cards and the DiscoverKit skeleton — built, not rolled out

**Cloud** (`src/Discover/`)
- `syncCard` is the one way a card's projection is written. It **projects the subject's current
  state, read in a transaction** — not the event's snapshot — so late or repeated events converge on
  the same card; merges projection fields only; and supplies `status: "visible"` only when a card
  has no status, never overwriting moderation's.
- `discoverExerciseCard`, `discoverWorkoutCard`, `discoverClipCard` — one trigger per card, separate
  from `onWorkoutTemplateWritten` (one trigger per aggregate, as the RawLogs fan-out does).
  The clip card resolves `exerciseName` from `Exercises/{exerciseID}` and parses `durationSeconds`
  out of the string in `videoMetaData`.
- **Deletes cascade for templates and clips, not exercises.** A deleted template or clip takes its
  subcollections (ratings, comments, likes, votes, `ViewSessions`) with it. A deleted exercise only
  loses its card: exercises are a catalogue edited by scripts, and a delete-and-recreate must not
  wipe everything people said about one.
- `recordClipWatch` writes its clip-level counts to `DiscoverClips/{clipID}`; `ViewSessions` stay
  under the clip. Counts already on `Clips` documents are not carried over.
- `rebuildDiscoverCards` — admin-only callable that runs `syncCard` over the union of subject and
  card ids for one kind. Backfills everything that predates the triggers. Never cascades a delete.
- Tests in `test/Discover/`; `recordClipWatch`'s tests now read the card.

**App**
- `DiscoverKit.xcodeproj` — generated from LoginKit's (ids prefixed `D1C`), synchronised root groups,
  `MEMBER_IMPORT_VISIBILITY`, shared scheme, in the workspace; linked and embedded by the app.
- Framework: card models (every count optional — a new card has none), three card loader protocols
  paging by **the last card as cursor** (no Firestore type crosses the boundary), preview loaders,
  `DiscoverPager` (one pager for every "see all"), `DiscoverHomeScreen` (clips / workouts /
  exercises, each loading and failing on its own), `DiscoverCardListScreen`, `DiscoverClipGridScreen`,
  `DiscoverKitRouter`. STATS' frame: white title bar, `darkColor` page, `SectionContainer` cards.
- Composition root (`Launch/Composition/DiscoverKit/`): `DiscoverKitComposition`, one Firestore loader
  per card, `DiscoverCardQuery` (per-document decode, document-id tiebreak on every ordering).
- `DiscoverKitTests`: pager and card display. **Not yet in `CI_iOS_TestPlan.xctestplan`** (step 10).
- Taps lead nowhere yet — detail routes arrive with steps 3, 4 and 7. The Tags section arrives with
  step 5. **Not yet on the tab bar** — that is step 9.
- `DiscoverSubject` moved to step 3, where it is first needed, and **its Firestore paths live in the
  composition root**, not the framework — the framework holds no infrastructure.

**Scripts** — `RebuildDiscoverCards.py <admin> exercises|workouts|clips|all` mints a custom token for
an admin, exchanges it for an ID token and calls `rebuildDiscoverCards`.

**Console — rules**
```
match /DiscoverExercises/{exerciseId} {
  allow read: if request.auth != null;
  allow write: if false;
}
match /DiscoverWorkouts/{templateId} {
  allow read: if request.auth != null
    && (resource.data.isPublic == true || resource.data.createdBy == request.auth.uid);
  allow write: if false;
}
match /DiscoverClips/{clipId} {
  allow read: if request.auth != null
    && (resource.data.isPublic == true || resource.data.createdBy == request.auth.uid);
  allow write: if false;
}
match /Clips/{clipId} {
  allow read: if request.auth != null
    && (resource.data.isPrivate == false || resource.data.userID == request.auth.uid);
  allow create: if request.auth != null && request.resource.data.userID == request.auth.uid;
  allow update, delete: if request.auth != null && resource.data.userID == request.auth.uid;
}
```
Queries on another user's cards must filter `isPublic == true`, or the rules reject them outright.

**Console — composite indexes** (collection scope)

| Collection | Fields |
|---|---|
| `DiscoverWorkouts` | `isPublic` ↑, `status` ↑, `createdAt` ↓, `__name__` ↓ |
| `DiscoverClips` | `isPublic` ↑, `status` ↑, `uploadedAt` ↓, `__name__` ↓ |
| `DiscoverExercises` | `status` ↑, `name` ↑, `__name__` ↑ |

**Rollout order**: rules and indexes → deploy functions → `RebuildDiscoverCards.py <admin> all`.

### Step 3 — Ratings — built, not rolled out

**Cloud** (`src/Discover/`)
- `discoverExerciseRatings` / `discoverWorkoutRatings` share `syncRatingSummary`, which **recounts**
  the subject's `Ratings` with an aggregation query (`count` + `sum` of `rating`, integers 1–10
  only) inside a transaction with the card write — **never applies a +1 / +r delta.** Triggers are
  at-least-once, and a delta handler double-counts every redelivered event, permanently. A recount
  is idempotent and order-independent, the property `syncCard` has for projections.
- `ratingScore` — the Bayesian ordering score, `(5 × 5.5 + sum) / (5 + count)`. Ordering only;
  never shown.
- A subject that no longer exists gets no write (a template's cascade delete fires this per rating).
- Tests in `test/Discover/` — including redelivery not double-counting.

**App**
- Framework: `DiscoverSubject` (kind + id, **no paths**), `RatingSummary` (`average` is the one
  place the displayed average is worked out; `replacingRating(_:with:)` for the optimistic update),
  `RatingSummaryLoader`, `MyRatingLoader`, `RatingWriter`, preview conformers.
- `DiscoverRatingViewModel` updates the summary **before** the server recounts, and puts both the
  summary and the user's rating back if the write fails. `canRate` is false on your own workout.
- `DiscoverRatingSection` (average large over "N ratings", "Rate this" / "Your rating"),
  `DiscoverRatingSheet` (RPE sheet's layout, `darkColor` not RPE's colour scale).
- `DiscoverExerciseDetailScreen` / `DiscoverWorkoutDetailScreen` — header and rating for now; home
  and "see all" taps on exercises and workouts now open them. Clip taps still lead nowhere (step 4).
- Composition root: `DiscoverSubject+Firestore.swift` is **the one definition of every subject,
  card and rating path**; `FirestoreRatingSummaryLoader`, `FirestoreMyRatingLoader`,
  `FirestoreRatingWriter` (writes `createdAt` only on a first rating). `userId` read once in
  `DiscoverKitComposition` and injected.
- `RatingSummaryTests`, `DiscoverRatingViewModelTests` (+ `RatingWriterSpy`).

**Console — rules**
```
match /Exercises/{exerciseId}/Ratings/{userId} {
  allow read: if request.auth != null;
  allow create, update: if request.auth != null
    && request.auth.uid == userId
    && request.resource.data.keys().hasOnly(['rating', 'authorId', 'createdAt', 'updatedAt'])
    && request.resource.data.authorId == userId
    && request.resource.data.rating is int
    && request.resource.data.rating >= 1 && request.resource.data.rating <= 10
    && exists(/databases/$(database)/documents/Exercises/$(exerciseId));
  allow delete: if false;
}
match /WorkoutTemplates/{templateId}/Ratings/{userId} {
  allow read: if request.auth != null;
  allow create, update: if request.auth != null
    && request.auth.uid == userId
    && request.resource.data.keys().hasOnly(['rating', 'authorId', 'createdAt', 'updatedAt'])
    && request.resource.data.authorId == userId
    && request.resource.data.rating is int
    && request.resource.data.rating >= 1 && request.resource.data.rating <= 10
    && get(/databases/$(database)/documents/WorkoutTemplates/$(templateId)).data.isPublic == true
    && get(/databases/$(database)/documents/WorkoutTemplates/$(templateId)).data.createdBy != request.auth.uid;
  allow delete: if false;
}
```
No rating a private workout, and no rating your own. A rating can be changed, never withdrawn.

### Step 4 — Comments and likes — built, not rolled out

**Cloud** (`src/Discover/`)
- `syncCount` — recount a query into one field, in a transaction, **only if its owner exists** and
  **only if the number changed**. The second guard matters: `likeCount` written onto a comment fires
  that comment's trigger, and skipping no-op writes is what lets the chain settle.
- `discover{Exercise,Workout,Clip}Comments` → the card's `commentCount` (visible comments, replies
  included) and, for a reply, its parent's `replyCount`. `parentId` is read from either side of the
  event — on a delete only `before` has it.
- `discover{Exercise,Workout,Clip}CommentLikes` → the comment's `likeCount`.
- `discoverClipLikes` → `DiscoverClips/{id}.likeCount` — the card, never the clip.
- Tests in `test/Discover/`.

**App**
- Framework: `DiscoverComment` (status `visible` / `removed` / `hidden`; counts optional),
  `DiscoverCommentThread`, `DiscoverUserProfile`, `DiscoverLikeTarget` (`@frozen`, as is
  `DiscoverSubject` — the framework builds with library evolution, and both are closed sets).
  Protocols: `CommentLoader`, `ReplyLoader`, `CommentWriter`, `CommentRemover`, `LikeLoader`,
  `LikeWriter`, `UserProfileLoader`, `ClipWatchRecorder`. `CachingUserProfileLoader` remembers hits
  **and misses** for the session.
- `DiscoverCommentsViewModel` — paging newest first, replies loaded on first open (oldest first),
  post / like / remove all shown before the server confirms and put back on failure; a failed post
  keeps the draft. `attemptedProfileIds` separates "name loading" from "Deleted user".
- `DiscoverCommentsScreen` + `DiscoverCommentRow` + `DiscoverCommentComposer`. A removed comment stays
  as "Comment removed" only while replies hang off it. 500-character limit, matching the rules.
- `DiscoverCommentsEntrySection` on both detail screens.
- `DiscoverClipPlayerScreen` — looping player (`DiscoverLoopingPlayerView`, reports progress and
  loops), like, comments. **One watch recorded per visit, on leaving**, through `ClipWatchRecorder` —
  the composition root's existing `FirebaseFunctionsViewClipRecorder` conforms to both it and
  MyDayKit's `ViewClipRecorder`, so both tabs feed `recordClipWatch` by the one path.
- Composition root: `DiscoverLikeTarget+Firestore` (the one definition of a like's path), comment
  paths on `DiscoverSubject+Firestore`, and one Firestore adapter per protocol.
  `FirestoreUserProfileLoader` reads `Users` thirty ids at a time (the `in` limit).
- **Avatars are initials.** `Users/{uid}` holds no photo URL — photos are in Storage by uid.
- **No report or block yet** — step 6. Comments must not reach real users before it lands.
- Tests: `DiscoverCommentsViewModelTests`, `CachingUserProfileLoaderTests`,
  `DiscoverClipPlayerViewModelTests`, with spies under `Helpers/`.

**Console — rules** (inside `match /databases/{database}/documents`)
```
function isNewComment(commentId) {
  let d = request.resource.data;
  return request.auth != null
    && d.keys().hasOnly(['commentId', 'authorId', 'text', 'parentId', 'status', 'createdAt'])
    && d.commentId == commentId
    && d.authorId == request.auth.uid
    && d.status == 'visible'
    && d.text is string && d.text.size() > 0 && d.text.size() <= 500
    && (d.parentId == null || d.parentId is string)
    && d.createdAt == request.time;
}
function isAuthorRemoval() {
  return request.auth != null
    && resource.data.authorId == request.auth.uid
    && resource.data.status == 'visible'
    && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['status', 'text'])
    && request.resource.data.status == 'removed'
    && request.resource.data.text == '';
}
function isOwnLike(userId) {
  return request.auth != null && request.auth.uid == userId
    && request.resource.data.keys().hasOnly(['authorId', 'createdAt'])
    && request.resource.data.authorId == userId;
}
function canReadComment() {
  return request.auth != null && resource.data.status in ['visible', 'removed'];
}

match /Exercises/{exerciseId}/Comments/{commentId} {
  allow read: if canReadComment();
  allow create: if isNewComment(commentId);
  allow update: if isAuthorRemoval();
  allow delete: if false;
  match /Likes/{userId} {
    allow read: if request.auth != null;
    allow create: if isOwnLike(userId);
    allow delete: if request.auth != null && request.auth.uid == userId;
  }
}
match /WorkoutTemplates/{templateId}/Comments/{commentId} {
  allow read: if canReadComment();
  allow create: if isNewComment(commentId)
    && get(/databases/$(database)/documents/WorkoutTemplates/$(templateId)).data.isPublic == true;
  allow update: if isAuthorRemoval();
  allow delete: if false;
  match /Likes/{userId} {
    allow read: if request.auth != null;
    allow create: if isOwnLike(userId);
    allow delete: if request.auth != null && request.auth.uid == userId;
  }
}
match /Clips/{clipId}/Comments/{commentId} {
  allow read: if canReadComment();
  allow create: if isNewComment(commentId)
    && get(/databases/$(database)/documents/Clips/$(clipId)).data.isPrivate == false;
  allow update: if isAuthorRemoval();
  allow delete: if false;
  match /Likes/{userId} {
    allow read: if request.auth != null;
    allow create: if isOwnLike(userId);
    allow delete: if request.auth != null && request.auth.uid == userId;
  }
}
match /Clips/{clipId}/Likes/{userId} {
  allow read: if request.auth != null;
  allow create: if isOwnLike(userId);
  allow delete: if request.auth != null && request.auth.uid == userId;
}
```
Every comment query filters `status in ['visible', 'removed']`, or `canReadComment` rejects it.
`Users/{uid}` must be readable by signed-in users for comment authors to resolve.

**Console — composite indexes** (collection `Comments`, collection scope)

| Fields | For |
|---|---|
| `parentId` ↑, `status` ↑, `createdAt` ↓, `__name__` ↓ | top-level comments, newest first |
| `parentId` ↑, `status` ↑, `createdAt` ↑, `__name__` ↑ | replies, oldest first |

### Step 5 — Tags — built, not rolled out

**Decided here:** seeded tags **and** your own votes. Seeded (curated) tags on a catalogue exercise
play exactly the role a workout author's tags do — **base tags**, always visible, one vote each — so
the server has one rule for both. A user's own votes are shown to them at once, outlined, even
below the threshold; nobody else sees them until three people agree.

**Cloud** (`src/Discover/Tags/`)
- `tallyTags` — the one visibility rule: base tags always, community tags at `VISIBLE_TAG_VOTES` (3),
  ranked by votes then alphabetically, capped at 20; counts kept for the top 30.
- `voterTags` — one voter's tags through `tagRejection`, de-duplicated, capped at 10.
- `syncSubjectTags` — recomputes a subject's tags **from scratch** (base tags, every `TagVotes`
  document, and its existing index entries found by collection-group query on `subjectId`), writes
  `tagCounts` / `visibleTags` onto the card with `mergeFields` (a plain merge would never drop a
  tag), and adds / removes `Tags/{tag}/TaggedExercises|TaggedWorkouts/{id}` entries. **Only public
  subjects are indexed**; a workout author's own vote document is ignored.
- `syncTagDirectory` — recounts `Tags/{tag}` (`exerciseCount`, `workoutCount`, `totalCount`,
  `lastUsedAt`, default `status`). Tag documents are never deleted.
- Triggers: `discoverExerciseTagVotes`, `discoverWorkoutTagVotes` (votes), `discoverExerciseTags`,
  `discoverWorkoutTags` (the subject itself — base tags, visibility, name/title).
- **`onWorkoutTemplateWritten` and the `TaggedWorkoutTemplates` index are removed** —
  `PlanTagIndex`, `ApplyTagIndexPlan`, `TemplateCard`, `CardsEqual` and their test. `IndexedTags`
  stays as the base-tag validator; its tests moved to `test/Discover/indexedTags.test.ts`.
- `rebuildDiscoverCards` gains kinds `exercise-tags` and `workout-tags`.

**App**
- MyDayKit: **`WorkoutTag` is now `public`**, answered to DiscoverKit's `TagNormalizer` by the
  composition root's `WorkoutTagNormalizer` — the rule keeps one definition.
- Framework: `DiscoverTag`, `DiscoverTagged<Card>` (a card plus `voteCount`, decoded from one flat
  entry document), `visibleTags` / `tagCounts` on both cards. Protocols: `PopularTagsLoader`,
  `TagSuggestionLoader`, `TaggedExercisesLoader`, `TaggedWorkoutsLoader`, `MyTagVotesLoader`,
  `TagVoteWriter`, `TagNormalizer`.
- `DiscoverTaggingViewModel` — own votes loaded and shown at once, whole set written per change,
  optimistic with revert, 10-tag limit, field normalised as typed, suggestions debounced 250 ms.
- `DiscoverTagsSection` on both detail screens (no Tag button on your own workout), `DiscoverTagSheet`
  (Done only dismisses), `DiscoverTagScreen` (exercises and workouts, each paged by votes), a Tags
  section on the home screen. `DiscoverFlowLayout`, `DiscoverTagChip` (plain / mine / pending),
  `DiscoverHeaderButton`.
- Composition root: `DiscoverTagPath` (the one definition of the directory's paths), one Firestore
  adapter per protocol, `tagVotePath` on `DiscoverSubject+Firestore`.
- Tests: `DiscoverTaggingViewModelTests`, `DiscoverTaggedDecodingTests`, `TagVoteWriterSpy`.

**Scripts** — `SeedExerciseTags.py [--write]` derives each exercise's base tags from its
`muscleGroups`, `movementPatterns` and `category` (normalised: `upper_back` → `upperback`), keeps any
tags already there, caps at 20. `RebuildDiscoverCards.py` takes `exercise-tags` / `workout-tags`,
and `all` now runs them after the card kinds.

**Console — rules**
```
function isOwnTagVote(userId) {
  let d = request.resource.data;
  return request.auth != null && request.auth.uid == userId
    && d.keys().hasOnly(['tags', 'authorId', 'updatedAt'])
    && d.authorId == userId
    && d.tags is list && d.tags.size() >= 1 && d.tags.size() <= 10;
}

match /Exercises/{exerciseId}/TagVotes/{userId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow create, update: if isOwnTagVote(userId)
    && exists(/databases/$(database)/documents/Exercises/$(exerciseId));
  allow delete: if request.auth != null && request.auth.uid == userId;
}
match /WorkoutTemplates/{templateId}/TagVotes/{userId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow create, update: if isOwnTagVote(userId)
    && get(/databases/$(database)/documents/WorkoutTemplates/$(templateId)).data.isPublic == true
    && get(/databases/$(database)/documents/WorkoutTemplates/$(templateId)).data.createdBy != request.auth.uid;
  allow delete: if request.auth != null && request.auth.uid == userId;
}
match /Tags/{tag} {
  allow read: if request.auth != null;
  allow write: if false;
  match /{entries}/{subjectId} {
    allow read: if request.auth != null;
    allow write: if false;
  }
}
```
Once `TaggedWorkoutTemplates` is deleted, its rule can go too.

**Console — indexes**

| Collection | Scope | Fields |
|---|---|---|
| `Tags` | collection | `status` ↑, `totalCount` ↓ |
| `Tags` | collection | `status` ↑, `tag` ↑ |
| `TaggedExercises` | **collection group** | single-field `subjectId` ↑ (exemption) |
| `TaggedWorkouts` | **collection group** | single-field `subjectId` ↑ (exemption) |

The two collection-group exemptions are what `syncSubjectTags` finds a subject's entries with —
**without them every tag sync fails.**

### Step 6 — Moderation — built, not rolled out

**Decided here:** auto-hide at **3 distinct reporters**, or **1 admin**. Apple guideline 1.2 wants
prompt action; the queue is where a wrong hide gets restored.

**Cloud** (`src/Discover/Moderation/`, `DiscoverReportFiled.ts`)
- `reportTarget` — validates a client-written `targetKind` + `targetPath` against **one path shape
  per kind**, so a crafted report cannot hide an arbitrary document. Maps each to the document
  moderation sets `status` on: the comment itself; the **card** for a workout or clip (the author's
  template or clip stays usable in MyDay); `Tags/{tag}` for a tag.
- `isAdmin` — the reporter's `admin` custom claim, read from **Auth**, never from the report.
- `moderateTarget` — counts **distinct reporterIds** by querying `targetPath` (never report documents,
  whose ids the client picks), hides at 3 or on an admin report, upserts
  `ModerationQueue/{sha256(targetPath)}` (`reportCount`, `reasons`, `status: open|hidden`,
  `firstReportedAt`, `updatedAt`, `adminReported`). A comment already `removed` stays removed.
  Nothing lifts a hide — restoring is the admin app's.
- **Hiding reuses what exists**: lists filter `status == "visible"`, counts count visible only,
  `syncCard` / `syncTagDirectory` never overwrite a status. `syncSubjectTags` now **skips a hidden
  card and drops hidden tags** from every subject, so a hidden workout leaves the tag pages and a
  hidden tag leaves every exercise and workout — both re-derived straight after hiding.
- `discoverReportFiled` — `onDocumentCreated` on `Reports/{reportId}`.
- Tests: `reportTarget.test.ts`, `discoverReportFiled.test.ts` (admin path via the Auth emulator).

**App**
- Framework: `DiscoverReportTarget` (`@frozen`), `DiscoverReportReason` (fixed list — no free text),
  `BlockedUsersLoader`, `MyReportsLoader`, `ReportWriter`, `BlockedUsersWriter`.
- **`DiscoverModerationStore`** — one per flow, built by the router, handed to every listing screen.
  Blocks and the user's own reports, loaded once a session; report and block both apply at once
  and revert on failure. **Filtering is on the device, by design** — a block is private and
  one-way, so no other user's query could honour it.
- Report: `⋯` on other people's comments (report / block), `⋯` on someone else's workout detail and
  clip player (clip also offers block), long-press a tag chip. `DiscoverReportSheet` — reason list,
  then "You won't see this again. We'll review it." A reported workout or clip closes its screen.
- Filtered: home clips / workouts / tags, clip grid, workout list, tag pages, comments and replies.
- `DiscoverBlockedUsersScreen` (from the comments screen's `⋯`) — the list, with Unblock.
- Composition root: `DiscoverReportTarget+Firestore` (**must match `ReportTarget.ts`'s shapes**),
  `DiscoverBlockPath`, `FirestoreReportWriter` (id `{uid}_{sha256(path)}`), `FirestoreMyReportsLoader`,
  `FirestoreBlockedUsersLoader` / `Writer`.
- Tests: `DiscoverModerationStoreTests`, `ModerationSpy`.

**Console — rules**
```
function isAdminStatusChange() {
  return request.auth != null && request.auth.token.admin == true
    && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['status'])
    && request.resource.data.status in ['visible', 'hidden'];
}

match /Reports/{reportId} {
  allow read: if request.auth != null && resource.data.reporterId == request.auth.uid;
  allow create: if request.auth != null
    && reportId.matches(request.auth.uid + '_[0-9a-f]{64}')
    && request.resource.data.keys().hasOnly(['reporterId', 'targetPath', 'targetKind', 'reason', 'createdAt'])
    && request.resource.data.reporterId == request.auth.uid
    && request.resource.data.targetKind in ['comment', 'workout', 'clip', 'tag']
    && request.resource.data.reason in ['spam', 'harassment', 'hate', 'sexual', 'violence', 'other']
    && request.resource.data.targetPath is string && request.resource.data.targetPath.size() <= 300
    && request.resource.data.createdAt == request.time;
  allow update, delete: if false;
}
match /ModerationQueue/{key} {
  allow read: if request.auth != null && request.auth.token.admin == true;
  allow write: if false;
}
match /Users/{userId}/BlockedUsers/{blockedId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```
And, for the admin app later, add `|| isAdminStatusChange()` to the `update` rule of every
`…/Comments/{commentId}` block from step 4, and an `allow update: if isAdminStatusChange();` to
`DiscoverWorkouts`, `DiscoverClips` and `Tags/{tag}`.

**Console — indexes**: none. Both report queries are single-field equality.

### Step 7 — Workout and exercise pages — built, not rolled out

**Decided here:** the workout page's one action is **Save to Library** — never "Add to Today";
putting a workout on a day is MyDay's job, from the library, where the date strip is. The save is
**a copy, not a reference**: private, the saver's own, and unchanged when the author edits theirs —
the same reasoning as snapshotting a coach-assigned workout at accept time.

**App — MyDayKit**
- `WorkoutTemplateModel.copiedFrom: String?` — optional, as every new persisted field must be; a
  `var` with a default so the builder's construction is unchanged.
- `WorkoutTemplateModel.copy(savedBy:id:at:)` — **the one definition of a copy**: new id, the
  saver's `createdBy`, created now, `isPublic: false`, content and tags unchanged, `copiedFrom` set.
- `WorkoutTemplateModelCopyTests`, and the MyDayKit scheme now runs `MyDayKitTests` — it had no
  test action, so no MyDayKit test could run from the scheme at all.

**App — DiscoverKit**
- `DiscoverWorkoutDetail` / `DiscoverWorkoutExercise` / `DiscoverWorkoutSet` — the page's own
  read-only model. `DiscoverWorkoutExercise.summary` (`4 × 8 · 80 kg`, `3 × 8–12`, a varying load
  left out rather than averaged).
- Protocols: `DiscoverWorkoutDetailLoader`, `ExerciseClipsLoader`, `WorkoutCopySaver`,
  `SavedWorkoutCopyChecker` — the last two **optional** in the router: nil on the coach tab bar,
  which has no MyDay, and on the user's own workout.
- Workout page: author ("by …"), description, **Save to Library** (checks for an existing copy
  first; `Saved` / failed-with-retry), the exercises with their summaries, then rating, tags,
  comments. Exercise page: a strip of that exercise's newest clips.
- The tag page's stray divider for a hidden workout is fixed.
- Tests: `DiscoverWorkoutExerciseSummaryTests`, `DiscoverWorkoutDetailViewModelTests`,
  `WorkoutCopySaverSpy`.

**App — composition root**
- `MyDayWorkoutLibrary` — MyDay's template saver, library manager and local store, **the same
  instances MyDay uses**, handed out by `MyDayKitComposition.workoutLibrary`. A copy written through
  any other saver would skip the sync queue; one added to any other manager would not show in
  MyDay's already-loaded library until relaunch.
- `FirestoreWorkoutTemplateByIdFetcher` (behind `WorkoutTemplateByIdFetching`) — one reader for both
  the page and the copy. `TemplateDiscoverWorkoutDetailLoader` maps the template to the page model.
- `LibraryWorkoutCopySaver` — read, `copy(savedBy:)`, save through MyDay's saver, add to MyDay's
  manager; knows no paths. `LibraryWorkoutCopyChecker` — reads the local store, so a copy saved a
  moment ago counts before it syncs.
- `FirestoreExerciseClipsLoader`.
- `DiscoverKitComposition.composeCombination` now takes `workoutLibrary:` — **wired in step 9**,
  where the player tab bar passes MyDay's and the coach tab bar passes `nil`.

**Console — index**

| Collection | Fields |
|---|---|
| `DiscoverClips` | `exerciseId` ↑, `isPublic` ↑, `status` ↑, `uploadedAt` ↓ |

No new rules: a copy is written through the existing template pipeline, as the saver's own private
template.

### Step 8 — `deleteDiscoverData(uid)` — built, not called yet

A module, not a trigger: the separate account-deletion feature calls it, alongside the MyDay, stats,
Storage, `Usernames` and RTDB pieces. Built and tested here because only DISCOVER knows where its
data lives. Nothing calls it until that feature exists.

**Cloud** (`src/Discover/Deletion/`)
- `deleteDiscoverData(db, bucket, userId)` returns a summary of what it did:
  - **ratings, likes, tag votes, reports** — hard-deleted via collection-group queries on `authorId`
    (`reporterId` for the top-level `Reports`). The existing triggers recount every card and comment
    they counted toward; the deletion never touches a count.
  - **comments** — one that **someone else** has replied to becomes a placeholder (text cleared,
    `authorId` removed, `removed` — or still `hidden` if moderation hid it), so their replies read
    under "Comment removed". Every other comment is deleted with its likes. Only other people's
    replies count: the user's own replies go in the same pass, and a placeholder kept for them would
    be empty. Judging it that way needs no ordering, which paging could not guarantee.
  - **clips** — the document and everything under it, plus `TestClips/{uid}/` and
    `TestClipThumbnails/{uid}/` in Storage. The clip-card trigger removes the card.
  - **workout templates**, public and private — the top-level document and everything under it; the
    card and tag triggers clean up. Copies other people saved are theirs and stay.
  - **the user's block list.**
- `forEachInPages` — re-runs the query from the start after each page (every handler takes the
  document out of the query), so **a run that stops halfway resumes on the next**; a page with
  nothing new ends the loop rather than spinning. Auth deletion triggers are at-least-once and a
  large account may need several runs.
- Tests: `deleteDiscoverData.test.ts` — including a second run finding nothing.
- Not in scope: `Users/{uid}/WorkoutTemplates` and the rest of `Users/{uid}` — the account-deletion
  feature deletes that subtree. Other users' `BlockedUsers/{uid}` entries for this user are left;
  they are harmless and cannot be found without reading every user's blocks.

**Console — indexes** (collection-group single-field exemptions, `authorId` ↑)

| Collection group | Field |
|---|---|
| `Ratings` | `authorId` |
| `Comments` | `authorId` |
| `Likes` | `authorId` |
| `TagVotes` | `authorId` |

### Step 9 — Tab wiring and legacy removal — built, not rolled out

**App**
- **Player tab bar** composes DiscoverKit **after** MyDay and hands it `myDayKit.workoutLibrary`, so
  Save to Library writes through MyDay's own saver and shows in MyDay's library at once.
- **Coach tab bar** composes DiscoverKit with `workoutLibrary: nil` — no MyDay, so no Save.
- **Removed — the old Discover tab's own code**, now referenced by nothing: `DiscoverCoordinator`,
  `DiscoverPageView` / `ViewController` / `ViewModel`, `DiscoverSectionHeader`, `DiscoverMoreWorkouts`,
  `DiscoverMoreClips`, `DiscoverPageDataSource`, `DiscoverPageSections+Items`, `DiscoverPosts` (and a
  stray untracked-by-the-project `DiscoverPosts 2.swift`). Their project entries and the two emptied
  groups went with them. The dead `TabBarCoordinator` (never constructed —
  `MainCoordinator.coordinateToTabBar()` has no caller) lost its discover tab so it still compiles.
- **Kept, deliberately — still reached from other legacy flows**, so not Discover's to delete:
  `ExerciseDescriptions/` and `ExerciseDiscoveryCoordinator` (from legacy workout display / creation,
  player detail, saved workouts), `WorkoutDiscovery/` (saved workouts), `SearchViewController` +
  `DiscoverSearchView` (comments, post creation), `PublicProfileViewController` (posts),
  `DiscoverMoreTags` (tag search), and the RTDB models they use. They go when those flows go — the
  same question CLAUDE.md raises about `PlayerInitialViewController` building tabs it never shows.

### Step 10 — Tests and documentation — done

- **Tests**: 93 Cloud Functions tests on the emulator (`test/Discover/`, `test/Tags/`), 74 DiscoverKit
  tests, and MyDayKit's copy tests — written step by step rather than here.
- **CI test plan**: every framework suite added — `StatsKitTests`, `MyDayKitTests`,
  `AccountCreationKitTests`, `LoginKitTests`, `DiscoverKitTests` — with all five frameworks under code
  coverage.
- **CI is not running, for reasons outside DISCOVER**: every run fails before starting on a GitHub
  billing error; the workflow pins Xcode 15.3 (cannot open the `objectVersion = 77` framework
  projects), an iOS 17.4 simulator and a wrong workspace path.
- **Minimum iOS raised to 26.0** for the app and all five active frameworks. StatsKit was built for
  26.1 and MyDayKit for 18.4 against the app's 17.0 — the app could not have launched below 26.1, and
  StatsKit's tests could not run on any installed simulator. All five suites now pass on iOS 26.0:
  StatsKit 28, MyDayKit 7, DiscoverKit 74 (LoginKit and AccountCreationKit have no tests yet).
- **Docs**: a *DISCOVER Tab* section in the app's `CLAUDE.md`, the new collections in its Firestore
  table, five new keep-in-step pairs, the CI section corrected; a *DISCOVER* section in the Cloud
  Functions repo's `CLAUDE.md`.

**The build is complete. What remains is the rollout checklist above** — rules, indexes, deploys,
seeding and backfills, in step order.

## Out of scope

- **Account deletion** — separate feature. The app has no in-app deletion today, which App Store
  guideline 5.1.1(v) requires. It will call `deleteDiscoverData(uid)` alongside the MyDay, stats,
  Storage, `Usernames` and RTDB pieces.
- **Admin moderation UI** — later, in `InTheGym-Admin` or the dashboard, reading `ModerationQueue`.
- **Automatic profanity filtering of comments** — can be added to the comment-create trigger later.
- **Clips recorded inside a workout session** — clips are only created from single-exercise logging.
