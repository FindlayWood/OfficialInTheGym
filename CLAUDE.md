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
- Dark: `#1C496E` — `Color.darkColor`
- Light: `#4179BD` — `Color.lightColor`

Both live in `MyDayKit/MyDayKitUI/Color/Color+Extension.swift`. **Never use system `Color.blue` *or*
`Color.accentColor` for accent or selection** — there is no `AccentColor.colorset` in the project, so
`accentColor` resolves to the same system blue and hides from a `Color.blue` grep. It read as generic
iOS chrome next to the session screens. Every selected
pill, active-state fill, tint and primary button is now `Color.darkColor` across both flows:
- **Workout builder** — everything in `MyDayWorkouts/UI/Screens/`
- **Exercise logging** — `MyDayExerciseListView`, `MyDayKitRepsView`, `MyDayUnitsHomeView` and the
  weight / distance / time / tempo / note selector views in `MyDayKitUI/Screens/`
- **MyDay home** — `MyDayHomeScreen` (Add button, date strip selection, activity underline, empty
  state), plus `CompletedSetView`, `RepeatSetView`, `ExerciseClipsSubView`, `SetDetailView`
- **Workout library / creation** — `MyDayWorkoutLibraryScreen`, `MyDayWorkoutCreationHomeScreen`,
  `WorkoutSettingsSheet`. These used `accentColor` rather than `Color.blue` and so survived the first
  sweep — **grep for both.**

The library row's icon is a **solid** `darkColor` tile with a white `dumbbell.fill`, not a 12%-tinted
one: at 44pt on a `secondarySystemBackground` card a wash of colour barely registers and the rows had
nothing anchoring them.

`Color.blue` still appears elsewhere in `MyDayKit` (clips, fitness, sports, wellness, `RPECard`) and
in `ExerciseCategory` / `SportType`, where it is a **semantic** colour identifying a category rather
than an accent. Leave those alone.

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

### Library reads are local-first (resolved)
Reads used to be Firestore-only while writes were local-first, so a template that had not synced yet
was invisible in the library it had just been saved to. Both defects are fixed:
- **`FileManagerWorkoutTemplateFetcher`** is the counterpart to `FileManagerWorkoutTemplateUploader`,
  reading `Documents/WorkoutTemplates/{id}.json`. **The directory and the ISO-8601 date strategy must
  stay in step with the uploader** — changing one side alone silently stops everything decoding. It
  decodes per file and skips failures, exactly as the Firestore fetcher decodes per document.
- **`WorkoutLibraryManager` takes `local:` and `remote:`.** `load()` reads local, publishes it
  immediately if non-empty, then fetches remote and publishes the merge. **A remote failure is not an
  error once local has produced something** — offline means stale, not broken, and blanking a visible
  list for a network blip is a worse lie than showing it. `.failed` is only reached when local was
  empty too.
- **`merge(_:with:)` unions by id, newest-created first.** Neither side is authoritative: local holds
  what has not synced, remote holds what was made on another device. Same id in both → later
  `updatedAt` wins.
- **`addTemplate` during `.loading` no longer drops the template.** It buffers into
  `pendingTemplates`, folded in by `publish(_:)` when the load settles. That moment — builder
  finishes, library still fetching — is exactly when the user is looking for it.

The loading skeleton mirrors the real row (icon tile, title bar, subtitle bar) under the same
"Your Library" heading, so the list fills in rather than swapping layouts. It is only the local read;
the network refresh happens behind an already-populated list.

Library rows read `"N exercises · <created>"`, the same `" · "` shape `DailyWorkoutCard` uses.
**The date is a differentiator, not decoration** — the builder's name suggestions produce repeats
(several "Saturday Upper"), and identical titles over identical exercise counts are unpickable.
It shows `createdAt`, not `updatedAt`, because `createdAt` is also the sort key, so dates read in
order down the list. Today and yesterday carry the time (`Today, 14:32`) since several templates
made in one sitting would otherwise all read "Today" and differentiate nothing.

## Feature Areas Complete
- Daily exercise logging
- Workout builder and templating (`WorkoutTemplateModel` / `WorkoutSessionModel`)
- Upload/sync pipeline:
  `WorkoutTemplateSaver` → `WorkoutTemplateSyncer` → `SyncQueueWorkoutTemplateUploader`
  → `FirestoreWorkoutTemplateUploader` → `WorkoutTemplateSyncService`
- Local-first template reads: `FileManagerWorkoutTemplateFetcher` + `FirestoreWorkoutTemplateFetcher`
  behind `WorkoutLibraryManager(local:remote:)` — the read path mirroring the write path
- `WorkoutSessionManager` with active session state, rest timer, `finishSession()` /
  `cancelSession()`; `onEntryUpdated: ((DailyWorkoutEntry) -> Void)?` callback fires after start,
  set completion, finish, and cancel — coordinator wires this to `dayManager.updateWorkoutEntry`;
  init restores `.inProgress` or `.completed` state from the entry on construction
