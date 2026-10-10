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
- **A — Clear the deck.** Retire Workload, Journal and both trackers. Remove the bridge
  (`onOpenLegacyTool`, `PerformanceHomeCoordinator`). Put the tab behind the paywall, with the
  emulator unlock.
- **B — Jump engine.** Generalise capture and tagging to N tags. Best-of-3 sessions. Store a result
  per test in Firestore per athlete. Vertical Jump moves onto it, keeping its existing data readable.
- **C — CMJ.** A test of its own, with power from the athlete's weight.
- **D — Weekly fatigue check and the readiness home.** The recent max, zones, calibration, the due
  date, and the dashboard home with the hero card and key numbers.
- **E — Drop jump**, with RSI and box height.
- **F — Single-leg CMJ and repeated jumps.**
- **G — Balance**, from the motion sensors.

Later, not scheduled: coach access, HealthKit resting HR / HRV in the readiness score, and manual
entry for results measured elsewhere (grip strength, sprint times).

### Open
- The legacy dormant CMJ tool (`CMJ/` in the app target) has its own Firestore data (`CMJ/{uid}`) and
  a fatigue level. Phase C decides whether that data is migrated, read, or left.
- Whether the retired tools' code is deleted in phase A or kept for reference.

## Out of scope
- Bringing back Wellness, Training Status or Injury Tracker.
