# PERFORMANCE tab — plan

Performance Center becomes its own tab and its own framework, `PerformanceKit`. **This plan is the
move, not the redesign.** Every tool comes across as it is, so the redesign that follows starts from
one module, not from code scattered through the app target. **None of Performance Center's code is
deleted.** It moves.

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
- **One tool per commit**, in the order below. Until a tool moves, the router hands it back to the app
  through `onOpenLegacyTool`, and the app opens it with the legacy `PerformanceHomeCoordinator` on the
  tab's own stack. Each move takes one case off that switch.
- **Wellness, Training Status, CMJ and Injury Tracker do not move.** They were already commented out
  of the menu. Their code stays in the app target, untouched.
- **Images live in PerformanceKit's own asset catalog**, the first framework in the project to have
  one, and are always loaded with `bundle: .performanceKit`. Without the bundle, `Image("x")` looks in
  the app's catalog and draws nothing. The app keeps its copies while legacy code still names them.

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

### Step 4 — Vertical Jump
Firestore `VerticalJump/{uid}` and `/Results`, AVFoundation capture and replay, `JumpCoordinator` and
its flows. Also opened directly by the legacy "More" menu (`PlayerProfileMoreCoordinator.jumpMeasure()`).

### Step 5 — Match Tracker
RTDB through `FirebaseDatabaseManager` (`MatchTrackerModel`, `WorkloadModel`); reads Firestore
`WellnessScores/{uid}` and `CMJ/{uid}`.

### Step 6 — Practice Tracker
The same shape as Match Tracker.

### Step 7 — Workload
`PerformanceMonitorViewController` and the two child view controllers it embeds,
`WorkloadChildViewController` and `OptimalWorkloadRatioViewController`. RTDB workloads. Nothing MyDay
writes reaches this screen: its workloads come from the match and practice trackers, custom
workloads and the legacy workout flow. That is a question for the redesign, not the move.

### Step 8 — Retiring the bridge
`PerformanceHomeCoordinator` and `onOpenLegacyTool` go, and the app's copies of the icons go if
nothing else names them.

## Out of scope
- The redesign. It is the next piece of work.
- Bringing back Wellness, Training Status, CMJ or Injury Tracker.
- Feeding MyDay sessions into the Workload tool.