- Per-exercise RPE input: `WorkoutExerciseRecord.rpe?`, `setExerciseRPE(exerciseId:rpe:)` /
  `exerciseRPE(for:)` on manager, `WorkoutExerciseRPESheet` (color-coded 1–10, flash-then-dismiss)
- Completed session read-only view: `completedHeader` (sets logged + duration + green badge);
  set pills not loggable but still open the detail overlay; Finish button hidden; revisiting a
  completed entry shows this view
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
  weight unit (kg / lbs / BW), distance unit (m / km / mi) and time unit (sec / min) all
  selectable at log time
- Custom session nav bar (system bar hidden) + cancel-workout flow (`cancelSession()` full reset)

## MYDAY Workout Flow
- **Library → Template Detail → Add to Today**: `MyDayWorkoutCoordinator` handles navigation;
  `MyDayWorkoutTemplateDetailScreen` shows dark scrollview + white metrics strip;
  "Add to Today" shows a `WorkoutAddedConfirmationOverlay` (instant dim, card springs from bottom)
  then pops back to MyDay home via `onWorkoutAddedToDay` callback chain
- **Template detail set pills tap through to `SessionSetDetailOverlay` in `.planned` mode.** That
  mode exists for a set that has not been performed, which is every set on a template — it renders
  the prescription as the card value under a TARGET heading with no bracketed target, no chevrons
  and no log button, so the screen gets a read-only detail view without a read-only variant being
  written. `SessionSetDetail` is built with `setRecord: nil`; the hero uses the same
  `heroAnimation` spring as the session screen and MyDay home, and
  `MyDayTemplateSetPillPlaceholder` holds the slot during the flight.
  The overlay covers the whole screen, custom nav bar included — see below.
- **Template detail nav is custom too — the system bar is hidden**, for exactly the reason the
  session screen's is. `MyDayWorkoutCoordinator` hosts it in `NavBarHidingHostingController` and the
  screen draws `MyDayWorkoutNavBar(title:onBack:)` with `showsOptions` defaulted to false; `onBack`
  pops through the coordinator. **Do not reinstate `.navigationTitle` / `.toolbar` here** — the dim
  could not cover the system bar and the overlay was boxed in below it.
- **`MyDayTemplateSetPill` caps at two values** via `SessionSetPillValue.values(for:record:)` with a
  nil record. It used to render reps, weight, time *and* distance unconditionally into a fixed 72×72
  frame, so a set carrying all four spilled its text outside the card. It is now 72×88 like every
  other set pill, ending with the **dimmed empty circle** a `.planned` `SessionSetPill` draws — a
  template set has not been performed, so the empty state is the honest one, and it fills the slot
  that otherwise left these pills looking lopsided. Indicator only; the whole pill is the tap target.
- **`DailyWorkoutEntry`**: `id`, `template`, `assignedDate`, `status` (`planned` / `inProgress` /
  `completed` / `incomplete`), `sessionId?`, `startedAt?`, `sessionRecord?`
- **`WorkoutExerciseModel`**: carries `exerciseName: String` and `exerciseCategory: ExerciseCategory`
  populated at template build time from the `Exercise` struct in `WorkoutBuilderManager.buildTemplate()`.
  Cards display `exerciseName` — never `exerciseId` (which is a UUID at runtime).
- **`WorkoutSessionRecord`**: embedded in `DailyWorkoutEntry`; holds `startedAt`, `endedAt`,
  `rpe?`, `workload?` (duration × RPE), and `exerciseRecords: [WorkoutExerciseRecord]` each with
  `exerciseName: String`, `rpe: Int?`, and `setRecords: [WorkoutSetRecord]` (per-set `isCompleted`
  + actual values, including performed `tempo` and `note`). All `Codable`, persisted automatically
  through `workoutSaver`. New fields on `WorkoutSetRecord` must be optional — see the Firestore
  decode warning under Workout Library Loading.
- **`MyDayManager+Workouts`**: `addWorkoutToDay(_:)`, `removeWorkoutFromDay(_:)`, and
  `updateWorkoutEntry(_:)` — all mutate `selectedDay.workouts` and save via `workoutSaver`
- **`DailyWorkoutCard`**: status chip lives in the subtitle row (not top row) to avoid ellipsis
  overlap. Card body tap → session screen; ellipsis-only tap → `WorkoutCardOptionsSheet`
  (Start Workout / Remove from Today). ZStack pattern: ellipsis `Button` sits above card `Button`
  as siblings so it wins its hit area without gesture conflicts.
- **`ExerciseCompletionView` mirrors `MyDayWorkoutSessionExerciseCard` — keep the two in step.**
  The MyDay home card for a single logged exercise uses the session card's structure, typography and
  chrome: header (name 16 semibold + reps summary 13 secondary), divider, horizontal sets row,
  divider, evenly-split actions row. An exercise logged on its own and an exercise logged inside a
  workout should read as the same kind of thing. **Presentation only — no callback or condition
  changed.** Two moves worth knowing: "Add Set" left the header (it was a tinted pill competing with
  the exercise name) for the actions row, joining "Clip"; and the clips strip is now passed
  `canAdd: false` and drawn only when clips exist, because the actions row owns adding — leaving
  `canAdd` true would draw a second add button inside the strip and its empty state would duplicate
  the row outright.
