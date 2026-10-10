# PERFORMANCE tab — plan

Performance Center becomes its own tab and its own framework, `PerformanceKit`. It happens in two
parts. **Part 1, the move** (steps 1–7): every legacy tool comes across as it is, so the redesign
starts from one module, not from code scattered through the app target. **Part 2, the testing hub**
(phases A–G below): Performance becomes the place an athlete measures readiness and power, built
around jump testing.

## Decisions

- **Tab order, player tab bar:** MYDAY, DISCOVER, PERFORMANCE, STATS, PROFILE. NEWSFEED left the
  player tab bar; the coach tab bar keeps it. ProfileKit's Settings → Tools row went too, since it
  was a second way into the same screen.
- **The home screen is open to everyone; pro is checked when a tool is opened**, by the router, read
  fresh each time (`PerformanceProAccess`). The tab is built once at launch, so a check made then
  would keep a new subscriber on the paywall until relaunch.
- **Moved as-is, UIKit included.** A legacy UIKit screen moves into the framework as UIKit. The one
  change a move makes is the one the framework rules require: **every Firebase call goes behind a
  narrow protocol, with its adapter in `InTheGym/Launch/Composition/PerformanceKit/`**, one per file,
  and the Firestore path or RTDB model lives there, not in the framework.
- **One tool per commit**, in the order below (Match and Practice Tracker are one tool). Until a tool moves, the router hands it back to the app
  through `onOpenLegacyTool`, and the app opens it with the legacy `PerformanceHomeCoordinator` on the
  tab's own stack. Each move takes one case off that switch.
- **Wellness, Training Status, CMJ and Injury Tracker do not move.** They were already commented out
  of the menu. Their code stays in the app target, untouched.
- **Icons are SF Symbols.** The move first copied the icons8 PNGs into an asset catalog; the restyle
  replaced them and the catalog went.

## Steps

### Step 1 — Skeleton and home — built
- `PerformanceKit.xcodeproj`, generated from ProfileKit's, ids prefixed `A7F0` (and `A7FA` for its
  entries in the app's pbxproj). One `PBXFileSystemSynchronizedRootGroup` per target, no file
  references, `BUILD_LIBRARY_FOR_DISTRIBUTION` and `MEMBER_IMPORT_VISIBILITY` on, iOS 26.0.
  In the workspace and `CI_iOS_TestPlan.xctestplan`.
- `PerformanceKitRouter` (`start()`, `.home`, `onShowPaywall`, `onOpenLegacyTool`), held by
  `PerformanceKitHostingController`, which also resets the bar colours the legacy tools change.
- `PerformanceHomeScreen` / `PerformanceToolCard` / `PerformanceHomeViewModel`: the legacy
  `PerformanceCenterView` and `PerformanceCenterOptionView`, moved. `PerformanceTool` is the legacy
  `PerformanceIntroOptions` without the commented-out cases. The journal is still hidden from anyone
  but its owner.
- `PerformanceKitComposition` builds the tab; `PurchaseManagerPerformanceProAccess` answers pro.

### Step 2 — Every way in goes through the router — built
Brought forward from the end, because the legacy callers reached each tool through the same
coordinator the moves take apart.
- `PerformanceKitComposition.presentModally(from:athlete:purchaseManager:)` presents the router full
  screen with a Dismiss button (`onDismiss`). `PlayerDetailCoordinator` (a coach viewing an athlete,
  so `athleteId` ≠ `currentUserId`), `PlayerProfileMoreCoordinator` and `TimelineCoordinator` call it.
  A non-pro user now sees the home and meets the paywall on a tool, as on the tab, rather than
  getting the paywall in place of the whole centre.
- The legacy intro screen (`PerformanceIntroViewController`, its UIKit and SwiftUI views,
  `PerformanceIntroViewModel`, `PerformanceIntroOptions`) is gone, replaced by step 1's home.
- `PerformanceHomeCoordinator` is no longer a `Coordinator`: it only holds the flow methods for the
  tools still in the app, on the router's stack, weakly.
- **The router holds its navigation controller weakly.** The navigation controller holds the router
  through its root screen, so a strong reference would keep every dismissed Performance Center alive.
- `PlayerProfileMoreCoordinator.jumpMeasure()` opens `JumpCoordinator` directly, not through
  Performance Center. Step 4 has to account for it.

