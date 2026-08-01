# InTheGym — CLAUDE.md

## Project Overview
iOS fitness app. iPhone only, iOS 17+ minimum.
Lean, minimal UI aesthetic throughout.

## Packages & Frameworks
### Active — modify freely
- `MyDayKit` — framework
- `StatsKit` — framework
- `AccountCreationKit` — package
- `LoginKit` — package

### Inactive — do not modify
- `ITGWorkoutKit` — ignore, do not touch
- `ClubKit` — ignore, do not touch

## Auth
Firebase Auth, email and password only.

## Architecture
- Coordinator-based UIKit navigation with SwiftUI views via `UIHostingController`
- Protocol-oriented DI — framework layer owns only protocols and managers
- All concrete infrastructure lives in the composition root
- Local-first: FileManager + JSON for templates and daily entries, Firestore for remote sync
- Session logs stored as `WorkoutSessionRecord` embedded in `DailyWorkoutEntry` (same JSON day file)

## Tech Stack
Swift, SwiftUI, UIKit, Combine, Firebase/Firestore, Firebase Cloud Functions,
Firebase Emulator (Python seeding scripts, --import/--export), NWPathMonitor

## Brand Colours
- Dark: `#1C496E`
- Light: `#4179BD`

## Conventions — enforce strictly

### General
- All code split into separate files — no exceptions
- Live-update UX: values apply as user types; "Done" is the sole forward navigation action
- UI aesthetic: lean and minimal

### SwiftUI
- No Swift Charts — all charts are hand-built custom components
- Set pills: `frame(width: 72, height: 52)`, `RoundedRectangle(cornerRadius: 14)`
- `.listStyle(.plain)` not `.insetGrouped`

### Swift
- Reference type arrays: `(0..<n).map { _ in Type() }` — never `Array(repeating:count:)`
- `await MainActor.run` for publishing violations
- `@unchecked Sendable` on managers where needed

### Navigation
- Coordinators: `sub.start()` from parent
- `popToCoordinatorRoot()` not `popToRootViewController()`

## Testing
Before writing any tests, read all test files and folders within `ITGWorkoutKit`
and use these as the template for structure, naming, and style.

## App Structure
5 tabs: NEWSFEED, DISCOVER, MYDAY, STATS, PROFILE.
Current focus: MYDAY tab — active session UI partially complete (see roadmap and Feature Areas Complete).
NEWSFEED may be replaced with a dedicated WORKOUTS tab (TBC).

Roadmap order:
1. Active session UI — abandon flow, manual set logging
2. Fix workout stats → update STATS tab
3. DISCOVER tab (exercises + workouts: display, scoring, user reviews)

## Workout Library Loading
The library screen showed an empty state despite saved templates existing. Three defects, all fixed:
1. `FirestoreWorkoutTemplateFetcher.fetchAll()` had `try` *outside* the `compactMap`, so one
   undecodable document aborted the whole fetch. It now decodes per document and skips failures
   with a `❌ Skipping workout template <id>` log. **Keep the decode per-document.**
2. `WorkoutExerciseModel.exerciseName` / `.exerciseCategory` are non-optional and were added in
   commit `adf2ac71`. Templates written to Firestore before that commit have neither key and can
   never decode — they are now skipped (and logged) rather than blanking the library. Any such
   template has to be recreated. **Adding a non-optional field to a persisted model breaks every
   document already in Firestore — make new fields optional or migrate.**
3. `WorkoutLibraryManager.load()` mapped every thrown error to `.empty`. There is now a
   `.failed(String)` state rendered as a "Couldn't Load Workouts" view with a Try Again button, and
   `loadIfNeeded()` only treats `.loaded` as settled so empty/failed results retry on next
   appearance — the manager is built once in `MyDayKitComposition` and outlives the screen, so the
   old `guard case .loading` left it blank until app relaunch. An `isFetching` flag guards against
   overlapping fetches.

Still outstanding: reads are Firestore-only while writes are local-first (`WorkoutTemplateSaver` →
FileManager + queued remote), so a template that has not synced yet is invisible to the library.
There is no `FileManager` counterpart to `FirestoreWorkoutTemplateFetcher`.
Also `addTemplate` drops the template if it lands while `state == .loading`.

