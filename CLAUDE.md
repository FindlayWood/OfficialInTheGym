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
Current focus: MYDAY tab — active session UI complete (see roadmap and Feature Areas Complete).
NEWSFEED may be replaced with a dedicated WORKOUTS tab (TBC).

Roadmap order:
1. Fix workout stats → update STATS tab
2. DISCOVER tab (exercises + workouts: display, scoring, user reviews)

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
  `cancelSession()`; `onEntryUpdated: ((DailyWorkoutEntry) -> Void)?` callback fires after start,
  set completion, finish, and cancel — coordinator wires this to `dayManager.updateWorkoutEntry`;
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
- Manual set logging — reps/weight/time/distance per set edited on the custom number pad via
  `SessionSetValueSheet`, with un-logging via `uncompleteSet(exerciseId:setId:)`;
  weight unit (kg / lbs / BW) selectable at log time
- Custom session nav bar (system bar hidden) + cancel-workout flow (`cancelSession()` full reset)

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
  expands that pill into a full-bleed card. Shows exercise name + set number, a single measure grid
  (see below), tempo/note when the template set has them, and a "Complete Set" button while the
  session is active.
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
- **Manual set logging**: every measure is editable — reps, weight, time and distance. **No typed
  input during a session:** tapping a card opens `SessionSetValueSheet`, which drives
  `CustomNumberPad` (the same big-target pad `MyDayKitRepsView` / `MyDayWeightSelectorView` use) and
  binds the value live, so "Done" only dismisses. `SessionSetMeasure` describes which value is being
  entered (title, icon, and whether decimals are allowed — reps and time are whole numbers). Do not
  reintroduce a system-keyboard `TextField` here. `SessionSetInput` carries the entered values up via
  `onLog`; the screen's `log(_:for:)` writes them through `manager.completeSet(...)` and starts the
  rest timer **only on first completion**, never on an edit. Button reads "Complete Set" then
  "Update Set", and is enabled once any value is entered (or BW is selected).
  `onRemoveLog` → `manager.uncompleteSet(exerciseId:setId:)` clears `isCompleted` and
  all performed values, and the overlay resets its fields back to the target.
  The overlay also renders the template set's `tempo` and `note` (mirroring `SetDetailView`'s cards);
  an all-zero `Tempo` is the builder's empty default and is treated as absent. Inputs seed once
  (`hasSeededInputs`) so a re-render never clobbers an entered value. The screen rebuilds
  `SessionSetDetail` from `manager.setRecord(exerciseId:setId:)` on every render — the stored
  `selectedSet` is only a tap-time snapshot, so **never read `setRecord` off it directly.**
  Known gap: the overlay stays open after logging, so the rest timer banner is hidden behind it
  until dismissed.
- **One merged measure grid — do not reintroduce separate TARGET and LOGGED grids.** There used to be
  a 4-card TARGET grid plus a 2-card input grid: six cards for four measures, with "—" drawn for
  measures the set never used. `measureGrid` now renders **one card per measure**, the performed
  value large with the target beside it in grey brackets, and the bracket appears **only when the two
  differ** so an on-target set stays clean and a deviation is what catches the eye. This is what
  keeps the overlay off a long scroll now that all four measures are editable — the earlier
  alternative, a TARGET/PERFORMED toggle, was rejected for hiding the target exactly while entering.
  `visibleMeasures` renders reps/time/distance only when the template or record has them; **weight is
  always offered**, since a load the template never specified (vest, dumbbell, loaded carry) is the
  commonest thing added beyond the prescription. `targetText(for: .weight)` carries its unit because
  the prescription may be in one the session cannot log — "(80 % of 1RM)" beside a logged 100 kg is
  the reference the user is working from — so `comparableValue` re-renders the performed weight the
  same way before comparing, or the unit alone would read as a difference. When the session is not
  active the cards read from the record, not the seeded inputs: a set left unlogged in a finished
  session must show "—", never the target it never met.
- **Weight unit is chosen in the session, not inherited.** `WeightUnit.loggable` is `[.kg, .lbs, .bw]`
  — `% of 1RM`, `% of BW` and `Max` are *prescriptions* (relative to a number the session doesn't
  hold, or an instruction), so they describe a target and are never stored against a performed set.
  `SessionSetValueSheet` shows the picker for `.weight` only; `SessionSetInput.weightUnit` carries
  the choice and `log(_:for:)` passes it straight through, so **do not re-default the weight unit
  from the template.** Previously it did, storing e.g. `weight: 100, weightUnit: .percent1RM` —
  rendered as "100 % of 1RM". `WeightUnit.carriesValue` is false for `.bw` / `.max`: those label a
  set on their own, so selecting BW clears and hides the number pad and stores `weight: nil`.
  The target's weight only seeds the field when the session logs in the unit the target was written
  in (`targetWeightInput`). Distance and time units still come from the template, defaulting to
  `.metres` / seconds, because a value whose unit is nil renders as "—".
