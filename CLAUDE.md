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
- Local-first: FileManager + JSON for templates, Firestore for remote sync
- Core Data planned (not yet implemented) for session logs

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
Current focus: MYDAY tab — workouts are now in the tab; next is the session screen.
NEWSFEED may be replaced with a dedicated WORKOUTS tab (TBC).

Roadmap order:
1. Workout session screen (next — `WorkoutSessionManager` ready, UI not built)
2. Fix workout stats → update STATS tab
3. DISCOVER tab (exercises + workouts: display, scoring, user reviews)

## Feature Areas Complete
- Daily exercise logging
- Workout builder and templating (`WorkoutTemplateModel` / `WorkoutSessionModel`)
- Upload/sync pipeline:
  `WorkoutTemplateSaver` → `WorkoutTemplateSyncer` → `SyncQueueWorkoutTemplateUploader`
  → `FirestoreWorkoutTemplateUploader` → `WorkoutTemplateSyncService`
- `WorkoutSessionManager` with active session state, rest timer,
  `finishSession()` / `abandonSession()`
- Wellness and RPE inline check-in cards
- Performance analytics with hand-built charts (`MiniBarChart`, `MiniLineChart`, ACWR zone bar)
- Library, creation home, template detail screens with collapsible exercise cards and set pill views
- Workouts in MYDAY tab — add/remove workouts to a day, persisted via `workoutSaver`

## MYDAY Workout Flow
- **Library → Template Detail → Add to Today**: `MyDayWorkoutCoordinator` handles navigation;
  `MyDayWorkoutTemplateDetailScreen` shows dark scrollview + white metrics strip;
  "Add to Today" shows a `WorkoutAddedConfirmationOverlay` (instant dim, card springs from bottom)
  then pops back to MyDay home via `onWorkoutAddedToDay` callback chain
- **`DailyWorkoutEntry`**: `id`, `template`, `assignedDate`, `status` (`planned` / `inProgress` /
  `completed` / `incomplete`), `sessionId?`, `startedAt?`
- **`MyDayManager+Workouts`**: `addWorkoutToDay(_:)` and `removeWorkoutFromDay(_:)` — both
  mutate `selectedDay.workouts` and save via `workoutSaver: MyDaySaver`
- **`DailyWorkoutCard`**: "WORKOUT" label, inline status chip, ellipsis; tap opens
  `WorkoutCardOptionsSheet` (half sheet — Start Workout / Remove from Today)
- **Coordinator callback pattern**: child coordinator exposes `var onX: (() -> Void)?`;
  parent sets it after `let sub = ChildCoordinator(...)` before returning `sub.start()`

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
