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

## Steps

### Step 1 — Groundwork ✅

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

### Step 2 — Cards and the DiscoverKit skeleton

**Cloud**
- `onExerciseWritten` → `DiscoverExercises` projection.
- `onWorkoutTemplateWritten` (extend) → `DiscoverWorkouts` projection, alongside its tag work.
- `onClipWritten` → `DiscoverClips` projection.
- **Move `recordClipWatch`'s counts from `Clips/{clipID}` to `DiscoverClips/{clipID}`.** It
  merges `viewCount` etc. onto the clip document itself — the exact thing *Who writes what*
  forbids. It is harmless only while the app writes a clip once, at upload; the first client edit
  of a clip (e.g. making it private) would wipe them with a `setData`. Looks up `exerciseName` from
  `Exercises/{exerciseID}` (the clip does not carry one) and parses `duration` out of
  `videoMetaData`, which stores it as a string.
- Deleting a subject: `recursiveDelete` its subcollections (ratings, comments, likes, votes) and
  delete its card and tag entries.

**App — framework**
- Scaffold `DiscoverKit.xcodeproj` from the StatsKit template: `PBXFileSystemSynchronizedRootGroup`,
  `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES`, a test target. Its own
  `UI/Color+Extension.swift` and `addSwiftUIView`, as every framework carries.
- `DiscoverSubject` (`.exercise(id)` / `.workout(id)` / `.clip(id)`) — the one definition of every
  engagement path. **No call site builds a path.**
- Card models: `DiscoverExerciseCard`, `DiscoverWorkoutCard`, `DiscoverClipCard`. Every field that
  may be absent on an existing document is optional.
- `DiscoverKitRouter` with `DiscoverKitRoutes`; home screen (Clips / Workouts / Exercises / Tags
  sections) and "see all" lists.

**App — composition root** (`InTheGym/Launch/Composition/DiscoverKit/`, one adapter per file)
- `DiscoverKitComposition` and the card loaders.

### Step 3 — Ratings

**Cloud**
- One handler, triggered on `Exercises/{id}/Ratings/{uid}` and `WorkoutTemplates/{id}/Ratings/{uid}`:
  applies deltas to `ratingCount` / `ratingSum` (create +1/+r, update +(new−old), delete −1/−r) and
  recomputes `score`. Idempotent under at-least-once delivery.

**App**
- `RatingLoader` (the summary, and the current user's rating) and `RatingWriter`.
- `RatingSummary.average` — the one place the average is worked out.
- 1–10 rating sheet in the RPE sheet's visual language. Hidden on the user's own workouts.

### Step 4 — Comments and likes

**Cloud**
- Comment triggers maintain the card's `commentCount` (visible comments only — a status change
  adjusts it) and the parent comment's `replyCount`.
- Like triggers maintain `likeCount` on comments and on `DiscoverClips`.

**App**
- `CommentLoader`, `CommentWriter`, `CommentRemover`, `LikeWriter`, `LikeLoader`.
- `UserProfileLoader` over Firestore `Users/{uid}`, behind a decorator that collects the unique ids on
  screen, fetches in batches of 30 (`in` query) and caches for the session. A missing profile renders
  as "Deleted user".
- Comments screen: top-level list, one level of replies, "Comment removed" placeholder rows, like
  button, delete own comment.
- Clip like button, and the Discover clip player — DiscoverKit's own screen, not MyDay's
  `ClipPlaybackScreen`.

### Step 5 — Tags

**Cloud**
- **Replace `TaggedWorkoutTemplates` with the `Tags` tree.** Nothing in the app reads it today, so
  the move is free now and would need a reader migration later.
- `TagVotes` trigger (exercises and workouts): diff before/after, maintain `tagCounts` /
  `visibleTags` on the card, and `Tags/{tag}/…/{id}.voteCount`.
- Change `planTagIndex` for workouts to index **author tags ∪ community tags with ≥ 3 voters**, the
  author's tags counting as one vote each, and carry `voteCount` on every entry.
- Maintain `Tags/{tag}.exerciseCount` / `workoutCount` / `totalCount` on the tag crossing the
  visibility threshold in either direction, and on a workout's `isPublic` changing.
- Every tag through the shared validator and blocklist.

**App**
- `TagVoteLoader`, `TagVoteWriter`, `TagDirectoryLoader`, `TaggedSubjectsLoader`.
- `TagNormalizer` protocol, implemented in the composition root by an adapter over MyDayKit's
  `WorkoutTag.normalized` — so the rule still has one definition. (`WorkoutTag` is `internal` today
  and needs to be made `public`.)