### Step 3 — Journal — built
- `JournalHomeScreen`, `JournalEntryScreen`, `JournalEntryDetailScreen`, `JournalEntryRow`, with
  `JournalHomeViewModel` / `JournalEntryViewModel`; route `.journal`. SwiftUI already, so moved as
  it was, apart from the defects below.
- `JournalEntriesLoader` and `JournalEntryWriter`. In the composition root:
  `FirestoreJournalEntriesLoader` (`Journal/{uid}/Entries`, newest first, decoded per document) and
  **two writers**, `FirestoreJournalEntryWriter` (`…/Entries/{id}`) and
  `FirestoreLatestJournalEntryWriter` (`Journal/{uid}`), composed by
  `EntriesAndLatestJournalEntryWriter(entries:latest:)`. The legacy view model wrote both in one
  batch. `JournalPath` and `JournalEntryFields` are the one definition of the paths and the fields.
- Defects fixed by the move, each with a test:
  - `JournalEntryModel.id` was a fresh `UUID()` on every read. `JournalEntry.id` is the document id.
  - Today's entries were appended to a second list on every load, so they repeated each time the
    screen reappeared. They are derived now.
  - A failed save left the spinner in place for good. It resets.
  - One undecodable entry emptied the journal. It is skipped.
  - An unused read of `Journal/{uid}` is gone; when that document was missing it skipped today's
    entries.
- Entries written from now on use the entry's own UUID as the document id rather than a Firestore
  auto-id. Old entries keep theirs and read the same way.
- The journal's nav bar is no longer the purple UIKit `premiumColour`. The moved screens use the
  system bar with `darkColor`, which `PerformanceKitHostingController` restores on the way back.

### Step 4 — Vertical Jump — built
- Routes `.verticalJump`, `.previousJumps`, `.jumpInstructions`, and the presented chain
  `.jumpRecorder(max:)` → `.jumpReplay(fileURL:max:)` → `.jumpResult(height:max:)`, each presented
  over the last (`present(_:from:)`). The best jump the home screen loaded rides along in the routes,
  replacing `JumpCoordinator.maxModel`, so the result screen does not read it again.
- SwiftUI screens moved as they were (`VerticalJumpHomeScreen`, `PreviousJumpsScreen`,
  `JumpInstructionsScreen`, `JumpResultsScreen`, sharing `VerticalJumpRow`). The UIKit camera and
  replay (`JumpMeasuringViewController`, `ReplayJumpMeasureViewController`, their views and view
  models) moved as UIKit, reporting through closures instead of `JumpCoordinatorFlow`.
- `VerticalJump.best(current:new:)` is the legacy best-jump rule on its own; `JumpMeasureViewModel`
  holds the height formula (h = t² × 1.22625). Both tested.
- `MaxVerticalJumpLoader`, `VerticalJumpHistoryLoader`, `VerticalJumpWriter`. In the composition root:
  `FirestoreMaxVerticalJumpLoader`, `FirestoreVerticalJumpHistoryLoader`, and two writers,
  `FirestoreVerticalJumpResultWriter` (`…/Results/{auto}`) and `FirestoreBestVerticalJumpWriter`
  (`VerticalJump/{uid}`), composed by `ResultAndBestVerticalJumpWriter(result:best:)`, replacing the
  legacy batch. `VerticalJumpPath` / `VerticalJumpFields` are the one definition of paths and fields.
- **CMJ builds the camera and replay from PerformanceKit** (`JumpRecording`, the only public part).
  CMJ stays in the app, dormant, but it records the same way, and leaving it a second copy of both
  screens would be a second copy of the height formula.
- Changed by the move:
  - The jumps shown are the **athlete's**. The legacy screens always used the signed-in user, so a
    coach opening an athlete's centre saw their own jumps. Recording is offered only on your own
    centre. **A coach reading `VerticalJump/{athleteId}` needs the Firestore rules to allow it.
    Rules are not in this repository; check before relying on it.**
  - A failed save no longer leaves "Saving Result..." on screen for good.
  - The instructions sheet's close button closes it. It had an empty action.
  - Dead code did not come across: `MyJumpsView` (UIKit, unused), `RecordJumpCoordinator` (every
    body commented out), a second recording delegate on the camera screen, and an unused
    `clipUploadingProtocol` conformance.