- **`CompletedSetView` is a completed `SessionSetPill`.** Same 72×88 frame, radius 14,
  `Color.darkColor` fill, white text, `Set N` label on top and the white `checkmark.circle.fill` at
  the bottom — every completion on the home screen has already been performed, so it is always in
  the logged state and has no empty variant. The checkmark is an indicator only; the whole pill is
  the tap target, as on the session screen. `index` comes from the enumerated `ForEach` in
  `ExerciseCompletionView`.
  It takes its values from **`SessionSetPillValue.values(for: ExerciseCompletions)`**, a second
  factory alongside the session one so both pills cap at **two values** in the same priority order
  (reps → weight → time → distance) — **keep the two factories in step.** The cap is what makes 72×88
  survivable: this pill previously ran to four lines at 100×100, and shrinking it without capping
  clips the text top and bottom. `eachSide` rides on the reps unit ("12 reps ea") rather than
  spending one of the two slots, since it qualifies the reps rather than being a measure.
  `PlaceholderSetView` mirrors it the way `SessionSetPillPlaceholder` mirrors the session pill —
  **same size and the same `SessionSetPillValue` values**, dimmed to 0.35 — so the slot survives the
  hero flight to `SetDetailView`. Rendering different measures there would resize the slot mid-flight
  and the hero would land crooked.
- **`SetDetailView` mirrors `SessionSetDetailOverlay` — keep the two in step.** Same header (name 20
  bold over a 13 medium subtitle, 36pt close circle), same `LOGGED` section label with its green
  check, same two-column measure grid in the session's order (**reps → weight → time → distance**),
  and the same `cardHeader` / `cardBackground` chrome with `Color.darkColor` labels. The subtitle is
  `Set N · HH:mm` — the session's "Set N" plus the completion time this view has always shown;
  `index` is looked up by `MyDayHomeScreen.setIndex(for:)` for display only, the overlay is still
  driven by `selectedSet`.
  **What it deliberately does not copy is editing.** The session overlay edits each measure inline
  via `SessionSetValueSheet`, so its cards carry chevrons and are buttons. Here the whole set is
  edited by re-entering the logging flow behind the **Edit** button, so the cards have **no chevrons
  and are not tappable**, and the Edit / Delete pair and the delete confirmation are untouched. Do
  not "finish the match" by making these cards tappable — that would fork set editing into two
  different mechanisms on the same screen.
  **Every card is always present**, exactly as on the session overlay — the four measures, tempo and
  note. A measure the set never carried draws "—" rather than vanishing, and so do tempo and note.
  A card that appears only sometimes is a card the user never learns is there. The note reads "—"
  rather than the session's "Add a note", since nothing is edited in place here and prompting for an
  action this card does not offer would be a dead end.
  Absent is judged the same way the rest of the app judges it: an all-zero `Tempo` is the builder's
  empty default and shows "—", and a note that is only whitespace counts as no note.
  The "Performed each side" chip stays conditional — it is a chip, not a card, and the session
  overlay has no counterpart to keep in step with.