- **Set pills show at most two values** (`SessionSetPillValue.values(for:record:)`), in priority
  order reps → weight → time → distance. A set carrying all four overflows the 72×88 frame and
  clips the text top and bottom. Pills take the `WorkoutSetRecord`, not just the `WorkoutSetModel`,
  and a logged set is read **wholesale** from the record — never merged field-by-field with the
  target, or logging bodyweight would resurrect the target's number under a `BW` unit.
  `SessionSetPillPlaceholder` renders the same values so the slot it holds stays the right size.
- **Session screen nav is custom — the system bar is hidden.**
  `WorkoutSessionHostingController` (a `UIHostingController` subclass) hides the nav bar in
  `viewWillAppear` and restores it in `viewWillDisappear`, mirroring `MyDayBoundaryViewController`.
  **Reason: a `UINavigationBar` is a sibling view owned by the `UINavigationController`, drawn above
  the hosting controller's view, so the set detail overlay could never dim or cover it** — the hero
  card was structurally boxed in below a white bar. Do not reinstate `.navigationTitle` /
  `.toolbar` on this screen. Hiding the bar also disables the swipe-from-edge pop, so the controller
  takes over `interactivePopGestureRecognizer.delegate` and allows the gesture whenever the stack has
  more than one VC — losing swipe-back would contradict the whole point of the screen.
  `WorkoutSessionNavBar` draws back / title / `⋯`, and `WorkoutSessionFinishBar` pins "Finish
  Workout" to the bottom, taking the slot `WorkoutSessionStartCard` holds pre-start (start bottom →
  finish bottom).
- **Leaving the session screen must stay free.** Progress persists after every set via
  `onEntryUpdated`, `WorkoutSessionManager.init` restores `.inProgress`, and the elapsed timer
  reseeds from `startedAt` — so back is a **plain chevron with no confirmation**. A warning would
  misrepresent stakes that do not exist. **Do not add a confirmation to back.**
  Cancelling the workout is the separate destructive action, kept behind the `⋯` menu with a
  confirmation dialog so it cannot be mistaken for leaving. It is called **"Cancel Workout", not
  "End"** — "end" reads as finishing, which is the opposite outcome. It calls
  `manager.cancelSession()` then `onCancelled` → `popToCoordinatorRoot()`.
- **`cancelSession()` is a full reset, not a "mark incomplete".** It discards `sessionRecord` and
  every logged set, returns the entry to `.planned` with `startedAt` / `sessionId` / `sessionRecord`
  cleared, and regenerates the manager's `sessionId` so a restart is a genuinely new session. The
  workout stays on the day and can be started again; removing it altogether is the separate
  "Remove from Today" action in `WorkoutCardOptionsSheet`. This is the one place in the flow where
  leaving does cost something, so the dialog says so plainly — everywhere else, back is free.
  This replaced `abandonSession()`, which set `.incomplete` and kept the record.
  `DailyWorkoutStatus.incomplete` is now unreachable but **kept** — it is a persisted `Codable`
  enum and dropping a case would break decoding of any day file already holding it.
  `DailyWorkoutCard` still renders a chip for it. `WorkoutSessionStatus.abandoned` was removed
  instead, being in-memory only.
- **Coordinator callback pattern**: child coordinator exposes `var onX: (() -> Void)?`;
  parent sets it after `let sub = ChildCoordinator(...)` before returning `sub.start()`.
  `MyDayCoordinator` now stores `rootViewController` in `start()` and exposes
  `popToCoordinatorRoot()`; `popToRoot()` / `popToRootViewController` are gone.

## Session Screen — What's Not Yet Built
- Rest timer banner is hidden behind the set detail overlay, which stays open after logging

## Firestore
Firestore collection structure will be provided when working on specific features.

## Long-term Architecture Goal
Each tab to become its own framework. Shared core features (e.g. user profile loading)
to be extracted into dedicated frameworks as usage spans multiple tabs.

## Future Ideas — not scheduled, not designed
Ideas captured so they are not lost. **Nothing here is agreed or specified — do not start
building any of it, and treat the details as a starting point for a conversation, not a spec.**

- **Coach-granted premium passes (in-app purchase).** A subscribed coach buys 1-year passes and
  grants them to their clients/athletes, giving each client the premium version of the app for that
  year. The pass is what lets the coach programme workouts to that client for the year. The coach
  must hold their own active subscription — a granted pass depends on the granting coach still
  being subscribed. Open questions before this is buildable: what happens to a client's pass when
  the coach's subscription lapses mid-year; whether passes are transferable or revocable; whether
  a client can hold passes from more than one coach; how this interacts with a client who also
  subscribes directly; and how the entitlement is verified server-side (App Store Server
  Notifications → Firestore) rather than trusted on device.

## What Not To Do
- Do not use Swift Charts
- Do not use `Array(repeating:count:)` for reference types
- Do not use `.insetGrouped` list style
- Do not use `popToRootViewController()`
- Do not modify `ITGWorkoutKit` or `ClubKit`
- Do not put concrete infrastructure in framework layer — composition root only
- Do not create multi-purpose files — one concept per file