- `PlayerProfileMoreCoordinator.jumpMeasure()` and `CoachProfileMoreCoordinator.jumpMeasure()` are
  unreachable (no row sends `.measureJump`, and the coach one is never built). They open Performance
  Center now rather than the camera.

### Step 5 — Match Tracker and Practice Tracker, as one tool — built
The legacy app had a full copy of each, identical apart from copy, icons, and the load a session
logs. They moved as **one tool**, `TrackedSessionKind` (`.match` / `.practice`) carrying every
difference, so there was no step 6.
- Routes `.tracker(kind)` and `.trackedSession(_:kind:)`. `TrackerHomeScreen`, `TrackedSessionRow`,
  `TrackedSessionDetailScreen`, `NewTrackedSessionScreen`, `RatingPicker` (a copy of the app's
  `QuestionView`, which Wellness keeps), with `TrackerHomeViewModel` and `NewTrackedSessionViewModel`.
- **Saving takes a snapshot, then stores the session, then logs its load**, in that order, so the
  snapshot describes the athlete coming into the session. The load links back by the key the session
  was stored under (`workoutID`). Match: a flat 1000 at RPE 10 over 7200 s. Practice:
  `duration × RPE × 1.5`, truncated. Both in `TrackedSessionKind.workload(...)`, tested.
- **`WorkloadRatio` is the one copy of the legacy workload metrics**, which were written out in both
  trackers and again in the Workload tool. It is deliberately **not** StatsKit's `ACWR`: a different
  log, device-calendar days, and the values every record already stores. It keeps the legacy
  `stdev()`, which computes `sqrt(Σ(x − mean)² / n − 1)` instead of `/ (n − 1)` and is often NaN
  (stored as 0). **Fixing it is for the redesign, with a decision about the records already written.**
  A test pins the current value so it cannot change quietly.
- Five services: `TrackedSessionsLoader` / `TrackedSessionWriter` (kind passed in), `WorkloadsLoader`
  / `WorkloadWriter`, `WellnessSnapshotLoader` / `CMJSnapshotLoader` (nil on failure, as before). In
  the composition root they go **through the legacy models** (`MatchTrackerModel`,
  `PracticeTrackerModel`, `WorkloadModel`, `RatioModel`, `WellnessAnswersModel`, `CMJModel`) so the
  stored shape is unchanged. `PerformanceKit+LegacyModels.swift` maps every field both ways, and
  `LegacyTrackerRecord` lets one mapping read both record types. `WellnessSnapshot` / `CMJSnapshot`
  mirror every field for that reason; their titles come from the app's enums.
- Changed by the move:
  - A coach sees the **athlete's** sessions (the legacy screens used the signed-in user), and
    recording is offered on your own centre only. **A coach reading `MatchTracking/{athleteId}`,
    `PracticeTracking/{athleteId}` and `Workloads/{athleteId}` depends on the Realtime Database rules.**
  - A failed save puts the button back. The legacy view models left the spinner up.
  - A new session appears in the list at once.
  - The match sheet's rating headers are the practice sheet's correct ones.
  - Cards are `systemBackground`, not `.white`, which was unreadable in dark mode.
  - The duration stepper stops at 0 and 240, like its slider.
- Still as before: a failure after the session is stored but before its load is logged leaves the
  session without a workload entry, and saving again records it twice.

### Step 6 — Workload — superseded
Not moved: retired in phase A. STATS already does ACWR from MyDay's data, and this tool read an RTDB
log MyDay never writes, so it could only show stale numbers. That also settled the Charts-package
question it raised.

### Step 7 — Retiring the bridge
Folded into phase A: with Workload retired, `PerformanceHomeCoordinator` and `onOpenLegacyTool` go.

### Restyle — built
Every SwiftUI screen moved onto MyDay's design vocabulary: a `systemBackground` page,
`secondarySystemBackground` cards at radius 16, uppercase 13pt captions, explicit system fonts, no
shadows, and the forward action as a 52pt `darkColor` button pinned to the bottom. The shared pieces
live in PerformanceKit's `UI/`. Default `List`s (inset grouped) went, and so did white cards, drop
shadows, the premium-colour gradient and the icons8 PNGs (SF Symbols now, so the asset catalog is
gone). System segmented controls became `PerformancePillPicker` and `RatingPicker`'s eleven cells,
which take the brand colour. The jump camera and replay are full-screen camera UI and stay as they
were. Copy was tightened where it repeated the navigation title or had typos.

