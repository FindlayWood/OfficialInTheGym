# PROFILE tab — plan

The agreed design for rebuilding PROFILE on Firestore as its own framework, **ProfileKit**. Nothing
here is built yet. Work is split into steps, each listing what changes in this repository (**App**)
and in `InTheGym-CloudFunctions` (**Cloud**), the same shape as `DISCOVER_PLAN.md`.

The decisions below come from an interview on 2026-10-03. Anything marked **open** was not settled
there. Each open item has a recommended default, but treat it as a question, not an answer.

---

## What is there today

The PROFILE tab is `MyProfileCoordinator` → `MyProfileViewController`: legacy UIKit, about 60 files
under `MyProfile/`, `PlayerPages/PlayerProfileMore/`, `CoachPages/CoachProfileMore/`,
`DataSources/Profile*` and `CellClasses/ProfileCells/`. **Every read and write is the Realtime
Database.**

| Part | Today | Store |
|---|---|---|
| Header | photo, display name, @username, follower/following counts, stamps (elite, verified, premium), bio | RTDB `users/{uid}`, Storage `ProfilePhotos/{uid}` |
| Body | the user's posts feed (`PostSelfReferences` → `Posts`), with like/comment/delete | RTDB |
| Header taps | followers / following (`MyFollowers`), clips (`MyClips`), saved workouts (`MyWorkouts`, the legacy `SavedWorkouts`, **not** MyDay templates), stamps preview | RTDB |
| "More" menu | Edit Profile, Subscription, **Exercise Stats, Workout Stats, Performance Center**, Settings. Measurements, My Coaches and Requests are commented out. Jump measuring and breathwork are reached from here too | mixed |
| Edit Profile | photo → Storage `ProfilePhotos/{uid}`; bio → **RTDB** `users/{uid}/profileBio` | RTDB + Storage |
| Settings | version, about, Instagram / website, contact email, reset password, log out | — |
| Other users | `UserProfileCoordinator` → `PublicTimelineViewController`, with public clips / workouts / followers | RTDB |

None of the newer data shows on the profile: MyDay templates, `WorkoutSessions`, Firestore `Clips`,
`ExerciseStats`, DISCOVER. There is **no in-app account deletion**, which App Store guideline
5.1.1(v) requires. DISCOVER shows authors' names but cannot open their profiles.

Two existing defects this plan has to deal with rather than copy:

- **Other users read `Users/{uid}` directly.** `FirestoreUserProfileLoader` (DISCOVER's author
  names) queries other people's `Users` documents. Firestore rules cannot hide individual fields, so
  whatever lets that query through also lets anyone read a user's **email**, and the body
  measurements this plan persists would land there too. See `Profiles/{uid}` below.
- **`Users` is decoded from two stores** (Firestore on the launch path, RTDB for followers, coaches
  and requests). The bio is written only to RTDB today, so it already disagrees between screens.

---

## Decisions

| Area | Decision |
|---|---|
| Framework | **ProfileKit**, built like DiscoverKit / LoginKit: a `PBXFileSystemSynchronizedRootGroup` per target and no file references. Firestore only. Imports no other framework. |
| Purpose | **Identity + public.** A header plus training highlights, and **your own profile is what other people see of you**: one screen, with owner-only controls added when it is yours. |
| Posts | **Gone.** No posts feed, no post creation from the profile. NEWSFEED's future is decided separately. |
| Followers / following | **Kept, rebuilt on Firestore** as a new model (`Follows`, below). The RTDB graph is migrated. |
| Follow model | **Open by default, with an optional private account.** A private account turns new follows into requests the owner approves. |
| Sections | **Header with stamps → PBs / highlights → Clips.** Public workouts were *not* chosen for the profile. |
| Workout history | **Not in this plan.** |
| Stats entries | **Exercise Stats and Workout Stats come out of the profile**; the STATS tab covers them. |
| Performance Center | **Out of scope, a separate roadmap task. Do not delete any of its code.** Its entry point is the only question (see open questions). |
| Edit Profile | **Photo, display name, bio, and body measurements** (height, weight, date of birth), with **weight logged over time**. Username changes were *not* chosen. |
| Settings | **Account deletion, private account toggle (+ requests inbox), subscription**, plus the existing items: reset password, log out, contact, version, about. |
| Other users | Opened from **DISCOVER authors, followers / following lists, and user search.** |
| Coaches | **Not considered.** The coach/player split is being removed, so ProfileKit has no `accountType` branch. The coach tab bar keeps the legacy `MyProfileCoordinator` until that work removes it. |
| Design | **MyDay's vocabulary**, as onboarding uses: `systemBackground` page, `secondarySystemBackground` cards at radius 14/16, uppercase caption headers, `Color.darkColor` accents, no shadows. *Recommended. The interview did not cover design.* |

