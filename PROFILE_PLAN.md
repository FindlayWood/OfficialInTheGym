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
  - Rows open the person's profile from step 7.
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

### Step 6 — Private accounts and requests — built, not rolled out

**Cloud**
- `profileProjection` adds `isPrivate`, true only for a literal `true`. It is what the `Follows`
  create rule and `FirestoreFollowWriter` read to choose `pending` or `active`. (`createAccount`
  already writes `isPrivate: false` at signup.)
- `approvePendingFollows` (v2, `Users/{uid}` updated, `isPrivate` true → false) sets every pending
  follow of the user to `active` with `approvedAt`, 500 per batch. It re-reads the user before each
  page, so flipping back to private mid-run stops it. Going private changes nothing; existing
  followers stay. Each approval fires `profileFollowCounts`.
- Tests: 5 new, 32 in `test/Profile`.

**App**
- **Private Account switch** in Settings → Account, with a footer that says what it does in each
  state. It is disabled until the setting loads (never a guessed "off"), shows a spinner while
  saving, and is put back on failure. **Turning it off asks first**: "any follow requests waiting
  will be approved".
- **Requests surface on the profile**, as a "N follow requests" row under the header, shown only
  while any are waiting. A private account's inbox has no other door, so it sits where the owner
  looks first. The count refreshes with the follow counts whenever the tab reappears.
- `FollowRequestsScreen`: paged newest first, with Approve (filled) and Decline (tinted).
  **Approving keeps the row as "Approved"; declining removes it.** Neither asks first. Both show at
  once and are put back on failure.
- Declining is `FollowerRemover`, the same delete of their follow document. There is no second
  protocol for it.
- Adapters:
  - `FirestorePrivateAccountLoader` / `Writer` read and write `Users.isPrivate`.
  - `FirestoreFollowRequestsLoader` and `FirestoreFollowRequestCountLoader` (a server count
    query).
  - `FirestoreFollowRequestApprover` uses `updateData` of `status` and `approvedAt`.
  - **`FollowsPageQuery`** is the one paged `Follows` query, shared by the follow lists (active)
    and the inbox (pending). `FirestoreFollowListLoader` now uses it.
- Tests: 14 new (`FollowRequestsViewModelTests`, privacy on `ProfileSettingsViewModelTests`, the
  request count on `MyProfileViewModelTests`), 81 in ProfileKit.