## Part 2 — the testing hub

Agreed 2026-10-10. Nothing in part 2 is built yet.

### What Performance is for
Testing readiness and power. **Jump testing is the core**, CMJ and Vertical Jump first, with a
weekly fatigue check built on CMJ. Everything on the tab is a test with a number that can be tracked
over time.

### Decisions
- **The tab is behind the paywall.** A non-pro user opening PERFORMANCE sees the paywall in the tab
  itself, not the home screen, and it is checked each time the tab appears, so subscribing lets them
  straight in. This replaces part 1's "home open, tools gated" rule.
- **Emulator builds can unlock pro with one tap.** In `#if EMULATOR` builds the paywall shows an
  extra "Unlock for testing" button, which sets an in-memory override on the pro check for the
  session. It is compiled out of every other build, so it can never ship. Not built yet; it belongs
  with phase A.
- **Home is the readiness dashboard** (layout A from the design discussion): the weekly check as the
  hero card with its zone, a row of key numbers (CMJ, Vertical Jump, RSI), then the tests. Not a menu.
- **Vertical Jump and CMJ are two separate tests** on one capture engine (record → tag → calculate).
  CMJ is hands on hips, no arm swing: the repeatable test, and the one the fatigue check uses.
  Vertical Jump allows arm swing: the "how high can I go" number.
- **A test is best of three attempts.** One jump is too noisy to track.
- **Retired from Performance:** Workload, Journal, Match Tracker and Practice Tracker. Their stored
  data is not touched (`Journal/`, `MatchTracking/`, `PracticeTracking/`, `Workloads/` stay where they
  are); only the tools leave the tab. Deleting their code is a decision for that commit, and git keeps
  it either way.
- **Coach access is not in part 2, but is designed for.** A coach linked to an athlete by request and
  approval will see a summary of that athlete's results. So every test result is stored per athlete
  in Firestore in a shape a server-written, coach-readable summary can be built from later, and the
  router keeps its `currentUserId` / `athleteId` split. The coach↔athlete link in Firestore is the
  same piece *Coach-Assigned Workouts* in `CLAUDE.md` is blocked on, so it should be built once for
  both.

### The weekly fatigue check — % of a recent max
The athlete does three CMJs; the best is compared with their **max**, and the result is a percentage
and a zone. Proposed starting zones: **≥95% fresh, 90–95% caution, <90% fatigued**.
- **The max is the best CMJ from the last 8 weeks, not of all time.** An all-time max is set once and
  only ever rises: one outlier day, or a peak from earlier in the season, would make every later check
  read as fatigued when the athlete is simply at their current normal. A recent max keeps the "% of
  max" framing and a clear pass / fail moment, without an old PB setting the bar for good. The window
  length is a parameter.
- **Until there is enough history** (proposed: three CMJ sessions in the window), the check says it is
  calibrating rather than giving a false result.
- **Weekly:** the home card shows when the next one is due.
- Open: whether the target and zones are fixed or per athlete (later, set by a coach).

### Tests
| Test | What it measures | Headline number |
|---|---|---|
| CMJ | Jump height, hands on hips, best of 3 | cm; peak power (Sayers: 60.7 × height + 45.3 × mass − 2055), using the latest weight from ProfileKit's weight log |
| Vertical Jump | Jump height with arm swing, best of 3 | cm |
| Weekly fatigue check | Best of 3 CMJs against the recent max | % of max and zone |
| Drop jump | Step off a box, land, rebound. Three tags: landing, take-off, landing | RSI = jump height ÷ ground contact time; box height is an input |
| Single-leg CMJ | CMJ on each leg | Height per leg, and the left / right asymmetry % |
| Repeated jumps | Consecutive hops, as in the 10/5 test | Best five RSI over ten |
| Balance | Single-leg stance, 30 s, eyes open and closed, phone held to the chest; motion sensors measure sway | Sway per leg, and left / right symmetry |

**One capture engine for every jump.** The existing camera and replay grow from two tags to N, with
the test deciding what the tags mean. Recording is at 240fps, about 4ms a frame, which is enough for
the ~150–300ms contact times in drop and repeated jumps. **The height formula stays in one place**
(`JumpMeasureViewModel`, h = t² × 1.22625); CMJ, Vertical Jump, drop jump and the rest all call it.