---

## Data model

```
Users/{uid}                              owner + createAccount — PRIVATE to the owner from step 2
  isPrivate: Bool?                       new, optional
  heightCentimetres: Double?             new, optional (already sent by signup, dropped by the function)
  dateOfBirth: Timestamp?                new, optional
  heightUnit / weightUnit: String?       new, optional — how to read back, not what the number means
  pinnedHighlights: [String]?            new, optional — exerciseIds, see step 8
  WeightTracking/{yyyy-MM-dd}            owner + createAccount — id, date, createdDate,
                                         weightKilograms, weightUnit?. UTC day key (WeightDay)
  BlockedUsers/{uid}                     exists (DISCOVER)

Profiles/{uid}                           SERVER — the public projection: everything anyone else reads
  userId, username, displayName, bio,
  verified, elite, status,               status: moderation's, "visible" by default (step 9)
  isPrivate,
  followerCount, followingCount, clipCount,
  highlights: [{exerciseId, exerciseName, maxWeight, maxTime}],
  usernameLower, displayNameLower,       for search
  updatedAt

Follows/{followerId}_{followeeId}        follower creates; followee approves / removes
  followerId, followeeId,
  status: "active" | "pending",
  createdAt, approvedAt?
```

### Rules of the model

- **Others read `Profiles`, never `Users`.** `Profiles/{uid}` is a projection a Cloud Function
  writes whenever `Users/{uid}`, a follow, a clip or an `ExerciseStats` document changes, the same
  pattern as DISCOVER's cards. Once it exists, rules close `Users/{uid}` to everyone but its owner,
  and `FirestoreUserProfileLoader` moves to `Profiles`. Email and body measurements are then
  structurally unreadable by anyone else, which no field-level rule could achieve.
- **Every count is a recount, never a delta**, as in DISCOVER. Triggers are at-least-once.
- **Counts never live on `Users`.** The owner edits `Users/{uid}`, and a `setData` from any client
  path would wipe them. They live on `Profiles`, which only the server writes.
- **One document per follow relationship, not mirrored `Followers` / `Following` subcollections.**
  One document means one writer per transition: the follower creates it, the followee approves or
  deletes it, and either can delete it. Followers are `where followeeId == X, status == active` and
  following is `where followerId == X, status == active`. A mirrored pair would be the two-writer
  shape *Composition root mechanics* forbids, and a pair that drifts shows a follower on one screen
  and not the other.
- **The rules decide `active` vs `pending`, not the client.** Create is allowed only when
  `followerId == auth.uid` and `status` matches `get(/Profiles/{followeeId}).isPrivate`: pending if
  private, active if not. A client cannot follow a private account by claiming `active`.
- **Turning private off approves every pending request** (Cloud Function). Turning private on does
  not remove existing followers. It only changes what new follows do.
- **A private profile shows its header to everyone, and its highlights and clips only to approved
  followers.** *Recommended. The interview did not cover what private hides* — see open questions,
  including whether a private user's clips leave DISCOVER.
- **New fields on `Users` are optional.** Every existing document lacks them. See the Firestore
  decode warning under *Workout Library Loading* in `CLAUDE.md`.
- **Weight is a log, not a field.** `WeightTracking/{yyyy-MM-dd}` keyed by a UTC day, one
  entry per day, the latest wins. `WeightUnit.percentBodyweight` prescriptions need the *current*
  weight, and a number captured once at signup goes quietly wrong. The signup value becomes the first
  entry. Weight is stored canonically in kilograms, as everywhere else.
- **Blocking cuts follows.** Blocking someone deletes `Follows` in both directions (Cloud Function),
  and a blocked user sees an empty profile. This uses DISCOVER's existing `BlockedUsers`.

---

## Steps

### Step 1 — ProfileKit skeleton, own profile, settings — built

