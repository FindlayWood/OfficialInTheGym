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
  BodyWeight/{yyyy-MM-dd}                owner — kilograms, unit, loggedAt. StatsDay key (UTC).
  BlockedUsers/{uid}                     exists (DISCOVER)

Profiles/{uid}                           SERVER — the public projection: everything anyone else reads
  username, displayName, bio, photoURL,
  isPrivate, verified, elite,
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
- **Weight is a log, not a field.** `BodyWeight/{yyyy-MM-dd}` keyed by `StatsDay.key(for:)`, one
  entry per day, the latest wins. `WeightUnit.percentBodyweight` prescriptions need the *current*
  weight, and a number captured once at signup goes quietly wrong. The signup value becomes the first
  entry. Weight is stored canonically in kilograms, as everywhere else.
- **Blocking cuts follows.** Blocking someone deletes `Follows` in both directions (Cloud Function),
  and a blocked user sees an empty profile. This uses DISCOVER's existing `BlockedUsers`.

---

## Steps

### Step 1 — ProfileKit skeleton, own profile, settings

**App**
- Generate `ProfileKit.xcodeproj` from DiscoverKit's project, prefixing its object ids (`P1F`), as
  DiscoverKit was generated from LoginKit. `IPHONEOS_DEPLOYMENT_TARGET = 26.0`, own
  `UI/Color+Extension.swift` (add it to the *keep in step* index), `ProfileKitTests` target,
  **added to `CI_iOS_TestPlan.xctestplan`**, and added to `InTheGym.xcworkspace`.
- `ProfileKitRouter` following *Architecture*: `ProfileRoutes` enum (`.myProfile`, `.settings`,
  `.editProfile`, …), `public init` taking every dependency, `public func start()`.
- `ProfileComposition` in `InTheGym/Launch/Composition/ProfileKit/`. **Replace
  `MyProfileCoordinator` on the player tab bar only.** `CoachInitialViewController` and
  `TabBarCoordinator` keep the legacy coordinator.
- Own-profile header from the signed-in user's `Users/{uid}` and profile photo: name, @username,
  bio, stamps. Follower counts are placeholders until step 5.
- Settings screen: subscription (status, manage via the App Store, restore, all through
  `PurchaseManager` injected behind a ProfileKit protocol), reset password, log out, contact,
  version, about. Log out calls back to the app. ProfileKit never imports Firebase Auth.
- **Not carried over:** posts, legacy saved workouts, Exercise Stats, Workout Stats, the commented-out
  Measurements / My Coaches / Requests. **Performance Center, Jump and Breathwork code stays in the
  repository untouched** (see open questions for their entry points).
- **Stamps colour:** the premium crown is `UIColor.premiumColour`, the purple literal, while SwiftUI
  `Color(.premiumColour)` is the green asset. The new header is SwiftUI, so it will be green. That is
  the documented app-wide conflict. Resolve it centrally rather than here.

### Step 2 — `Profiles` projection, `Users` closed

**Cloud**
- `syncProfile`: on `Users/{uid}` write, writes `Profiles/{uid}` (identity fields, lowercased search
  fields). Later steps add counts and highlights to the same function.
- Backfill script in `InTheGym-Scripts`: `RebuildProfiles.py`, for every existing user.

**App**
- `FirestoreUserProfileLoader` (DISCOVER) reads `Profiles` instead of `Users`.
- ProfileKit reads other people only through a `ProfileLoader` protocol answered from `Profiles`.

**Console:** rules for `Profiles` (read: any signed-in user; write: none), then **close
`Users/{uid}` reads to the owner**. That is the last item, after the DISCOVER loader has moved.

### Step 3 — Edit profile: photo, name, bio

**App**
- `EditProfileScreen` (SwiftUI, live-update, "Done" dismisses): photo via `PhotosPicker` on the
  avatar with a camera badge, as account creation does, plus display name and bio.
- Writes through narrow protocols in `ProfileKit/Services/` (`ProfilePhotoUploader`,
  `ProfileDetailsWriter`), adapters in the composition root, one destination each.
- **The bio and display name must also reach RTDB `users/{uid}` while legacy screens read it.** That
  is two writers (`FirestoreProfileDetailsWriter`, `RealtimeDatabaseProfileDetailsWriter`) composed
  by a path-free decorator, per *one writer, one destination*. Drop the RTDB writer when the last
  RTDB reader of `users/{uid}` goes.

### Step 4 — Body measurements and the weight log

**Cloud**
- `createAccount` persists the five body keys it currently drops
  (`CLOUD_FUNCTIONS_ACCOUNT_CREATION.md`) and writes the signup weight as the first `BodyWeight`
  entry.

**App**
- A "Body" card on Edit Profile: height and date of birth reuse the account-creation sheet rules
  (wheel only in a sheet, Clear, switching unit converts). **Copy, do not import**: AccountCreationKit
  is another framework.
- Weight: "Log weight" writes today's `BodyWeight` entry, with a small hand-built trend (bars or a
  line, decided at build time; no Swift Charts) and the history list.
- `Users` gains the optional properties so the app can read them back.
- **Not here:** feeding the latest weight into `% of BW` prescriptions. That is a MyDay change worth
  its own task once the log exists.

### Step 5 — Follows

**Cloud**
- `syncFollowCounts`: on `Follows` write, recount `followerCount` / `followingCount` onto both
  users' `Profiles`.
- Migration script `MigrateFollows.py`: RTDB `Followers/{uid}` / `Following/{uid}` → `Follows`
  documents, all `active`. Dry run first.

**App**
- Follow / Following / Requested button on another user's profile (step 7 makes that screen
  reachable). The UI updates before the server confirms and reverts on failure, as DISCOVER's likes
  do.
- Followers and following lists from your own header. Remove a follower from your list.

**Console:** rules for `Follows` (create rules as above, read by either party, and by anyone for
`active` follows of a public profile) and composite indexes on `(followeeId, status, createdAt)` and
`(followerId, status, createdAt)`.

**Open:** legacy RTDB follow writes. Until every follow button is ProfileKit's, a follow made
elsewhere lands only in RTDB. Step 7 removes the other buttons. Decide whether to freeze RTDB follow
writes at migration time or dual-write until then.

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
  RawLogs, WorkoutSessions, WorkoutTemplates, BodyWeight, BlockedUsers), the analytics
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

- [ ] `Profiles` rules + `RebuildProfiles.py` **before** `Users` reads are closed
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