### Phases
- **A — Clear the deck — built.**
  - Workload, Journal, Match Tracker and Practice Tracker are gone from PerformanceKit and their code
    removed, app and framework, with their adapters and tests. So is the dormant legacy CMJ tool
    (`CMJ/`, `CMJCoordinator`), and with it `JumpRecording`, the factory that existed only for it.
    Stored data (`Journal/`, `MatchTracking/`, `PracticeTracking/`, `Workloads/`, `CMJ/`) is untouched.
  - `WorkloadModel` stays: the legacy profile workloads and the coach dashboard still read it. So do
    Wellness, Training Status and Injury Tracker, now with no entry point at all.
  - The bridge is gone: no `onOpenLegacyTool`, no `PerformanceHomeCoordinator`.
  - **The tab is behind the paywall.** `PerformanceRootScreen` switches between the home and
    `PerformanceLockedScreen` on `PerformanceGateViewModel.isUnlocked`, which
    `PerformanceKitHostingController.onWillAppear` refreshes. The locked screen's button presents the
    app's paywall full screen, so closing it makes the tab appear and re-check. Tools no longer check
    pro themselves.
  - **Emulator unlock:** `EmulatorUnlockPerformanceProAccess` (app, `#if EMULATOR`) wraps the real
    check with a session-only override, shared by every router; the composition sets
    `router.onUnlockForTesting` only in that build, and the locked screen shows its button only when it
    is set. Verified: the type is in the Emulator binary and absent from Debug.
  - The two unreachable `jumpMeasure()` / `showPerformanceMonitor` paths in the legacy More
    coordinators open Performance Center.
- **B — Jump engine — built.**
  - `JumpTestKind` (Vertical Jump today) is a **tag plan** of `JumpEvent`s and a number of attempts
    (3). `JumpTiming` turns tagged times into flights (take-off → landing) and ground contacts
    (landing → take-off) for any plan, refusing tags out of order or at zero. `JumpPhysics` is the
    one height formula. `JumpAttempt` is height from the last flight, plus its times.
  - Tagging is `JumpTaggingViewModel` behind a reworked replay screen: one "Tag ‹event› (n of N)"
    button stepping through the plan, Undo, a marker per tag, and a reason shown when a tag is
    refused. The legacy screen had two fixed buttons and dropped a bad tag without a word.
  - A test is a **session**: `JumpTestSessionScreen` has three attempt slots, records each through
    camera → tag → back, marks the best, lets one be removed and re-recorded, and saves after one or
    more. The session id is fixed when it starts, so a retried save overwrites. The router runs the
    chain (`.jumpTest` → `.jumpRecorder` → `.jumpReplay`); the video is deleted once measured.
  - Stored at **`Users/{uid}/JumpTests/{id}`**: `kind`, `date`, `attempts` and a query-only
    `bestHeight`. One collection for every jump test, so the fatigue check and a coach's summary read
    one place. **Firestore rules must allow the owner this subcollection; they are not in this repo.**
  - Vertical Jump runs on it. Its pre-engine results (`VerticalJump/{uid}/Results`) are read as
    one-attempt sessions by `LegacyVerticalJumpSessionsLoader`, merged by
    `CurrentAndLegacyJumpTestSessionsLoader` (a failed legacy read does not hide new sessions).
    Nothing writes the legacy paths now, and the separate best-jump document is no longer read: the
    best is worked out from the sessions. `JumpResultsScreen` and the two legacy writers are gone.
- **C — CMJ — built.**
  - `JumpTestKind.cmj` (stored `kind: "cmj"`): the same take-off / landing plan and best of three,
    with its own technique step (hands on hips, no arm swing). On the home above Vertical Jump.
  - **The jump-test screens are generic now**: `JumpTestHomeScreen`, `JumpTestHistoryScreen` and the
    instructions take a kind, routed as `.jumpTestHome(kind)`, `.jumpTestHistory(kind)`,
    `.jumpInstructions(kind)`. Vertical Jump's own screens became these. A new jump test needs a case,
    a summary, a technique step and a tile icon.
  - **Power, CMJ only** (`JumpTestKind.estimatesPower`): `JumpPower` is the Sayers equation,
    60.7 × height + 45.3 × mass − 2055 watts, plus W/kg. It was fitted to jumps without arm swing,
    so Vertical Jump does not show it. A result at or below zero is no power, not a negative one.
  - **Body mass is stored on the session** (`bodyMass`), read when the sitting opens through
    `BodyMassLoader` → `FirestoreBodyMassLoader` (`Users/{uid}.weightKilograms`, which
    `syncLatestWeight` keeps as the latest weight-log entry). A session's power therefore does not
    move with later weigh-ins. No logged weight is no power: the jumps still save, and the screens
    say "Log your weight in Profile to see power."
  - Power shows on the session as you go, on the home's best card, and under each history row,
    marked "est.".