**App**
- `ProfileKit.xcodeproj`, generated from DiscoverKit's with object ids prefixed **`BF10`**, plus
  `BF1A` for its entries in the app's pbxproj. `IPHONEOS_DEPLOYMENT_TARGET = 26.0`. It is in
  `InTheGym.xcworkspace`, and `ProfileKitTests` is in `CI_iOS_TestPlan.xctestplan` (both the
  coverage list and the test targets). It has its own `UI/Color+Extension.swift`, adding
  `premiumColor` (`#79B49F`, the colorset's value) and `eliteColor` (`goldColour`).
- `ProfileKitRouter` (`.myProfile`, `.settings`), `ProfileKitBoundaryViewController` hiding the
  system bar around the root, and `ProfileKitComposition` in
  `InTheGym/Launch/Composition/ProfileKit/`. **It replaces `MyProfileCoordinator` on the player tab
  bar only**; `CoachInitialViewController` and `TabBarCoordinator` are untouched.
- `MyProfileScreen`: a custom title bar ("Profile" and a settings gear, where the old "More" menu
  was) and `ProfileHeaderCard` showing the photo, display name with inline stamps, @username and
  bio. There is a skeleton while loading and a "Couldn't Load Profile" card with Try Again.
  **Follower counts are absent, not zero**, until step 5.
- `ProfileSettingsScreen`:
  - **Subscription:** status, Upgrade (the existing paywall) or Manage (the App Store sheet), and
    Restore Purchases with its own states.
  - **Account:** Reset Password, confirmed first, sends once per visit, with sent / failed states.
  - **Tools:** Performance Center.
  - **About:** About, Instagram, Website, Contact, Icons8, Version.
  - **Session:** Log Out, confirmed first, with an error alert on failure.
- Protocols: `MyProfileLoader`, `ProfilePhotoLoader`, `ProfileSubscriptionService` (named so it
  does not clash with the app's own `SubscriptionService`), `ProfileSignOutService`,
  `PasswordResetService`, each with a public `Preview…` conformer.
- App adapters:
  - `CurrentUserMyProfileLoader` reads `UserDefaults.currentUser` on each load.
  - `ImageCacheProfilePhotoLoader` maps Storage `objectNotFound` to `nil`.
  - `PurchaseManagerSubscriptionService` and `FirebaseProfilePasswordReset` (email injected).
  - `ProfileAppRoutes` covers the paywall, manage subscriptions, Performance Center and About.
- **`AppSignOut`** is the sign-out sequence lifted out of `SettingsViewModel.logout()`. The legacy
  settings and ProfileKit both call it, and it is listed under *A rule that exists in two places*
  in `CLAUDE.md`. `Constants.contactEmail` replaces the address hardcoded in `SettingsView`.
- **Not carried over:** posts, legacy saved workouts, Exercise Stats, Workout Stats, and the
  commented-out Measurements / My Coaches / Requests. Jump and Breathwork had no live row in the old
  menu (their actions existed, but nothing called them), so nothing was lost. **Their code, and all
  of Performance Center's, stays in the repository.**
- **Open question 1, resolved by the recommended default:** Performance Center keeps a row under
  Tools in settings. Dropping it is one row and one closure.
- **Stamps colour:** the header is SwiftUI, so premium is the green colorset value. The purple
  `UIColor.premiumColour` conflict is still app-wide and still unresolved.
- Tests (20): `MyProfileViewModelTests`, `ProfileSettingsViewModelTests`, `ProfileStampTests`.
- **Known gap:** the bio comes from Firestore `Users.bio`, while the legacy Edit Profile writes
  RTDB `users/{uid}/profileBio`. A bio edited before step 3 will not show. Step 3 closes this.

### Step 2 — `Profiles` projection, `Users` closed — built, not rolled out

**Cloud** (`InTheGym-CloudFunctions`, branch `profile`, cut from `discover` because it reuses
`syncCard`)
- `syncProfile` (v2, `Users/{uid}` written) projects `Profiles/{uid}` through DISCOVER's
  `syncCard`: current state read in a transaction, own fields merged, `status` defaulted to
  `"visible"` and never overwritten. A deleted user deletes the profile.
- `profileProjection` is an **allow-list**: `userId`, `username`, `displayName`, `bio`,
  `verified`, `elite`, `usernameLower`, `displayNameLower`. Missing fields become `""` / `false`
  rather than absent. A test asserts that the email, body measurements and account type are never
  copied.
- `rebuildProfiles` (v1 callable, `admin` claim) re-projects the union of `Users` and `Profiles`
  ids, so it backfills and also removes orphans. Tests: 11, against the emulator.
- **No `photoURL`.** The photo stays at Storage `ProfilePhotos/{uid}`, addressed by the uid the
  client already has. Step 3 may add a `photoUpdatedAt` if cached photos need busting after an
  edit.

**Scripts:** `InTheGym-Scripts/RebuildProfiles.py <admin>` calls the callable. It reuses
`RebuildDiscoverCards.py`'s admin sign-in.

**App**
- `FirestoreUserProfileLoader` (DISCOVER's author names) reads `Profiles` instead of `Users`. It was
  the **only** client read of another user's `Users` document. The launch path's
  `UserAPIServiceAdapter` reads only the signed-in user's own document, which the new rule still
  allows.
- **Deferred to step 7:** ProfileKit's loader for other people's profiles. Nothing shows another
  user's profile until then, and a protocol with no caller is dead code. The own-profile header
  keeps reading the cached `currentUser`.
- The emulator needs nothing new. `SeedDiscover.py` writes `Users` documents and the functions
  emulator builds `Profiles` from them, as it builds cards, provided the functions are built from
  this branch.

**Rules** (console). Add:

```
match /Profiles/{userId} {
  allow read: if request.auth != null;
  allow write: if false;
}
```

Then, **last, after the backfill**, change the read rule on `Users/{userId}`. Keep its write rules
as they are:

```
match /Users/{userId} {
  allow get: if request.auth != null && request.auth.uid == userId;
  allow list: if false;
  // …existing write rules unchanged
}
```

### Step 3 — Edit profile: photo, name, bio — built, not rolled out

**Changed from the plan:** the legacy store is kept in step **server-side**, not by a second client
writer. The client writes Firestore `Users/{uid}` only. `onCreateAccount` already bridged Firestore
to RTDB at signup, and a matching `onEditAccount` bridges edits, so one bridge covers every writer
(this app, an admin, a future web client). Two client writers would also leave a legacy key the
client has to know forever.

**Found while doing it:** the legacy Edit Profile wrote the bio to RTDB `users/{uid}/profileBio`, a
key nothing decodes (`Users` reads `bio`). Legacy bio edits never showed anywhere. That screen still
exists on the coach tab bar and still writes the dead key. `onEditAccount` ignores it.

**Cloud**
- `onEditAccount` (v1, `Users/{uid}` updated, beside `onCreateAccount`) copies `displayName` and
  `bio` to RTDB `users/{uid}`, only when they changed, and only those keys. It mirrors the after
  state outright, so redelivery is harmless. 4 tests. The test closes its RTDB connection, or Jest
  never exits.
- `syncProfile` (step 2) already re-projects `Profiles/{uid}` on the same write.

**App**
- An "Edit Profile" button on your own header opens `EditProfileScreen` **modally** with Cancel /
  Done. Being modal is what makes "leave without Done" read as discarding.
- **Done saves everything and Cancel discards everything, the photo included.** The photo goes
  first; if it fails, nothing else is written. If the photo succeeds and the text fails, the photo
  is remembered, so the retry writes only the text, and the profile behind reloads either way.
  Done with no changes just closes. No swipe-to-dismiss with unsaved edits or mid-save.
- Limits are signup's: display name 1–100, bio ≤ 300, extra characters refused as signup does.
  Text is trimmed before saving. `ProfileDetails` holds the limits.
- Writers, one destination each:
  - `FirestoreProfileDetailsWriter` → `Users/{uid}`, via `updateData` of exactly the two keys.
  - `CurrentUserProfileDetailsWriter` → the cached `UserDefaults.currentUser`.
  - `RemoteAndCurrentUserProfileDetailsWriter(remote:currentUser:)` composes them, remote first,
    so the cache never shows an edit the server did not take.
- Photo:
  - `StorageProfilePhotoUploader` → `ProfilePhotos/{uid}`, scaled to 720pt and compressed to fit
    `downloadImage`'s 720×720-byte cap. A bigger photo would upload and then never load.
  - `CachingProfilePhotoUploader(wrapping:)` then puts it in `ImageCache` (new
    `store(_:for:)`), so every screen shows the new photo at once.
- Not refreshed until relaunch: DISCOVER's session cache of author names
  (`CachingUserProfileLoader`). Acceptable, since only your own name is affected.
- Tests: 13 new (`EditProfileViewModelTests`, plus `editProfile` on `MyProfileViewModelTests`),
  33 in ProfileKit.

**Rules** (console)
- Add an update rule to `Users/{userId}`. It must be the **only** client write allowed there, since
  it is what stops a client from setting its own `verifiedAccount` / `eliteAccount`. Nothing else
  in the app writes `Users/{uid}` today (signup goes through `createAccount`).

  ```
  allow update: if request.auth != null && request.auth.uid == userId
    && request.resource.data.diff(resource.data).affectedKeys().hasOnly(["displayName", "bio"])
    && request.resource.data.displayName is string
    && request.resource.data.displayName.size() > 0
    && request.resource.data.displayName.size() <= 100
    && request.resource.data.bio is string
    && request.resource.data.bio.size() <= 300;
  ```

  Later steps widen `hasOnly`: step 4 (body measurements), step 6 (`isPrivate`) and step 8
  (`pinnedHighlights`).
- Storage: `ProfilePhotos/{uid}` must allow the owner to **overwrite**, not only create. Signup only
  ever created.

### Step 4 — Body measurements and the weight log — built, not rolled out

**Changed from the plan, three ways:**
- **Signup already persists the measurements.** The functions' `createAccount` has written
  `heightCentimetres` / `weightKilograms` / `heightUnit` / `weightUnit` / `dateOfBirth` to
  `Users/{uid}` since 10 August, and seeds `Users/{uid}/WeightTracking/{yyyy-MM-dd}`. The plan's
  "createAccount drops them" was out of date (and so was `CLAUDE.md`, now corrected). The log
  therefore uses the existing **`WeightTracking`** collection, not a new `BodyWeight`.
- **Body Measurements is its own screen**, Settings → Account, captioned "Only you can see these",
  rather than a card on Edit Profile. Edit Profile edits what other people see, and putting weight
  there would make people wonder whether it shows.
- **The latest weight on `Users/{uid}` is kept by the server.** `createAccount` calls
  `Users.weightKilograms` "the latest known weight", and the first log would have made it stale.
  `syncLatestWeight` re-derives it from the newest entry on every write, rather than the app writing
  both the entry and the user document.

**Cloud**
- `syncLatestWeight` (v2, `Users/{uid}/WeightTracking/{id}` written) copies the newest entry by
  `date` to `Users.weightKilograms` (and `weightUnit` when the entry has one), in a transaction.
  - Deleting the newest entry falls back to the previous one.
  - Deleting the last entry removes `weightKilograms` but keeps the unit preference.
  - It writes nothing unchanged and never recreates a deleted user.
  - 5 tests.

**App**
- **Height and date of birth** use the signup rows and wheels, copied into ProfileKit
  (`BodyMeasurementRow`, `HeightPickerSheet`, `DateOfBirthSheet`, `ProfilePickerSheet`). They save
  **when the sheet closes**, and only if changed. A failure puts the screen back to the server's
  value with a banner. Clear deletes the field.
- **Weight:**
  - The screen shows the latest reading, a hand-built **line** over time (x-axis is time, not
    entry index), and the history; long-press an entry to delete it.
  - "Log Weight" opens a whole + tenths wheel on the last reading. Kilograms or pounds, converted
    on switch, stored as kilograms to one decimal, which signup's whole numbers do not need.
  - One entry per **UTC** day (`WeightDay`, matching the server's `dateKey()` and StatsKit's
    `StatsDay`), so logging again the same day replaces the entry.
  - Logs and deletes show at once and are put back if the write fails.
- Adapters, one destination each:
  - `FirestoreBodyMeasurementsLoader` reads the user's own `Users/{uid}` by hand, since the app's
    `Users` model has no body fields.
  - `FirestoreBodyMeasurementsWriter` uses `updateData` of the three keys, with
    `FieldValue.delete()` for a cleared one.
  - `FirestoreWeightLogLoader` decodes per document and skips bad entries.
  - `FirestoreWeightEntryWriter` writes `createAccount`'s entry shape.
  - `FirestoreWeightEntryRemover`.
  - `WeightTrackingPath` is the one definition of the collection.
- Remote-only reads: a failed load is "Couldn't Load Measurements" with Try Again, never an empty
  log. No local cache, since this is a settings screen opened occasionally.
- Tests: 17 new (`BodyMeasurementsViewModelTests`, `WeightDayTests`, `ProfileWeightUnitTests`),
  50 in ProfileKit.
- **Still not here:** feeding the latest weight into `% of BW` prescriptions. `Users.weightKilograms`
  is now the number to read for that.

**Rules** (console)
- Widen step 3's `Users/{userId}` update rule. The full rule:

  ```
  allow update: if request.auth != null && request.auth.uid == userId
    && request.resource.data.diff(resource.data).affectedKeys()
         .hasOnly(["displayName", "bio", "heightCentimetres", "heightUnit", "dateOfBirth"])
    && request.resource.data.displayName is string
    && request.resource.data.displayName.size() > 0
    && request.resource.data.displayName.size() <= 100
    && request.resource.data.bio is string
    && request.resource.data.bio.size() <= 300
    && (!("heightCentimetres" in request.resource.data)
         || (request.resource.data.heightCentimetres is number
             && request.resource.data.heightCentimetres >= 50
             && request.resource.data.heightCentimetres <= 300))
    && (!("heightUnit" in request.resource.data)
         || request.resource.data.heightUnit in ["centimetres", "feetInches"])
    && (!("dateOfBirth" in request.resource.data)
         || request.resource.data.dateOfBirth is timestamp);
  ```

  `weightKilograms` and `weightUnit` are deliberately absent. Only `syncLatestWeight` (Admin SDK)
  writes them.
- Add `WeightTracking`:

  ```
  match /Users/{userId}/WeightTracking/{entryId} {
    allow read, delete: if request.auth != null && request.auth.uid == userId;
    allow create, update: if request.auth != null && request.auth.uid == userId
      && request.resource.data.id == entryId
      && request.resource.data.date is timestamp
      && request.resource.data.weightKilograms is number
      && request.resource.data.weightKilograms >= 20
      && request.resource.data.weightKilograms <= 400
      && (!("weightUnit" in request.resource.data)
           || request.resource.data.weightUnit in ["kilograms", "pounds"]);
  }
  ```

- No new index: a single-field `orderBy("date")` uses the automatic one.

### Step 5 — Follows — built, not rolled out

**Cloud**
- `profileFollowCounts` (v2, `Follows/{id}` written) recounts **active** follows into
  `Profiles.followerCount` / `followingCount` for both people, through DISCOVER's `syncCount`: a
  recount, nothing written for a missing profile or an unchanged count. The users come from both
  snapshots' fields, since a create names them only after and a delete only before.
- `rebuildProfiles` now recounts follows on every profile it writes, so a rebuild is a full repair
  and the rollout backfill counts follows that predate the trigger.
- **Legacy bridge, one way:** `mirrorLegacyFollow` / `mirrorLegacyUnfollow` (v1, RTDB
  `Following/{a}/{b}`).
  - The old Follow button (`ProfileInfoCellViewModel`) still writes RTDB, so its follows are
    carried into `Follows`.
  - Each is `pending` if the followee is private, and never overwrites an existing follow.
  - ProfileKit's follows are **not** written back to RTDB. The legacy NEWSFEED is the only RTDB
    reader left, and a two-way mirror is a loop.
  - This resolves open question 7. Retire it when step 7 removes the legacy Follow button.
- `FollowPaths.ts`: the `Follows/{followerId}_{followeeId}` id, matched by the app's `FollowPath`
  and the rules.
- Tests: 11 new, 27 in `test/Profile`. The new tests give their users `Users` documents, because
  `rebuildProfiles`' test runs in parallel against the same emulator and deletes orphan profiles.

**Scripts**
- `MigrateFollows.py`: dry run by default, `--write` to create. It reads RTDB `Following`, creates
  missing `Follows` documents as `active`, never overwrites, and skips self-follows and malformed
  ids. Run it after `profileFollowCounts` is deployed, or follow it with `RebuildProfiles.py`.
- `Emulator/SeedDiscover.py` seeds 10 follows. `demo` follows 3 accounts and is followed by 4.

**App**
- The profile header shows **"N Followers · M Following"** once the `Profiles` document exists
  (absent, not zero, before). Each half opens its list. Counts refresh whenever the tab reappears,
  and lag a follow by the trigger's few seconds.
- `FollowListScreen`:
  - Paged newest first, 30 at a time, resumed after `(createdAt, documentId)`, since migrated
    follows share one timestamp.
  - Every row has a follow button: Follow / Follow back / Following / Requested.
  - **Unfollowing keeps the row** so a mis-tap is undone in place. **Removing a follower** (own
    followers list only) asks first and takes the row away.
  - Every action shows at once and is put back on failure. A follow shows the status the writer
    returns, which may be `Requested`.
  - Rows are not tappable yet. Opening a profile is step 7.
- Adapters, one destination each:
  - `FirestoreProfileCountsLoader`, `FirestoreFollowListLoader`, `FirestoreProfileSummaryLoader`.
  - `FirestoreFollowStatusLoader` uses parallel `get`s of `Follows/{me}_{them}`, not a query; see
    the rules.
  - `FirestoreFollowWriter` is create-only in a transaction. It returns an existing follow's
    status unchanged, and otherwise picks `pending` / `active` from `Profiles.isPrivate` the way
    the rule demands.
  - `FirestoreUnfollower` and `FirestoreFollowerRemover`.
- **`ProfileNamesReader`** is the one batched `Profiles` name query. DISCOVER's
  `FirestoreUserProfileLoader` now uses it too, instead of its own copy.
- Tests: 17 new (`FollowListViewModelTests`, counts on `MyProfileViewModelTests`), 67 in ProfileKit.

**Rules** (console):

```
match /Follows/{followId} {
  // Either person named in the id may read it, even when it does not exist
  // yet — that is how the app asks "do I follow them?". Anyone signed in may
  // read an active follow (follower lists).
  allow get: if request.auth != null
    && (followId.split("_")[0] == request.auth.uid
        || followId.split("_")[1] == request.auth.uid
        || resource.data.status == "active");
  allow list: if request.auth != null
    && (resource.data.status == "active"
        || resource.data.followerId == request.auth.uid
        || resource.data.followeeId == request.auth.uid);
  allow create: if request.auth != null
    && request.resource.data.followerId == request.auth.uid
    && request.resource.data.followeeId != request.auth.uid
    && followId == request.resource.data.followerId + "_" + request.resource.data.followeeId
    && request.resource.data.keys().hasOnly(["followerId", "followeeId", "status", "createdAt"])
    && request.resource.data.createdAt == request.time
    && request.resource.data.status ==
         (get(/databases/$(database)/documents/Profiles/$(request.resource.data.followeeId))
            .data.get("isPrivate", false) ? "pending" : "active");
  allow delete: if request.auth != null
    && (resource.data.followerId == request.auth.uid
        || resource.data.followeeId == request.auth.uid);
  // update (approving a request) arrives in step 6
}
```

The create rule reads the followee's `Profiles` document, so **a follow of someone with no profile
is denied**. That is one more reason the step 2 backfill comes first.

**Indexes** (console): composite on `Follows`
- `followeeId` ASC, `status` ASC, `createdAt` DESC
- `followerId` ASC, `status` ASC, `createdAt` DESC

### Step 6 — Private accounts and requests

**Cloud**
- `isPrivate` flows into `Profiles` through `syncProfile`.
- `approvePendingFollows`: when `isPrivate` goes true → false, set every pending follow to `active`.

**App**
- Private toggle in Settings, saying plainly what it does and that existing followers stay.
- Requests inbox (approve / decline), reached from the header when there are pending requests.
- The profile screen hides highlights and clips from non-followers of a private account, with a
  "This account is private" card.

**Open:** push notifications for new followers and requests. Messaging is in the stack, but the
interview did not cover it.

### Step 7 — Other users' profiles: DISCOVER, lists, search

**App**
- The same profile screen for any `userId`, with owner-only controls hidden.
- **DISCOVER → profile:** DiscoverKit declares a `UserProfileOpener` protocol (it imports no other
  framework). The composition root answers it by building ProfileKit's screen and pushing it onto
  DISCOVER's navigation controller. Wire it to workout authors, clip owners and comment authors.
- Followers / following rows open profiles.
- User search screen (from the profile header; **open:** also from DISCOVER?): prefix query on
  `Profiles.usernameLower` and `.displayNameLower`, debounced like the username availability check.
- **Replace every `UserProfileCoordinator` entry point** (NEWSFEED, comment sections, tagged users)
  with ProfileKit's screen, so there is one profile and one follow button.

**Console:** indexes for the two search fields if the composite queries need them.

### Step 8 — Highlights (PBs) and clips

**Cloud**
- `syncProfileHighlights`: on `Users/{uid}/ExerciseStats/{exerciseId}` write, copy `maxWeight` /
  `maxTime` for the user's highlighted exercises into `Profiles.highlights`. Others never read
  `ExerciseStats` directly.
- `clipCount` added to the profile recount.

**App**
- Highlights section: up to N tiles (exercise name, best weight in kg rendered in the viewer's unit,
  or best time). Owner can choose which exercises are pinned (`pinnedHighlights`).
- Clips grid from the user's Firestore `Clips` (`userID`), visible ones only. Tapping a clip opens
  the existing clip player route. Like counts come from `DiscoverClips` where the clip has a card.

**Open:** what fills highlights before the user pins anything. Recommended: their three
most-trained exercises by `setCount`, a weighted best for loaded and a time best for timed.

### Step 9 — Report and block on profiles

**App + Cloud**
- A profile carries user-generated text and a photo, so it falls under Apple guideline 1.2 like
  DISCOVER's comments. Add a **profile report target** to `DiscoverReportTarget` /
  `ReportTarget.ts` (fixed reasons, the same 3-reporters-or-1-admin hide, where hiding blanks the bio
  and photo on `Profiles`). Add **Block** to another user's profile menu, writing the existing
  `BlockedUsers`.
- `removeFollowsOnBlock` Cloud Function.
- **Must ship with step 7**, the first moment a stranger's profile is reachable.

### Step 10 — Account deletion

**Cloud**
- `deleteAccount` callable: Firestore `Users/{uid}` and every subcollection (MyDay, ExerciseStats +
  RawLogs, WorkoutSessions, WorkoutTemplates, WeightTracking, BlockedUsers), the analytics
  `WorkoutSessions` copies, top-level `WorkoutTemplates` the user authored, `Usernames/{username}`,
  `Profiles/{uid}`, every `Follows` document either side, `Clips` + Storage (`TestClips`,
  `TestClipThumbnails`, `ProfilePhotos`), **`deleteDiscoverData(uid)`** (built, DISCOVER step 8),
  RTDB `users/{uid}` and the legacy graph, then the Auth user last. Idempotent, so a second run
  finds nothing, with a test that proves it.

**App**
- Settings → Delete Account: what goes, password re-entry as confirmation, then the callable.
- Then **clear the local stores** for that uid (`Documents/MyDays/{uid}`,
  `Documents/WorkoutTemplates/{uid}`, `Documents/PendingSync/*_{uid}.json`). This is the one case
  where wiping is right, unlike sign-out, where scoping is. Then sign out to the welcome screen.

### Step 11 — Tests and documentation

- `ProfileKitTests` in the StatsKit / DiscoverKit style: follow-state view model, privacy gating,
  highlight formatting, weight-log unit conversion, search debounce. Cloud tests for every function,
  including recounts on redelivery.
- `CLAUDE.md`: a PROFILE section, the Firestore table rows, the five-framework lists becoming six,
  and the *keep in step* index (ProfileKit's `Color+Extension.swift`, its copies of the
  account-creation sheets).

---

## Rollout checklist

Built from the steps above as each one lands, in step order, **the same discipline as DISCOVER**:
rules and indexes are console work, so a merged branch is not a working feature. The order that
matters most:

**Step 2 — `Profiles`**
- [ ] Deploy `syncProfile` and `rebuildProfiles` from the functions `profile` branch
- [ ] Console rules: add `Profiles/{userId}` (read: signed in; write: none)
- [ ] `python RebuildProfiles.py findlaywood1@gmail.com`, then spot-check a few `Profiles` documents
- [ ] Ship an app build whose DISCOVER reads `Profiles` (this branch)
- [ ] Console rules: close `Users/{userId}` to `get` by its owner, no `list`. **Last**, and only
      once no build in use still reads other users' `Users` documents. DISCOVER has not shipped,
      so that is any build from this branch onward.

**Step 3 — Edit profile**
- [ ] Deploy `onEditAccount` from the functions `profile` branch
- [ ] Console rules: the `Users/{userId}` update rule above, then check that no other client write
      to `Users` is still relied on
- [ ] Storage rules: the owner may overwrite `ProfilePhotos/{uid}`

**Step 4 — Body measurements**
- [ ] Deploy `syncLatestWeight` from the functions `profile` branch
- [ ] Console rules: the widened `Users/{userId}` update rule, and `WeightTracking`
- [ ] Confirm the deployed `createAccount` is the 10 August version that persists the body keys

**Step 5 — Follows**
- [ ] Deploy `profileFollowCounts`, `mirrorLegacyFollow`, `mirrorLegacyUnfollow` and the updated
      `rebuildProfiles` from the functions `profile` branch
- [ ] Console rules: `Follows`
- [ ] Console indexes: the two `Follows` composites (wait for them to finish building)
- [ ] `python MigrateFollows.py`, check the counts, then `python MigrateFollows.py --write`
- [ ] `python RebuildProfiles.py findlaywood1@gmail.com`, to recount every profile once

**Later steps** (expanded as they land)
- [ ] `Follows` rules + indexes **before** `MigrateFollows.py --write`
- [ ] Profile reporting and blocking (step 9) live **before** other users' profiles (step 7) reach
      real users
- [ ] `deleteAccount` deployed **before** the Delete Account button ships

---

## Open questions

1. **Performance Center, Jump measuring, Breathwork — entry points.** Their code stays (Performance
   Center explicitly). Their only door today is the "More" menu this plan replaces. Recommended: a
   temporary "Tools" row in Settings that calls back to the app, until each gets its own roadmap
   task. The alternative is that they are unreachable until then.
2. **What a private account hides.** Recommended above: header public, highlights and clips
   followers-only. Do a private user's clips also leave DISCOVER?
3. **Premium stamp for other users.** Premium is known only on-device (RevenueCat), so another
   user's profile cannot show it truthfully. Recommended: own profile only, until entitlements are
   server-verified (see *Future Ideas* → coach passes).
4. **Default highlights** before anything is pinned (step 8).
5. **Follow notifications** (step 6).
6. **Search from DISCOVER as well as the profile?** (step 7).
7. **Legacy RTDB follows during the gap** between migration and step 7 (step 5).
8. **Legacy profile files.** Delete `MyProfile/`, `PlayerProfileMore/` and friends once the coach tab
   bar no longer needs them, **never Performance Center's**. That probably belongs with the
   coach/player split removal.

## Out of scope

- Posts, and the NEWSFEED question.
- Workout history.
- Public workouts on the profile (DISCOVER lists them).
- Username changes.
- The coach tab bar and the coach/player split.
- Performance Center's redesign.
- Feeding the weight log into `% of BW` prescriptions.