## Feature Areas Complete
- Daily exercise logging
- Workout builder and templating (`WorkoutTemplateModel` / `WorkoutSessionModel`)
- Upload/sync pipeline:
  `WorkoutTemplateSaver` → `WorkoutTemplateSyncer` → `SyncQueueWorkoutTemplateUploader`
  → `FirestoreWorkoutTemplateUploader` → `WorkoutTemplateSyncService`
- `WorkoutSessionManager` with active session state, rest timer, `finishSession()` /
  `abandonSession()`; `onEntryUpdated: ((DailyWorkoutEntry) -> Void)?` callback fires after start,
  set completion, finish, and abandon — coordinator wires this to `dayManager.updateWorkoutEntry`;
  init restores `.inProgress` or `.completed` state from the entry on construction
- Per-exercise RPE input: `WorkoutExerciseRecord.rpe?`, `setExerciseRPE(exerciseId:rpe:)` /
  `exerciseRPE(for:)` on manager, `WorkoutExerciseRPESheet` (color-coded 1–10, flash-then-dismiss)
- Completed session read-only view: `completedHeader` (sets logged + duration + green badge);
  set pills disabled; Finish button hidden; revisiting a completed entry shows this view
- Wellness and RPE inline check-in cards
- Performance analytics with hand-built charts (`MiniBarChart`, `MiniLineChart`, ACWR zone bar)
- Library, creation home, template detail screens with collapsible exercise cards and set pill views
- Workouts in MYDAY tab — add/remove workouts to a day, persisted via `workoutSaver`
- Workout session screen — navigate, start, track set completion, finish
- Post-session summary screen — duration/sets stats, session RPE picker, workload reveal,
  notes input, "Complete Workout" finalises session (`finishSession(rpe:notes:)`)
- Set detail overlay on session screen — matched-geometry hero expansion from the tapped set pill

## MYDAY Workout Flow
- **Library → Template Detail → Add to Today**: `MyDayWorkoutCoordinator` handles navigation;
  `MyDayWorkoutTemplateDetailScreen` shows dark scrollview + white metrics strip;
  "Add to Today" shows a `WorkoutAddedConfirmationOverlay` (instant dim, card springs from bottom)
  then pops back to MyDay home via `onWorkoutAddedToDay` callback chain
- **`DailyWorkoutEntry`**: `id`, `template`, `assignedDate`, `status` (`planned` / `inProgress` /
  `completed` / `incomplete`), `sessionId?`, `startedAt?`, `sessionRecord?`
- **`WorkoutExerciseModel`**: carries `exerciseName: String` and `exerciseCategory: ExerciseCategory`
  populated at template build time from the `Exercise` struct in `WorkoutBuilderManager.buildTemplate()`.
  Cards display `exerciseName` — never `exerciseId` (which is a UUID at runtime).
- **`WorkoutSessionRecord`**: embedded in `DailyWorkoutEntry`; holds `startedAt`, `endedAt`,
  `rpe?`, `workload?` (duration × RPE), and `exerciseRecords: [WorkoutExerciseRecord]` each with
  `exerciseName: String`, `rpe: Int?`, and `setRecords: [WorkoutSetRecord]` (per-set `isCompleted`
  + actual values). All `Codable`, persisted automatically through `workoutSaver`.
- **`MyDayManager+Workouts`**: `addWorkoutToDay(_:)`, `removeWorkoutFromDay(_:)`, and
  `updateWorkoutEntry(_:)` — all mutate `selectedDay.workouts` and save via `workoutSaver`
- **`DailyWorkoutCard`**: status chip lives in the subtitle row (not top row) to avoid ellipsis
  overlap. Card body tap → session screen; ellipsis-only tap → `WorkoutCardOptionsSheet`
  (Start Workout / Remove from Today). ZStack pattern: ellipsis `Button` sits above card `Button`
  as siblings so it wins its hit area without gesture conflicts.