- Tag sheet on exercise and workout detail: ranked visible tags, add a tag, remove your own, prefix
  suggestions from `Tags`. Not offered on your own workout — author tags are edited in the builder.
- Tag screen: exercises and workouts for one tag, each ordered by `voteCount`.
- Home screen Tags section: `Tags` ordered by `totalCount`.

### Step 6 — Moderation

**Cloud**
- `Reports` trigger: count reports per target; at **3**, or **1 from an admin**, set
  `status: "hidden"` on the comment, card or `Tags/{tag}`, and upsert `ModerationQueue/{targetHash}`.
- Tag blocklist enforced in the validator (step 1).

**App**
- `ReportWriter`; report sheet with a fixed reason list, on comments, workouts, clips and tags.
- `BlockedUsersLoader` / `BlockedUsersWriter`; blocked users' comments and clips filtered client-side.

### Step 7 — Workout and exercise detail, and shared actions

**App**
- Exercise detail: rating, tags, comments, and the exercise's clips.
- Workout detail: DiscoverKit's own `DiscoverWorkout` read model, rating, tags, comments.
- Actions reached through composition, never by importing another framework:

| Discover needs | DiscoverKit declares | Composition root provides |
|---|---|---|
| Add a workout to today | `DiscoverWorkoutAdder` | Adapter that fetches the full `WorkoutTemplateModel` and calls MyDay's `addWorkoutToDay`. The entry snapshots the template, so the author later deleting it breaks nothing. |
| Normalise a tag | `TagNormalizer` | Adapter over `WorkoutTag.normalized` |
| Record a clip watch | `ClipWatchRecorder` | The existing `FirebaseFunctionsViewClipRecorder`, conformed in an extension |

### Step 8 — `deleteDiscoverData(uid)`

**Cloud** — a module the separate account-deletion feature will call. Built and tested here.
- Hard-delete the user's `Ratings`, `Likes`, `TagVotes` and `Reports` via collection-group queries on
  `authorId`. **The existing triggers correct every count** — the deletion never touches a count.
- Comments: delete those with no replies; turn those with replies into placeholders (`text` cleared,
  `authorId` removed, `status: "removed"`) so other people's replies still make sense.
- Delete the user's clips (document, Storage video and thumbnail) and public workouts; their subject
  triggers clean up cards, tag entries and everything other people left on them.
- **Re-runnable**: every step is a delete-if-exists that resumes where it stopped. Auth triggers are
  at-least-once and a heavy account may outlast one invocation.

### Step 9 — Tab wiring and legacy removal

**App**
- Replace `DiscoverCoordinator` with DiscoverKit in **both** `PlayerInitialViewController` and
  `CoachInitialViewController`.
- Delete the legacy RTDB Discover once unreferenced: `Discover/`, `WorkoutDiscovery/`,
  `ExerciseDescriptions/`, `DiscoverPageDataSource`, and the models behind them (`ExerciseRatingModel`,
  `WorkoutRatingModel`, `ExerciseCommentModel`, `WorkoutCommentModel`, `TagModel`, `DiscoverExerciseModel`).

### Step 10 — Tests and documentation

**Cloud**
- Emulator tests for every trigger, one file per function, namespaced ids, following the existing
  suite.

**App**
- `DiscoverKitTests` in the `StatsKitTests` style: rating average, tag visibility threshold, profile
  batching and caching.
- **Add `DiscoverKitTests` to `CI_iOS_TestPlan.xctestplan`** — a target outside the plan does not run.

**Docs**
- A Discover section in this repo's `CLAUDE.md`, and the new paths in its Firestore table.
- The Discover functions in `InTheGym-CloudFunctions/CLAUDE.md`.

---

## Out of scope

- **Account deletion** — separate feature. The app has no in-app deletion today, which App Store
  guideline 5.1.1(v) requires. It will call `deleteDiscoverData(uid)` alongside the MyDay, stats,
  Storage, `Usernames` and RTDB pieces.
- **Admin moderation UI** — later, in `InTheGym-Admin` or the dashboard, reading `ModerationQueue`.
- **Automatic profanity filtering of comments** — can be added to the comment-create trigger later.
- **Clips recorded inside a workout session** — clips are only created from single-exercise logging.