- **D — Weekly fatigue check and the readiness home — built.**
  - **Every CMJ session is a check** (`FatigueCheck`). The check is three CMJs, which is a CMJ
    session, so it is not a second kind of record, and an ad-hoc CMJ counts too. "Start weekly check"
    opens a CMJ session.
  - The result is the latest session's best as a fraction of the best CMJ in the **eight weeks before
    that session**. The window hangs off the latest session, not today, so a result does not drift
    as days pass. **Calibrating until two earlier sessions** fall in the window. Above the max reads
    over 100%, "New best".
  - `FatigueZone` is the one definition of the boundaries (≥95% fresh, 90–95% caution, <90% fatigued)
    and owns their colours: StatsKit's matte green / amber / red, copied into PerformanceKit's colour
    extension (keep in step).
  - Due seven days after the latest CMJ, or now if there is none.
  - **The home is the dashboard** (layout A): `FatigueCheckCard` (result in its zone's colour with a
    zone bar from 80% to 105% and a line of advice, or calibrating, or the first-check invitation;
    the due line at its foot), key numbers (best CMJ, best Vertical Jump, best power per kg), then
    the tests, with "Start weekly check" pinned. `PerformanceDashboardViewModel` reads CMJ and
    Vertical Jump separately so one failing does not hide the other, and reloads every time the tab
    appears, which is how a test saved from a test's own screen reaches it.
  - Still open: whether the target and zones become per athlete (or per coach).
- **Fix — the camera no longer crashes without a camera.** The recorder assumed a back and a front
  camera and access to them; in the simulator, or with access denied, it force-unwrapped nil and
  crashed on opening. `JumpCameraAvailability.check()` now runs first (asking for access if it never
  has) and the router shows `JumpCameraUnavailableScreen` instead: "Open Settings" when access is
  off; "Add a sample jump" **in the simulator only** (`#if targetEnvironment(simulator)`), which feeds
  a plausible attempt, measured through the same `JumpTiming` and `JumpPhysics`, into the session.
  The capture code also guards its inputs as a second line.
- **E — Drop jump — built.**
  - `JumpTestKind.dropJump` (stored `"dropJump"`): tag plan `[.landing, .takeOff, .landing]`. Tag
    names and hints are now the test's (`tagTitles`, `tagHints`, `tagSteps`), so a drop jump's button
    reads "Tag box landing (1 of 3)" and its two landings are told apart.
  - **RSI = jump height (m) ÷ ground contact (s)** (`JumpAttempt.reactiveStrengthIndex`). A test has a
    `headline` (height, or reactive strength), and **the best attempt is the best score**
    (`score(for:)`), so a drop jump's best is its best RSI, not its highest rebound.
    `JumpTestKind+Display` is the one formatting of a result ("RSI 1.84", with "34.1 cm · 0.21 s
    contact" beneath), used by every screen.
  - **Box height** is picked on the session (20–60 cm), fixed once the first attempt is in, and stored
    as `boxHeight`. RSI is only comparable off the same box; the test's screens show the box, and the
    dashboard's "Drop jump RSI" tile pools boxes.
  - Drop Jump is on the home's test list, and the key numbers are now a 2×2 grid: CMJ, Vertical
    Jump, drop-jump RSI, power per kg.
- **F — Single-leg CMJ and repeated jumps.**
- **G — Balance**, from the motion sensors.

Later, not scheduled: coach access, HealthKit resting HR / HRV in the readiness score, and manual
entry for results measured elsewhere (grip strength, sprint times).

### Settled
- The old CMJ data (`CMJ/{uid}`) is left alone; phase C starts fresh.
- The retired tools' code is deleted (phase A).

## Out of scope
- Bringing back Wellness, Training Status or Injury Tracker.