- **Session screen flow**: `MyDayCoordinator` pushes `MyDayWorkoutSessionScreen` on `.workoutSession`
  route; screen shows `WorkoutSessionStartCard` overlay until started; tapping "Start Workout" calls
  `manager.startSession()` which fires `onEntryUpdated` to persist; set pills disabled until started;
  elapsed timer seeds from `manager.startedAt` on resume so it is accurate when re-entering an
  in-progress session; "Finish" navigates to `WorkoutSessionSummaryScreen` (via `onGoToSummary`
  callback → `coordinator.showSummary(manager:)`). Screen is pure UI — no save calls. Coordinator
  wires `manager.onEntryUpdated = { dayManager.updateWorkoutEntry($0) }`.
  Revisiting a completed entry shows `completedHeader` (read-only).
- **Summary screen** (`WorkoutSessionSummaryScreen`): pushed after "Finish"; shows duration + sets
  completed stats, session RPE picker (1–10 grid, same colour coding as exercise RPE) with average
  exercise RPE displayed for reference, workload (duration × RPE) animates in once RPE is entered,
  free-text notes field, "Complete Workout" button. "Complete Workout" calls
  `manager.finishSession(rpe:notes:)` then pops to root. Back navigation discards summary input.
  `WorkoutSessionRecord` now includes `notes: String?`; workload and rpe set at finish time.
- **Set detail overlay** (`SessionSetDetailOverlay`): tapping a set pill (when session started)
  expands that pill into a full-bleed card. Shows exercise name + set number, a TARGET stats grid
  (reps/weight/time/distance from `WorkoutSetModel`), a LOGGED grid (from `WorkoutSetRecord`, shown
  with green badge if completed), and a "Complete Set" button if not yet logged and session active.
  `SessionSetDetail` bundles exercise + setModel + setRecord + index, and owns `matchedId`
  (`"\(exercise.id)-\(setModel.id)"` — set ids are only unique within an exercise). Pill tap opens
  the overlay via `onSetTapped((WorkoutSetModel, WorkoutSetRecord?, Int) -> Void)?` on the exercise
  card; whole-pill is the tap target (`.contentShape` + `.onTapGesture`).
  **Animation deliberately mirrors `MyDayHomeScreen.setDetailOverlay` — keep the two in step.**
  `SessionSetPill` carries `matchedGeometryEffect` on `"\(matchedId)background"` /
  `"\(matchedId)overlay"`; while selected it is swapped for `SessionSetPillPlaceholder` so the
  layout slot survives the hero flight. The card reveals its content via `@State isShowing` 0.3s
  after appear (`.easeInOut(0.2)`); the close button reverses that before calling `onDismiss` at
  +0.4s. Presented from `.overlay { }` on the screen — never inside the main `ZStack` — with a 0.6
  black dim (`.transition(.opacity)`) and `.transition(.asymmetric(insertion: .identity,
  removal: .offset(y: 5)))` on the card. The spring lives in one place as `heroAnimation`; drive it
  only with `withAnimation` at the mutation sites, never also with `.animation(_:value:)`.
  Known gaps: "Complete Set" dismisses immediately so the LOGGED grid only appears on re-tap, and
  `SessionSetDetail` is a snapshot that does not refresh — both belong with manual set logging.
- **Coordinator callback pattern**: child coordinator exposes `var onX: (() -> Void)?`;
  parent sets it after `let sub = ChildCoordinator(...)` before returning `sub.start()`

## Session Screen — What's Not Yet Built
- Abandon session flow
- Manual set logging (editing actual reps/weight per set — `MyDayWorkoutSessionLogSetSheet` exists but not wired)

## Firestore
Firestore collection structure will be provided when working on specific features.

## Long-term Architecture Goal
Each tab to become its own framework. Shared core features (e.g. user profile loading)
to be extracted into dedicated frameworks as usage spans multiple tabs.

## What Not To Do
- Do not use Swift Charts
- Do not use `Array(repeating:count:)` for reference types
- Do not use `.insetGrouped` list style
- Do not use `popToRootViewController()`
- Do not modify `ITGWorkoutKit` or `ClubKit`
- Do not put concrete infrastructure in framework layer — composition root only
- Do not create multi-purpose files — one concept per file