**Deferred to step 7** (it needs other people's profiles to exist):
- The "This account is private" card.
- Hiding a private account's highlights, clips and follow lists from non-followers. The `Follows`
  list rule currently lets anyone list any account's active follows.

**Rules** (console)
- `Users/{userId}` update: add `isPrivate` to `hasOnly`, plus
  `&& (!("isPrivate" in request.resource.data) || request.resource.data.isPrivate is bool)`.
  The full `hasOnly` list is now
  `["displayName", "bio", "heightCentimetres", "heightUnit", "dateOfBirth", "isPrivate"]`.
- `Follows` gains an update rule, for approval by the followee only:

  ```
  allow update: if request.auth != null
    && resource.data.followeeId == request.auth.uid
    && resource.data.status == "pending"
    && request.resource.data.status == "active"
    && request.resource.data.diff(resource.data).affectedKeys().hasOnly(["status", "approvedAt"])
    && request.resource.data.approvedAt == request.time;
  ```

- No new index. The inbox runs on step 5's `(followeeId, status, createdAt desc)`.

### Step 7 — Other users' profiles: DISCOVER, lists, search — built, not rolled out

**Do not ship this to users before step 9.** A stranger's profile, with its bio and photo, can now
be reached from DISCOVER, search and every legacy screen, and Apple guideline 1.2 requires a way to
report and block it.

**App, ProfileKit**
- `UserProfileScreen` is someone else's profile. It uses the same header card, read from
  `Profiles/{uid}` (`PublicProfileLoader`), and is titled `@username`.
  - A full-width **Follow / Request to Follow / Requested / Following** button.
  - Unfollowing a **private** account asks first, since following again means a new request.
  - Follow and unfollow move the follower count at once, so the button and the number agree before
    the server's recount. A request moves no count.
  - Never shows the premium crown (open question 3: own profile only).
- **Private accounts:** header and counts are public. Lists are for approved followers only
  (`canSeeLists`), so for anyone else the counts render as plain text and a "This account is
  private" card explains why, with different wording while a request is waiting.
- Opened on your own id (your name in someone's list), it shows your public profile, with no Follow
  button.
- A missing profile shows "This account isn't available", not an error to retry.
- **Search** opens from a magnifier on the profile title bar (`UserSearchScreen`).
  - Prefix match on `usernameLower` and `displayNameLower`, username matches first.
  - Debounced 300 ms; every keystroke cancels the search before it, and results for a query no
    longer in the field are dropped. "@" and case are ignored.
  - Results open the profile. Following is decided on the profile, not from a match.
- **Follow and request rows are tappable**: name and photo open the profile, while the buttons keep
  their own taps.
- `ProfileKitRouter.showUserProfile(_:)` is the public entry point. It pushes onto the router's own
  stack without `start()`, so another tab keeps its root.

**App, DISCOVER**
- DiscoverKit declares **`UserProfileOpener`** (it imports no other framework) and takes it,
  optionally, on its router. Three places open profiles:
  - the workout page's "by Author" line, which becomes a button with a chevron;
  - "View profile" in the clip player's menu;
  - comment avatars and names.
- Your own content, a deleted author or no opener all leave plain text.
- `ProfileKitUserProfileOpener` answers it with a ProfileKit router built on DISCOVER's navigation
  controller, so profiles open inside the DISCOVER tab and back returns to the workout, clip or
  thread.

**App, legacy**
- **`UserProfileCoordinator.start()` now pushes ProfileKit's profile** instead of
  `PublicTimelineViewController`.
  - All nine legacy callers (NEWSFEED, comment sections, tagged users, old follower lists) go
    through it, so one change moves all of them to the one profile and the one Firestore follow
    button.
  - The legacy RTDB Follow button is now unreachable, so `mirrorLegacyFollow` has nothing left to
    bridge. Retire it once the old app versions in use no longer matter.
  - The coordinator's other flow methods are dead and left for a cleanup pass.
- `ProfileKitComposition.makeRouter` builds the one dependency graph for every entry point: the
  tab, DISCOVER and the legacy coordinator. `DiscoverKitComposition` now takes `purchaseManager`,
  because a ProfileKit router needs it.

**Adapters:** `FirestorePublicProfileLoader` and `FirestoreUserSearchLoader` (two single-field
range queries in parallel, so no composite index).

**Tests:** 18 new (`UserProfileViewModelTests`, `UserSearchViewModelTests`), 99 in ProfileKit.
DiscoverKit's suite still passes.

**Not here:**
- Hiding search results and profiles that moderation has hidden (`Profiles.status`), which is
  step 9.
- Whether a private user's clips leave DISCOVER (open question 2), which belongs with step 8's
  clips section.

**Rules** (console). Tighten the `Follows` **list** rule from step 5, so a private account's lists
are readable only by its approved followers (and its owner). The client hides them already; this
makes the server agree.

```
function canSeeListsOf(uid) {
  return uid == request.auth.uid
    || !get(/databases/$(database)/documents/Profiles/$(uid)).data.get("isPrivate", false)
    || (exists(/databases/$(database)/documents/Follows/$(request.auth.uid + "_" + uid))
        && get(/databases/$(database)/documents/Follows/$(request.auth.uid + "_" + uid))
             .data.status == "active");
}

allow list: if request.auth != null
  && (resource.data.followerId == request.auth.uid
      || resource.data.followeeId == request.auth.uid
      || (resource.data.status == "active"
          && (canSeeListsOf(resource.data.followeeId)
              || canSeeListsOf(resource.data.followerId))));
```

A list query constrains one of `followeeId` / `followerId` with `==`. The rule is evaluated for that
side, and the `||` with the unconstrained side is how one rule covers both lists. Test both lists,
for a public account and a private one, in the Rules Playground before publishing.

### Step 8 — Highlights (PBs) and clips — built, not rolled out

**Decided at the start of the step** (2026-10-04):
- **Highlights are automatic until pinned.** They are your three most-trained exercises (by
  `setCount`) until you pin up to three of your own. This settles open question 4.
- **A private account's public clips stay in DISCOVER.** A clip's own `isPrivate` already decides
  that. This settles open question 2.
- **The profile grid shows public clips only, for everyone**, your own profile included.

**Changed from the plan:** highlights live in **`ProfileHighlights/{uid}`**, not on `Profiles`.
`Profiles` is readable by every signed-in user, and a private account's PBs are for followers. A
separate document lets the rules gate it with the same check as the follow lists, so the server
enforces the privacy rather than only the app hiding it.

**Cloud**
- `syncProfileHighlights` rebuilds `ProfileHighlights/{uid}` (`highlights`, `isPinned`) from
  current state in a transaction.
  - It uses the pinned ids in order (skipping any with no stats), or else the top three
    `ExerciseStats` by `setCount`.
  - Each highlight is `exerciseId`, `exerciseName`, `maxWeight` (kg), `maxTime` (s) and
    `isTimeBased` (StatsKit's rule).
  - A deleted user deletes the document. Unchanged content is not written: the comparison is
    independent of field order, since Firestore reads keys back in its own order.
- It has two triggers:
  - `profileHighlightsFromStats`, on `Users/{uid}/ExerciseStats/{id}`, so a new best or a change in
    ranking updates the tiles.
  - `profileHighlightsFromPins`, on `Users/{uid}`, which runs only when `pinnedHighlights` changes
    or the user is created or deleted, so a bio edit does not rebuild highlights.
- `profileClipCount` (on `DiscoverClips/{id}`) recounts `Profiles.clipCount`: the owner's public,
  visible clips, exactly the grid's set, via `syncCount`.
- `rebuildProfiles` also recounts clips and rebuilds every user's highlights.
- Tests: 7 new, 39 in `test/Profile`.

**App**
- **Highlights section** on both profiles: up to three equal tiles, each a best (kg, or `2m 30s`
  for timed work) over the exercise name. It is titled "Top Lifts" when automatic and "Highlights"
  when pinned.
  - On your own profile it carries **Edit**, and when empty says how it fills. On someone else's,
    an empty section is not drawn.
  - A private account you do not follow shows none: the screen does not even ask, since the rules
    would deny it.
- **Edit Highlights** is presented modally with Cancel / Save.
  - An Automatic row, then every logged exercise with its best, numbered 1–3 in the order picked.
    A fourth pick is refused, not swapped in.
  - Pins whose stats are gone are dropped on load.
  - Save shows the result on the profile **at once**, worked out from the candidates on screen,
    since the server's rebuild lags.
- **Clips grid** on both profiles: three columns of portrait thumbnails (`AsyncImage`) with
  durations, the newest 12, from the owner's public, visible `DiscoverClips` cards. The header
  shows `clipCount`.
  - **Tapping a clip opens DISCOVER's clip player**, with likes, comments and report.
    `ProfileKitRouter.onOpenClip` is answered by `DiscoverClipOpener`, which builds a DiscoverKit
    router on the profile's stack **lazily**: building eagerly would recurse, since each
    composition builds the other's router.
  - DiscoverKit gained `DiscoverKitRouter.showClip(_:)` and `DiscoverKitComposition.makeRouter`.
  - `ProfileClip` carries every card field, so no second read is needed.
- Your own profile now reads its counts from the same `PublicProfileLoader` as other profiles.
  **`ProfileCountsLoader` and `FirestoreProfileCountsLoader` were removed**, which also gives the
  clip count.
- Adapters:
  - `FirestoreProfileHighlightsLoader` and `FirestoreHighlightCandidatesLoader`, both reading
    through **`ProfileHighlight(highlightData:)`**, the one parser of the highlight shape.
  - `FirestorePinnedHighlightsWriter`, where an empty list deletes the field.
  - `FirestoreProfileClipsLoader`.
- Weights show in kilograms. There is no app-wide unit preference to read yet.
- Tests: 16 new (`EditHighlightsViewModelTests`, `ProfileHighlightTests`, highlights and clips on
  both profile view models), 115 in ProfileKit. DiscoverKit's suite still passes.

**Rules** (console)
- `ProfileHighlights` (`canSeeListsOf` is step 7's function, shared):

  ```
  match /ProfileHighlights/{userId} {
    allow read: if request.auth != null && canSeeListsOf(userId);
    allow write: if false;
  }
  ```

- `Users/{userId}` update: add `"pinnedHighlights"` to `hasOnly`, plus
  `&& (!("pinnedHighlights" in request.resource.data) || (request.resource.data.pinnedHighlights is list && request.resource.data.pinnedHighlights.size() <= 3))`.

**Indexes** (console): composite on `DiscoverClips`: `createdBy` ASC, `isPublic` ASC, `status` ASC,
`uploadedAt` DESC.

### Step 9 — Report and block on profiles — built, not rolled out

**This is the step step 7 waits for.** Once it is rolled out, steps 7–9 can reach users together.

**Cloud**
- `reportTarget` (DISCOVER's moderation) accepts a new kind, **`"profile"`**, at `Profiles/{uid}`.
  Its `moderatedPath` is the projection itself, so DISCOVER's `discoverReportFiled` →
  `moderateTarget` hides a profile at **3 distinct reporters or 1 admin**, with no new function.
  - It sets `Profiles.status = "hidden"`, never touching `Users/{uid}`. `syncProfile` leaves
    `status` alone, so the profile stays hidden through later edits.
  - It is queued in `ModerationQueue` for the admin app like any report.
- `removeFollowsOnBlock` (on `Users/{uid}/BlockedUsers/{id}` created) deletes the follows **both
  ways**, pending requests included. It fires whether the block came from DISCOVER or a profile.
  Unblocking restores nothing.
- Tests: 6 new (profile report target, three reporters hiding a profile, the block trigger).

**App**
- A **⋯ menu** on someone else's profile, with Report Profile and Block / Unblock.
  - **Report** opens a sheet with the fixed reason list (`ProfileReportReason`, ProfileKit's copy
    of `DiscoverReportReason`; the raw values are the rules' list), then thanks the user and
    suggests blocking. It makes no promise of an outcome.
  - **Block** asks first, saying what it does ("you'll stop following each other… hidden in
    Discover… they won't be told").
- **Blocked:** the follow button and the content go, a "You've blocked this account" card offers
  Unblock, and the follow status and count drop at once to match the server's cut. All of it is put
  back if the write fails.
- **Hidden profiles:** others see "This account isn't available", as for a deleted one. Search drops
  them, after the query, rather than adding a composite index per field. The **owner** still sees
  their profile, with a notice: "Your profile is hidden… contact us from Settings".
- Adapters:
  - `FirestoreProfileReporter` uses kind `"profile"` and path `Profiles/{uid}`.
  - **`ReportDocumentWriter`** is the one definition of a report document, extracted from
    `FirestoreReportWriter`, which DISCOVER's reports now use too.
  - `BlockedUsersProfileBlocker(wrapping:)` wraps DISCOVER's own `FirestoreBlockedUsersWriter`, so
    there is one block. `FirestoreProfileBlockStatusLoader` reads the user's own `BlockedUsers`.
- **DiscoverKit is unchanged.** ProfileKit declares its own reporter and blocker protocols, and only
  the composition root's adapters are shared.
- Tests: 6 new on `UserProfileViewModelTests`, 121 in ProfileKit.

**What a block does not do, deliberately:** hide the blocker's public header from the person they
blocked. Whether someone has blocked you lives in their private `BlockedUsers`, and `Profiles` is
one document for every reader, so the server cannot vary it per viewer. Instead, the rules refuse
any follow or request between the two while the block stands, and the gated content (lists,
highlights) needs an approved follow, which the block removed.

**Rules** (console)
- `Reports` create: add `'profile'` to the accepted `targetKind` list
  (`['comment', 'workout', 'clip', 'tag', 'profile']`).
- `Follows` create: add both block checks:

  ```
  && !exists(/databases/$(database)/documents/Users/$(request.resource.data.followeeId)/BlockedUsers/$(request.auth.uid))
  && !exists(/databases/$(database)/documents/Users/$(request.auth.uid)/BlockedUsers/$(request.resource.data.followeeId))
  ```

### Step 10 — Account deletion

**Cloud**
- `deleteAccount` callable: Firestore `Users/{uid}` and every subcollection (MyDay, ExerciseStats +
  RawLogs, WorkoutSessions, WorkoutTemplates, WeightTracking, BlockedUsers), the analytics
  `WorkoutSessions` copies, top-level `WorkoutTemplates` the user authored, `Usernames/{username}`,
  `Profiles/{uid}`, `ProfileHighlights/{uid}`, every `Follows` document either side, `Clips` + Storage (`TestClips`,
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

**Step 6 — Private accounts and requests**
- [ ] Deploy `approvePendingFollows` and the updated `syncProfile` from the functions `profile`
      branch
- [ ] `python RebuildProfiles.py findlaywood1@gmail.com`, so every profile carries `isPrivate`
- [ ] Console rules: `isPrivate` in the `Users` update rule, and the `Follows` update rule

**Step 7 — Other users' profiles**
- [ ] **Step 9 is live first.** Do not ship a build with step 7 to users until profile reporting
      and blocking are in it.
- [ ] Console rules: the tightened `Follows` list rule, tested in the Rules Playground for both
      lists, public and private

**Step 8 — Highlights and clips**
- [ ] Deploy `profileHighlightsFromStats`, `profileHighlightsFromPins`, `profileClipCount` and the
      updated `rebuildProfiles` from the functions `profile` branch
- [ ] Console index: the `DiscoverClips` composite (wait for it to build)
- [ ] Console rules: `ProfileHighlights`, and `pinnedHighlights` in the `Users` update rule
- [ ] `python RebuildProfiles.py findlaywood1@gmail.com`, to build every user's highlights and clip
      count

**Step 9 — Report and block**
- [ ] Deploy `removeFollowsOnBlock` and the updated `discoverReportFiled` (new `"profile"` kind) from
      the functions `profile` branch
- [ ] Console rules: `'profile'` in the `Reports` `targetKind` list, and both block checks in the
      `Follows` create rule
- [ ] Then steps 7–9 may ship together

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
2. ~~What a private account hides.~~ **Settled in steps 7–8:** header and counts public; lists and
   highlights followers-only; public clips stay public, in DISCOVER and on the profile.
3. **Premium stamp for other users.** Premium is known only on-device (RevenueCat), so another
   user's profile cannot show it truthfully. Recommended: own profile only, until entitlements are
   server-verified (see *Future Ideas* → coach passes).
4. ~~Default highlights.~~ **Settled in step 8:** the three most-trained until pinned.
5. **Follow notifications** (step 6).
6. **Search from DISCOVER as well as the profile?** (step 7).
7. **Legacy RTDB follows during the gap** between migration and step 7 (step 5).
8. **Legacy profile files.** Delete `MyProfile/`, `PlayerProfileMore/` and friends once the coach tab
   bar no longer needs them, **never Performance Center's**. That probably belongs with the
   coach/player split removal.

## Out of scope

- **Search's long-term home.** Step 7's people search sits on the profile title bar for now. After
  this plan is finished it moves to DISCOVER as a unified people + workouts + exercises search,
  built entirely in DiscoverKit, and ProfileKit's search is deleted. See *Follow-up: unified
  search* in `DISCOVER_PLAN.md`.

- Posts, and the NEWSFEED question.
- Workout history.
- Public workouts on the profile (DISCOVER lists them).
- Username changes.
- The coach tab bar and the coach/player split.
- Performance Center's redesign.
- Feeding the weight log into `% of BW` prescriptions.