- **Session screen flow**: `MyDayCoordinator` pushes `MyDayWorkoutSessionScreen` on `.workoutSession`
  route; screen shows `WorkoutSessionStartCard` overlay until started; tapping "Start Workout" calls
  `manager.startSession()` which fires `onEntryUpdated` to persist; set pills cannot be *logged*
  until started, but stay tappable throughout (see the overlay's three modes);
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
- **Set detail overlay** (`SessionSetDetailOverlay`): tapping a set pill — **in any session state** —
  expands that pill into a full-bleed card. Shows exercise name + set number, a single measure grid
  (see below), tempo and note cards, and a "Complete Set" button while the session is active.
- **The overlay has three modes** (`SessionSetDetailMode`), because it answers a different question
  in each and the same card shows a different number:
  `.planned` (not started) renders the **prescription** as the card's value, titled TARGET, with no
  bracketed target — bracketing would print the number twice — and no chevrons or log button;
  `.active` renders live input with the target beside it; `.review` (finished) renders the record,
  with "—" for a set never logged. This replaced a single `isSessionActive: Bool`, which could not
  tell `.planned` from `.review` and so drew an unstarted set as "—" — hiding the prescription,
  which is the entire reason to open a set before doing it. **Do not collapse the mode back to a
  Bool.** `SessionSetPill.isInactive` now only *dims* the empty circle; the pill is tappable in
  every state, so a set is readable before it is performed and after.
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
- **Manual set logging**: every measure is editable — reps, weight, time and distance — plus tempo
  and a note. **No typed input for numbers during a session:** tapping a card opens
  `SessionSetValueSheet`, which drives
  `CustomNumberPad` (the same big-target pad `MyDayKitRepsView` / `MyDayWeightSelectorView` use) and
  binds the value live, so "Done" only dismisses. `SessionSetMeasure` describes which value is being
  entered (title, icon, and whether decimals are allowed — reps and time are whole numbers). Do not
  reintroduce a system-keyboard `TextField` for any numeric measure. The **note is the sole
  exception** — free text has no number-pad equivalent, so `SessionSetNoteSheet` uses a `TextEditor`
  and the system keyboard. Do not extend that sheet to numbers.
  `SessionSetInput` carries the entered values up via
  `onLog`; the screen's `log(_:for:)` writes them through `manager.completeSet(...)` and starts the
  rest timer **only on first completion**, never on an edit. Button reads "Complete Set" then
  "Update Set", and is enabled once any value is entered (or BW is selected).
  `onRemoveLog` → `manager.uncompleteSet(exerciseId:setId:)` clears `isCompleted` and
  all performed values, and the overlay resets its fields back to the target.
  An all-zero `Tempo` is the builder's empty default and is treated as absent throughout
  (`Tempo.isEmpty`) — stepping a tempo back to 0–0–0–0 stores `nil`, not a tempo of zero. Inputs seed once
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
  **Every option is always offered, whether or not the template prescribed it** — all four measures
  (`SessionSetMeasure.allCases`), plus tempo and note. A card the set never used draws "—" rather
  than vanishing. This replaced a `visibleMeasures` filter that showed reps/time/distance only when
  the template or record had them: a measure the prescription omitted is still one the user may have
  performed (a vest, a dumbbell, a loaded carry), and **a card that appears only sometimes is a card
  the user never learns is there.** Do not reintroduce the filter.
  Tempo and note are full-width cards below the grid, not cells inside it — four tempo phases and a
  sentence of text both need the width. `SessionSetEditTarget` (`.measure` / `.tempo` / `.note`)
  routes the single `.sheet(item:)` to the right sheet and carries its detent height.
  `targetText(for: .weight)` carries its unit because
  the prescription may be in one the session cannot log — "(80 % of 1RM)" beside a logged 100 kg is
  the reference the user is working from — so `comparableValue` re-renders the performed weight the
  same way before comparing, or the unit alone would read as a difference. When the session is not
  active the cards read from the record, not the seeded inputs: a set left unlogged in a finished
  session must show "—", never the target it never met.
- **A session never writes back to the template.** Tempo and note used to be read-only prescriptions
  off `WorkoutSetModel`; they are now editable, and the edit lands on `WorkoutSetRecord.tempo` /
  `.note` as *performed*. `WorkoutSetModel` keeps saying what the coach asked for — the template is
  reused on later days, so editing it from a session would silently rewrite next week's workout.
  Both cards therefore show two things: the performed value, and the prescription beneath it
  (bracketed target for tempo, a `target`-icon line for the note) **only when the two differ**, the
  same rule the measure cards use. Both are carried on `SessionSetInput` and persisted by the same
  "Complete Set" / "Update Set" press as the measures — they are not separately saved.
  `canLog` deliberately ignores them: a note alone must not mark a set completed, or it would count
  toward the session's sets-completed stat without anything having been performed.
  `Tempo` gained a memberwise `init` and `isEmpty` for this.
- **Seeding the overlay reads a logged set wholesale — never field-by-field.** `seedInputs()`
  branches once: `seedFromRecord(_:)` for a set with `isCompleted`, `resetInputsToTarget()` for
  everything else. It must not fall back per field (`record?.weight ?? templateWeight`), because a
  set logged with the weight cleared stores `weight: nil`, which per-field fallback cannot tell
  apart from a set never logged — so the template's number reappeared on the overlay while the pill,
  which already read wholesale (`SessionSetPillValue.values`), correctly showed none. **The two must
  agree.** This bug has now appeared twice, first for tempo and then for all four measures; treat
  any `record?.x ?? setModel.x` in the seeding path as the same defect.
  Units are the one exception — a unit qualifies a value rather than being one, so an absent
  `weightUnit` / `distanceUnit` falls back rather than leaving a number that cannot be rendered.
  The note is never seeded from the prescription in either branch: it records how the set went, and
  pre-filling it with the coach's instruction would put words in the user's mouth and store them as
  their own.
- **Weight unit is chosen in the session, not inherited.** `WeightUnit.loggable` is `[.kg, .lbs, .bw]`
  — `% of 1RM`, `% of BW` and `Max` are *prescriptions* (relative to a number the session doesn't
  hold, or an instruction), so they describe a target and are never stored against a performed set.
  `SessionSetInput.weightUnit` carries the choice and `log(_:for:)` passes it straight through, so
  **do not re-default the weight unit from the template.** Previously it did, storing e.g.
  `weight: 100, weightUnit: .percent1RM` — rendered as "100 % of 1RM".
  `WeightUnit.carriesValue` is false for `.bw` / `.max`: those label a
  set on their own, so selecting BW clears and hides the number pad and stores `weight: nil`.
  The target's weight only seeds the field when the session logs in the unit the target was written
  in (`targetWeightInput`).
- **Distance unit is chosen in the session too** — m / km / mi, `DistanceUnit.allCases`, the same
  three `MyDayWorkoutBuilderDistanceScreen` offers and drawn the same way (short label over
  `fullName`). It rides on `SessionSetInput.distanceUnit`; `log(_:for:)` no longer derives it from
  the template, so a 400 m target logged as 0.5 km stays 0.5 km. `targetText(for: .distance)` now
  carries its unit for the same reason weight does, and `comparableValue` re-renders the performed
  distance with its unit before comparing, or the unit alone would read as a difference.
  Switching unit **keeps** the entered number (type "5", then pick km) — unlike the builder screen,
  which clears it, because there picking the unit is step one.
- **Time has no unit in the model and must not gain one.** `WorkoutSetModel.time` and
  `WorkoutSetRecord.time` are both a plain second count, exactly as `MyDayWorkoutBuilderTimeScreen`
  stores them — that screen has no unit picker at all, it steps a total in seconds and draws it as
  `Xm Ys`. `SessionTimeUnit` (`sec` / `min`) is **entry only**: it decides what the number on the
  pad meant and converts to seconds before storage. Whole numbers in both units — decimals are off
  for time because "1.30 min" reads as 1m 30s but means 78 seconds, so 90 seconds is 90 `sec`.
  Seeding picks the unit back: a clean number of minutes seeds as minutes ("3 min", not "180 sec").
  `SessionTimeUnit.display` renders `1m 30s` everywhere a time appears on a card, so
  `cardUnitLabel(for: .time)` is nil — the value carries its own units.
  `SessionSetPillValue.formatTime` keeps its own tighter `1m30s` for the 72pt pill.
- **One unit picker, three unit types.** `SessionSetValueSheet` flattens whichever of
  `WeightUnit` / `DistanceUnit` / `SessionTimeUnit` the measure uses into `[SessionSetUnitOption]`
  (id, label, optional `fullName`, `carriesValue`) and draws a single picker. The three enums share
  no protocol but need the same picker. An option with no `fullName` renders the label-only 40pt
  button the weight picker has always had; one with a `fullName` gets the 52pt two-line button from
  the builder. Reps is the only measure with no picker, and so the only 560pt detent.
- **Set pills show at most two values** (`SessionSetPillValue.values(for:record:)`), in priority
  order reps → weight → time → distance. A set carrying all four overflows the 72×88 frame and
  clips the text top and bottom. Pills take the `WorkoutSetRecord`, not just the `WorkoutSetModel`,
  and a logged set is read **wholesale** from the record — never merged field-by-field with the
  target, or logging bodyweight would resurrect the target's number under a `BW` unit.
  `SessionSetPillPlaceholder` renders the same values so the slot it holds stays the right size.
- **Quick-complete: the pill's circle is its own tap target.** Tapping the circle logs the set at
  its prescribed values without opening the overlay — performing a set exactly as written is the
  common case, and it should not cost a tap, a hero animation and a button press. The rest of the
  pill still opens the overlay. The circle carries its own `.onTapGesture`, which SwiftUI dispatches
  before the pill's, and is widened to `.frame(width: 44)` — **width only**: the pill is a fixed
  72×88 and a two-value set already fills it, so growing the target vertically pushes the text into
  the clip. `SessionSetPill.onQuickComplete` is `nil` whenever the tap is not offered and the circle
  then falls through to `onTap` rather than swallowing the tap. The circle is tinted
  `Color.darkColor.opacity(0.55)` while live, because otherwise nothing tells the user it does
  anything the rest of the pill does not.
  `MyDayWorkoutSessionExerciseCard.canQuickComplete` decides per set: session running, not finished,
  **not already logged**, and something prescribed to log. **Re-tapping a logged set does not toggle
  it off** — a set may hold values the user typed, and one stray tap on a 44pt target would discard
  them silently; un-logging stays behind the overlay's deliberate "Remove log". A set with nothing
  prescribed falls through to the overlay rather than being marked complete while empty, mirroring
  the overlay's disabled button.
- **`SessionSetInput.target(for:)` is the one definition of "the prescription as a performed set".**
  Quick-complete logs through it, so it must stay in step with
  `SessionSetDetailOverlay.resetInputsToTarget()` feeding `input` — the same idea in two shapes, one
  resolved and one as editable text. A set logged by either path has to come out identical. It
  applies the same rules the overlay does: weight only carries over when the prescribed unit
  survives `WeightUnit.loggableDefault` unchanged (so `% of 1RM` logs reps and no load), the
  distance unit only rides along when there is a distance, an all-zero `Tempo` stores `nil`, and the
  **note is never seeded from the prescription**. `isLoggable` mirrors the overlay's `canLog`.
- **`log(_:exercise:set:)` on the session screen is shared by both paths** — the overlay's
  "Complete Set" and the pill's circle. It takes the exercise and set rather than a
  `SessionSetDetail` so the quick path need not invent an `index`, and reads `wasLogged` from
  `manager.setRecord(...)` rather than a passed-in record, the manager being the only current
  source. The rest timer still starts on first completion only.
- **Session screen nav is custom — the system bar is hidden.**
  `NavBarHidingHostingController` (a `UIHostingController` subclass) hides the nav bar in
  `viewWillAppear` and restores it in `viewWillDisappear`, mirroring `MyDayBoundaryViewController`.
  **Nothing in it is screen-specific** — the template detail screen uses it too. It and
  `MyDayWorkoutNavBar` were renamed from `WorkoutSessionHostingController` /
  `WorkoutSessionNavBar` when the second screen adopted them; host any screen that needs the bar
  gone rather than writing a second one.
  **Reason: a `UINavigationBar` is a sibling view owned by the `UINavigationController`, drawn above
  the hosting controller's view, so the set detail overlay could never dim or cover it** — the hero
  card was structurally boxed in below a white bar. Do not reinstate `.navigationTitle` /
  `.toolbar` on this screen. Hiding the bar also disables the swipe-from-edge pop, so the controller
  takes over `interactivePopGestureRecognizer.delegate` and allows the gesture whenever the stack has
  more than one VC — losing swipe-back would contradict the whole point of the screen.
  `MyDayWorkoutNavBar` draws back / title / `⋯`, and `WorkoutSessionFinishBar` pins "Finish
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
- **The `⋯` menu and its confirmation are custom cards, not system controls.** Both are
  `WorkoutSessionDialogOverlay`, a centred card driven by one `WorkoutSessionDialog` state
  (`.options` / `.confirmCancel`). The system `Menu` and `confirmationDialog` were dropped because
  both fought the screen: a `Menu` anchors to the bar button and brings system chrome that reads as
  a different app, and a `confirmationDialog` slides up from the bottom edge — exactly where
  `WorkoutSessionFinishBar` sits — putting the destructive action under the thumb in the same place
  as "Finish Workout". **One overlay with two states, not two overlays**: tapping "Cancel Workout"
  in the menu swaps the card inside the same backdrop, so the confirmation *replaces* the menu
  rather than stacking a second dim layer on it. Presented from `.overlay { }` for the same reason
  the set detail overlay is — the system nav bar is hidden, so only an overlay can dim over
  `MyDayWorkoutNavBar`. The bar raises intent only (`onOptions`) and owns no menu of its own.
  In the confirmation, **"Keep Going" is the filled button and "Cancel Workout" is tinted**: the
  destructive option comes first because it is what the user came for, but the safe choice is the
  one the eye lands on.
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

## Workout Completion Rules
Three guards on what counts as a finished workout. All three protect the same thing: a completed
session is a claim that work was performed, and it is read by stats now and by a coach later.

- **A completed workout cannot be removed from the day.** `removeWorkoutFromDay` guards on
  `entry.status != .completed`, and `DailyWorkoutCard` hides the `⋯` entirely for a completed entry
  — not just the delete row, because "Start Workout" is equally meaningless for work already done
  and the sheet would open offering nothing. The card body still taps through to the read-only
  completed view. The manager guard is what makes this an invariant rather than a UI convention the
  next caller can breach.
- **A session cannot be finished with zero sets logged.** `WorkoutSessionFinishBar(isEnabled:)` is
  driven by `manager.totalSetsLogged > 0`. Finishing an empty session would write a
  `CompletedWorkoutSession` recording no work, which still counts toward the day and would tell a
  coach the workout was done.
- **"Complete Workout" is disabled until a session RPE is picked** (`canComplete` on
  `WorkoutSessionSummaryScreen`). RPE is the one thing on that screen that cannot be recovered
  later — notes can be added to a record, but how hard it felt is only answerable now, and
  `workload` (duration × RPE) does not exist without it.

All three use the disabled styling already established by `SessionSetDetailOverlay`'s log button:
`Color.secondary` label on `Color(UIColor.tertiarySystemFill)`, with `.easeInOut(0.15)` on the
enabled flag. **Keep new gated buttons in step with it** rather than inventing a second look.

## Session Screen — What's Not Yet Built
- Rest timer banner is hidden behind the set detail overlay, which stays open after logging.
  Quick-complete sidesteps this rather than fixing it — logging from the pill's circle never opens
  the overlay, so the banner is visible on that path. Logging *through* the overlay still hides it.

## Exercise Stats Raw Logs
Two things are written when work is recorded, and **both paths write the same two things**:
1. the whole day document — `Users/{uid}/MyDay/{yyyy-MM-dd}`, `setData(merge: true)` with the entire
   `MyDayFullDayModel`. Every log rewrites the whole day, workouts included.
2. a raw stats log — `Users/{uid}/ExerciseStats/{exerciseID}/RawLogs/{logID}`, holding an
   `ExerciseStatsSaveModel` (id, exerciseID, exerciseName, dateComplete, reps, weight, time).

An exercise logged on its own goes through `MyDayManager.addNewCompletion` → `MyDayAndStatSaver`,
which writes both together. A **set logged inside a workout session** writes the day through
`workoutSaver` (via `onEntryUpdated`) and the raw log through `workoutStatsSaver`, wired from
`WorkoutSessionManager.onSetLogged` / `.onSetUnlogged` in `MyDayCoordinator`. Work done in a session
and work logged on its own are the same work — **stats that counted only one of them would depend on
how the user happened to record it.**

- **`WorkoutSetRecord.getStats(...)` and `ExerciseCompletions.getStats()` must stay in step.** They
  write to the same collection, so anything one records that the other does not is a gap that opens
  and closes with the logging route. Weight normalisation is shared as
  `WeightUnit.kilograms(_:unit:)` — kg passes through, lbs converts, and `% of 1RM` / `% of BW` /
  `Max` / `BW` are **prescriptions or bodyweight, not loads, so they normalise to 0**, as does an
  absent unit. Do not re-inline that conversion at either call site.
- **The raw log id is `"{sessionId}-{setId}"`** (`WorkoutSetRecord.statsLogId`), never the set id
  alone. Set ids are only unique *within an exercise*, and a template reused next week repeats them
  exactly — keying by set id would have each session overwrite the last one's logs. It is derived,
  not stored, so un-logging can address the log it already wrote; `sessionId` survives relaunch
  because `WorkoutSessionManager.init` restores it from `sessionRecord.id`.
- **Logs are written per set, not at finish**, mirroring the exercise path and so surviving a session
  the user leaves and never finishes. Re-logging a set rewrites the same document, so an edit
  corrects the log rather than adding a second one.
- **Three things delete a raw log, and all three must**: `uncompleteSet` (only when the set was
  actually logged), `cancelSession` (which discards the whole record — it fires before the session id
  is regenerated, since that id addresses the logs), and `removeWorkoutFromDay`
  (`deleteWorkoutStats(for:)`). Removing the workout is the second way a session's sets stop
  existing, and it is offered whatever the status; logs left behind would count toward stats for a
  workout the user can no longer see.
- `finishSession` writes no logs — the sets were logged as they happened.

## Completed Workout Sessions
A finished session is written as a document of its own, to **two** paths, on `finishSession` only —
unlike raw logs, which are per set, because a session only means something complete:

```
WorkoutSessions/{sessionId}              <- analytics, every user
Users/{userId}/WorkoutSessions/{id}      <- that user's workout history
```

Both hold the **same** `CompletedWorkoutSession`; only the analytics copy ever gains `deletedAt`.
The session still lives embedded in the day (`DailyWorkoutEntry.sessionRecord`) — that is what the
day screen reads. These documents exist so that "what workouts have been done" does not mean reading
every day document of every user.

- **Both writes go in one `WriteBatch`** (`FirestoreCompletedWorkoutSessionSaver`). Two identical
  copies that can silently diverge are worse than one — a half-succeeded write would leave the
  collections disagreeing with nothing to say which was right.
- **`userId` is the performer, injected into `WorkoutSessionManager.init(entry:userId:)` from the
  coordinator.** It is emphatically **not** `entry.template.createdBy`, which is the template's
  *author* — for a coach-programmed workout that is the coach, and every session would be filed
  under them. `finishSession` used to build `WorkoutSessionModel` that way; that was a latent bug
  that only stayed harmless because the return value is discarded.
- **The deletion path is currently unreachable — deliberately, and it is kept anyway.**
  `FirestoreCompletedWorkoutSessionDeleter` hard-deletes the user's copy and marks the analytics copy
  `deletedAt`, in one batch. Its only caller is `removeWorkoutFromDay`, which now refuses `.completed`
  entries (see *A completed workout cannot be removed* below), and `cancelSession` cannot reach a
  completed session either. So nothing sets `deletedAt` today. It is retained because a session
  document with no way to retract it is a worse position to be in than unused code, and because a
  deletion that was never recorded cannot be reconstructed afterwards. **If a "delete a completed
  workout" path is ever added, this is already built** — and Function 2 in
  `CLOUD_FUNCTIONS_WORKOUT_SESSIONS.md` is what retires the coach-facing copy.
- **`updateData` failing on a missing analytics document is intended.** The copies are only written
  together, so either both exist or neither does; a session completed before this shipped has
  neither, and the batch failing changes nothing. Do not soften it to `setData(merge:)` — that
  writes a stub document holding only a `deletedAt`.
- **Forward-only, by decision** — sessions finished before this shipped are not backfilled and stay
  readable in their day documents.
- Requires Firestore rules permitting the new collections. **Rules are not in this repository** —
  a client write to a new top-level collection is denied until they are deployed.

`WorkoutSessionModel` (`MyDayWorkoutModel.swift`) is dead — built by `finishSession`, never read.
Left in place; `CompletedWorkoutSession` is the model that is actually persisted.

### These writes are remote-only, and that is a decision
Unlike templates (`WorkoutTemplateSaver` → `WorkoutTemplateSyncer` → `SyncQueueWorkoutTemplateUploader`
→ `WorkoutTemplateSyncService`, which keeps a `Documents/PendingSync` queue and flushes on reconnect),
the session documents and the exercise raw logs have **no local copy and no retry**. A failed write is
simply lost.

Accepted deliberately, because the data is not: every completed session is still in the day file at
`Documents/MyDays/{uid}/{date}.json` as `workouts[].sessionRecord`, and **nothing yet reads these
collections** — the history screen does not exist and analytics is external. A missing document
therefore costs nothing today and can be backfilled from local day files at any point. Firestore's own
disk-backed mutation queue covers ordinary offline writes.

**Revisit when the workout history screen is built** — that is when a missing document first becomes
visible to a user, and when it will be clear whether a sync queue or a one-off backfill is the answer.
Two caveats that survive until then: permission-denied is a **hard** failure the SDK never retries
(so deploy the rules before trusting the collection), and `#if EMULATOR` sets
`isPersistenceEnabled = false` (`AppDelegate.swift:41`), so emulator builds have no offline queue at
all. The exercise raw logs have had this same gap since long before the workout ones — fix both
together or neither.

## Coach-Assigned Workouts — designed, not built
The data model is prepared for coach assignment; **none of the assignment feature exists yet.** What
is in the code today is provenance: `DailyWorkoutEntry.assignedBy` / `.assignmentId` and the same
pair on `CompletedWorkoutSession`, both optional, both `nil` for everything written so far (which is
correct — those workouts were self-started). They are carried from the entry into the completed
session by `WorkoutSessionManager.completedSession(from:endedAt:)` and nothing else reads them.

The agreed design, so that whoever builds it does not re-litigate it:

- **Assignments live at `Users/{athleteId}/AssignedWorkouts/{id}`**, written by the coach. A coach
  never touches `Users/{uid}/MyDay/*` — that document holds wellness and RPE, and Firestore rules
  cannot scope a write to one field, so write access there would expose everything on it.
- **Accepting materialises a `DailyWorkoutEntry`** carrying `assignedBy` / `assignmentId` and a
  **snapshot of the template taken at accept time**, not at assign time. From that moment it is an
  ordinary entry: same session flow, same raw logs, same completed-session document.
- **The date is a parameter of acceptance, not an edit.** The athlete picks which day to put it on;
  the assignment keeps the coach's original `assignedDate` alongside an `acceptedForDate`. This keeps
  the coach's record of intent intact, makes "assigned Monday, done Wednesday" legible for free, and
  avoids coach and athlete writing the same fields. Open question, deliberately: whether a coach may
  edit an assignment *after* acceptance — leaning no, since the entry's snapshot would silently
  disagree with it, making withdraw-and-reassign the honest version.
- **Completion still writes to `WorkoutSessions` / `Users/{uid}/WorkoutSessions`** — the same single
  pair as a self-started workout, with `assignedBy` set. A **Cloud Function** triggers on create,
  and when `assignedBy` is set writes the coach-facing projection and pushes to that coach.
  **Do not add a parallel `CompletedAssignedWorkouts` client write.** It was considered and rejected:
  it would make the athlete's own history a union of two collections forever, let the two shapes
  drift, and duplicate the soft-delete logic. Server-side fan-out gets the same structural privacy
  boundary — the coach reads only the projection, never the athlete's sessions — and a projection the
  client cannot fabricate.
- **Assigned workouts appear in MyDay**, in their own section of the scroll, so the date strip stays
  the calendar. They are read from the assignment collection and merged **at display time** — the day
  document is not written until the athlete accepts. **De-dupe rule: if a day entry carries an
  `assignmentId`, that assignment must not also render as its own row.** Once accepted, a workout
  stays in its section rather than moving; the section says who asked for it, which does not change
  when it is done, and cards jumping between sections reads as a glitch.
- Assignments are **inherently remote** — they originate on another device — which makes them the
  first thing on the MyDay screen that cannot be answered from local storage. Cache them to disk on
  fetch. Reads that are remote-only while everything around them is local-first is the exact bug
  that emptied the workout library.
- Raw logs deliberately gain nothing: a coach reads set detail from the completed session's
  `exerciseRecords`, so `ExerciseStatsSaveModel` stays the athlete's own stats record.

**Blocked on: the coach↔athlete link living in Firestore.** `CoachPlayers/{coachId}` and
`PlayerCoaches/{playerId}` are **Realtime Database** paths (`FirebaseInstance`), and Firestore rules
cannot read RTDB — so there is currently no way to express "this coach may write to this athlete's
assignments". Deferred by decision; nothing above is enforceable until it is resolved.

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
