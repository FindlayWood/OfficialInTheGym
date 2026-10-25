# Custom Exercises — Plan

Users create exercises the catalogue lacks. Each one is private to its creator, and you review it
to decide whether it joins the catalogue. DISCOVER users can suggest corrections to a catalogue
exercise's muscle groups and movement patterns, and every suggestion goes through you.

**Status: designed 24 October 2026, built 25 October — every step.** Part 1, step 1 and the admin
app's merge fix are merged and deployed. Steps 2–11 are committed on branches in five repos (the
app, functions and scripts on `custom-exercises`; the dashboard and admin app on
`complete-exercises`) and are **not merged, deployed or released**. See *Rollout* at the end.

## Decisions — agreed, do not relitigate
- **A custom exercise is complete or it is not saved.** Name, category, at least one muscle group,
  at least one movement pattern, compound, unilateral. These are the fields a catalogue exercise has
  (`InTheGym-Admin`'s `Exercise`), so an approved one needs nothing filled in afterwards. The
  admin app's `bodyArea` is a copy of `category` and is not asked for.
- **Written like workout templates: two paths, two writers, one decorator.**
  `Users/{uid}/CustomExercises/{id}` is the creator's copy, which the picker reads.
  `CustomExercises/{id}` at the top level is the review copy. Each writer knows one path, and a
  decorator that knows no paths composes them (see *Composition root mechanics*).
- **Never written to `Exercises/`.** Any write there fires `discoverExerciseCard` and publishes a
  DISCOVER card.
- **Approving keeps the id.** The dashboard writes `Exercises/{id}` with the custom exercise's own
  id. The creator's raw logs, `ExerciseStats`, templates and day files already point at that id,
  so their history becomes catalogue history and nothing is migrated. **Ids are plain UUIDs with no
  `custom-` prefix**; the server tells the two apart by where the document is.
- **A rejected exercise stays private to its creator.** Rejection only means it never joins the
  catalogue. Taking it away would break their logs and templates.
- **Body-part votes on DISCOVER are suggestions only.** They never change `Exercises.muscleGroups`
  or `movementPatterns` themselves; you review and apply them. Those two fields decide every
  user's training balance.
- **Review lives in both the SwiftUI `InTheGym-Admin` app and the React `inthegym-dashboard`.**
  Keep it minimal in both: the dashboards are due a fuller rework soon.
- **Free.** Not a pro feature. Logging is free, and a custom exercise is part of logging.
- **The name cannot be changed once saved.** Raw logs, templates and `ExerciseStats` each store the
  name they were written with, so a rename would split one exercise's history across two names.
  The form says so beside the name field.
- **Every raw log records the muscle groups and movement patterns it was counted under** (step 1).
  Training balance must not depend on what the exercise says when the log is later edited or
  deleted.

## Before anything else — the admin app wipes tags
`InTheGym-Admin`'s `FirebaseService.saveExercise` calls `setData(from: exercise)` **without
merge**, which replaces the whole document. Every exercise edited there loses the curated `tags`
DISCOVER seeded onto it (`SeedExerciseTags.py`), and with them its base tags. Approval writes
through the same kind of call, so **fix this first**: `setData(from:merge: true)`, or `updateData`
of the form's own fields. The React dashboard uses `updateDoc`, which merges, but its
`UploadExercise` creates exercises with only `id`, `name` and `category`, so the catalogue keeps
gaining exercises that add nothing to training balance. Its create form needs the full field set
too.

## Steps

### 1. Server — one exercise lookup — **built**
The app side is on `exercise-model`. The functions side is on `log-body-parts` in
`InTheGym-CloudFunctions`, as `MyDay/DailyStats/LogBody.ts`. That branch also fixed a worse bug:
Update and Delete wrote the volume maps with `update()` and a nested map, which wiped the day's
other muscle groups on every edit or delete. Days already affected are not repaired; a backfill
over `RawLogs` would rebuild them.

`DailyStatsFromRawLogCreate`, `…Update` and `…Delete` each read `Exercises/${exerciseID}`
separately. Replace all three with one helper, `exerciseBody(db, exerciseId)`, which reads
`Exercises/{id}` and then `CustomExercises/{id}`. This is the only server change needed for a
custom exercise to count toward training balance. Because it reads the **top-level** copy, it also
covers someone who saved a public workout containing another user's custom exercise: their logs
carry that id, and the lookup finds it. `ClipCard` also reads `Exercises/{id}`, so a clip recorded
on a custom exercise has no exercise on its card. Decide whether it uses the same helper.

**Logs carry their own body parts — decided.** Update and Delete used to look the exercise up
again when they ran, not as it was when the log was counted. Once muscle groups are edited (step
10), deleting an old log would take volume away from the *new* groups, and some would go negative.
So:
- `ExerciseStatsSaveModel` gains optional `muscleGroups` / `movementPatterns`, written at
  completion through **both** `getStats` paths. They must stay in step, as everything on that pair
  must.
- **An exercise logged on its own** takes them from the picked `Exercise` (part 1 decodes them).
- **A set logged inside a workout** has only the template's `WorkoutExerciseModel`, which carries
  name and category but no body parts. `WorkoutBuilderManager.buildTemplate()` copies them onto
  `WorkoutExerciseModel` as optional fields, the same way it already copies `exerciseName`.
  Templates built before that have none.
- **The three triggers read the log's own copy** and fall back to `exerciseBody` only for a log
  without one: everything already logged, and sets from older templates. Create and Update must
  resolve a log identically, or the Update diff moves volume between groups.
- This must ship before the suggestions queue (step 10) lets anyone edit muscle groups.

### 2. MyDayKit — model — **built**
- `Exercise` gains optional `isCompound` / `isUnilateral`, optional for the same reason as part 1:
  every existing day file embeds an `Exercise`.
- `CustomExercise` is the stored shape: the catalogue fields plus `createdBy`, `createdAt`,
  `updatedAt`. It converts to `Exercise` for the picker.
- `status` (`pending` / `approved` / `rejected` / `duplicate`, plus `duplicateOf`) exists only on
  the top-level copy, and only the dashboard writes it.

### 3. MyDayKit — muscle groups and movement patterns to choose from — **built**
`ExerciseMuscleGroupsLoader` / `ExerciseMovementPatternsLoader` in MyDayKit, returning
`ExerciseMuscleGroup` / `ExerciseMovementPattern`. Named apart from StatsKit's
`MuscleGroupsLoader` / `MovementTypesLoader`, which read the same collections: the app's
`RemoteMuscleGroupsLoader` / `RemoteMovementTypesLoader` now conform to both, so there is one
reader per path. `CachedExerciseMuscleGroupsLoader` / `…MovementPatternsLoader` wrap them with a
disk cache at `Documents/ExerciseBody/` (`ExerciseBodyListStoreLocation`): cache first with a
refresh behind it, so the form works offline. Not yet built in `MyDayKitComposition` — the form
(step 6) is their first consumer.

### 4. Write path — mirror the template pipeline — **built**
`CustomExerciseSaver` → local `FileManagerCustomExerciseWriter`
(`Documents/CustomExercises/{uid}/{id}.json`, its path from one `CustomExerciseStoreLocation`) →
sync queue → `UserAndTopLevelCustomExerciseUploader(user:topLevel:)` over
`FirestoreCustomExerciseUploader` and `FirestoreTopLevelCustomExerciseUploader`. It is saved
locally first so an exercise made offline can be picked at once. Built in `MyDayKitComposition`,
user id injected.

As built: MyDayKit's `CustomExerciseUploading` is the one protocol at every layer, and create,
edit and archive are all the same whole-exercise write. `CustomExerciseSyncer`,
`SyncQueueCustomExerciseUploader` (`Documents/PendingSync/customExercises_{uid}.json`) and
`CustomExerciseSyncService` mirror their template twins. **Both Firestore writes merge**, because
`status` is never encoded and a replace would delete the server's copy of it.
`LocalUserDataEraser` removes the local store and the queue. The saver is exposed as
`MyDayKitComposition.customExerciseSaver` for step 6.

**Fixed with it, for templates too:** both sync services used to be locals that nothing held after
launch, so a write queued offline was never retried. `MyDayKitComposition` now holds them, the tab
bar holds the composition, and sign-out stops them (see CLAUDE.md, *Local stores are scoped by
user id*).

### 5. Read path — the picker — **built**
- An `ExerciseLibrary`, like `WorkoutLibraryManager`, merges the catalogue, the local custom store
  and the remote custom store **by id, catalogue first**. Once an exercise is approved the
  catalogue holds the same id, and the user's copy disappears from the picker. Part 1's id-keyed
  rows are what make this safe.
- Custom exercises carry a small "Yours" marker.
- Two ways in: a **Create exercise** button in the picker, and **Create "<search text>"** in the
  empty search state, with the name filled in. Logging and the workout builder share
  `MyDayExerciseListView`, so both get it.

As built: `ExerciseLibrary` is the merge, a value with tests (`ExerciseLibraryTests`): catalogue
wins by id, the two custom stores union with the newer `updatedAt` winning and remote winning a
tie (it alone carries `status`), archived exercises left out. `ExerciseManager` takes
`customLocal:` / `customRemote:` (`FileManagerCustomExerciseFetcher`,
`FirestoreCustomExerciseFetcher`) and reads all three at once, each allowed to fail alone. Both
Create entry points call the picker's `createExercise` closure, which is `nil` until step 6 wires
the form, so they are not drawn yet.

### 6. Create screen — **built**
One form in MyDay's builder vocabulary. Everything required; Save disabled until it is all
filled (account creation's `canAdvance` pattern, gated button styling from
`SessionSetDetailOverlay`). Muscle groups and patterns are multi-select chips from step 3.
Compound and unilateral are two-option pickers with neither preselected: a preselected toggle
would count as answered when it was not.

As built: `CustomExerciseFormScreen` on `CustomExerciseFormModel` (tests:
`CustomExerciseFormModelTests`), in `MyDayKit/MyDayKit/CustomExercises/`. Both coordinators take
`CustomExerciseDependencies` (saver, the two cached loaders, user id); `nil` leaves Create out of
the picker. Saving **replaces the form with the next screen** — reps when logging, sets when
building a workout — as if the exercise had been picked, so back cannot reopen the form and save
twice. The name is trimmed with spaces collapsed and capped at 60 characters; muscle groups are
grouped under their region; body parts are stored in the lists' order, not tap order.
`FlowLayout` moved out of `WorkoutSettingsSheet` into `MyDayKit/MyDayKit/UI/` so both share it.

### 7. Similar-exercise check — **built**
- **While typing the name**, list close catalogue and own-custom matches under the field ("Did you
  mean Bench Press?"), each one tappable to pick it instead. MyDayKit declares a
  `SimilarExerciseFinder`; the composition root answers it with `DiscoverExerciseMatcher`, made
  `public` (forgives one typo). There is still one matcher, as with `TagNormalizer`.
- **On Save**, a second check on the body: same movement pattern plus overlapping muscle groups,
  under a different name. Shown once as a confirmation ("Similar to Romanian Deadlift. Save
  anyway?"), never a block.

As built: `DiscoverExerciseMatcher` is public with a generic `search(_:in:name:limit:)`, and the
app's `DiscoverSimilarExerciseFinder` answers MyDayKit's `SimilarExerciseFinder` with it. Name
matches (up to 3, from 3 characters) show under the name field as "Already in the list — use one
instead?", each with a Use button. `ExerciseBodySimilarity` is the body check (tests:
`ExerciseBodySimilarityTests`); `saveOrAskFirst()` asks on the first Save only, in
`CustomExerciseSimilarDialog` — Use one of up to 3 matches, Save Anyway (the filled button), or
Keep Editing. Using an existing exercise from either check carries on as if it had been picked,
saving nothing. To let that card dim the whole screen, the form now hides the system bar
(`NavBarHidingHostingController` + `MyDayWorkoutNavBar`), as the session and template screens do.

### 8. Server — rules, index, deletion — **built**
- Rules:
  - `Users/{uid}/CustomExercises`: the owner reads and writes.
  - `CustomExercises/{id}`: the owner creates it with `createdBy == uid` and **no `status`**, and
    may update the catalogue fields only while it is pending (or has no status yet). **No client
    ever writes `status`**: the app's model never encodes it, so a create carrying `pending` would
    be the one exception, and a late edit or archive would then put a reviewed exercise back in
    the queue. A function sets `pending` on create instead, beside the one that mirrors `status`
    onto the user copy.
  - Archiving (`archivedAt`) is allowed on both copies whatever the status — it is how a pending
    exercise is withdrawn, and harmless once reviewed. An edit queued while pending and flushed
    after review is denied for good, so the sync service should drop a write the rules reject
    rather than retry it forever.
  - Reads: the owner and admins.
- Index: `CustomExercises` on `status` + `createdAt`.
- Deletion module in `functions/src/Account/`: delete the user's copies, plus their top-level
  documents that are `pending` / `rejected` / `duplicate`. Approved ones are catalogue by then and
  stay.

As built, in `InTheGym-CloudFunctions` (branch `custom-exercises`):
- **Rules** (`isValidCustomExercise` and friends): every catalogue field required and typed, the
  category one of `ExerciseCategory`'s raw values, at least one muscle group and pattern, no other
  keys. Create without `status`; no client change to `status`, `name`, `id`, `createdBy` or
  `createdAt`; body fields only while `pending` (or no status yet); `archivedAt` always; no client
  deletes. The review copy is read by its creator and catalogue editors (`canEditCatalogue`), who
  may also update it. Tests in `test/Rules/firestoreRules.test.ts`.
- **`syncCustomExerciseStatus`** on `CustomExercises/{id}`: sets `pending` on arrival, `withdrawn`
  when archived while pending (a new status, so the `pending` queue drops it), and mirrors the
  status onto `Users/{createdBy}/CustomExercises/{id}`. This is the "function mirrors status" of
  *Also decided*. Tests in `test/CustomExercises/`.
- **Index**: `CustomExercises` on `status` + `createdAt`, both ascending (oldest first).
- **Deletion**: `deleteCustomExercises` removes the user's review copies except `approved`, called
  from `deleteAccount` after `deleteUserData`, which already takes `Users/{uid}/CustomExercises`.
- **App**: `CustomExerciseStatus.withdrawn`; `CustomExerciseSyncService` drops a queued write the
  rules refuse (permission denied) instead of retrying it forever.

**Deploy order matters:** these rules must be live before an app build that saves custom exercises
reaches users. Until then every upload is refused, and with the drop above it would be dropped from
the queue — the exercise survives only on that phone.

### 9. One complete catalogue exercise — dashboards and starting tags — **built**
An exercise created in either dashboard and an approved custom exercise (step 10) write the same
document, `Exercises/{id}`, and must come out identical. **Every catalogue exercise carries
every field**: `id`, `name`, `category`, `bodyArea` (a copy of `category`), `muscleGroups`,
`movementPatterns`, `isCompound`, `isUnilateral`, `dateAdded`, `dateLastEdit`, and `tags`.

- **The DISCOVER card is not the dashboard's job.** Any write to `Exercises/{id}` fires
  `discoverExerciseCard` (the card) and `discoverExerciseTags` (the tag directory). A dashboard
  writes a complete exercise and the server does the rest.
- **The React dashboard's `UploadExercise` writes `id`, `name` and `category` only.** Its
  create and edit forms gain the full field set, with muscle groups and patterns as multi-select
  from `MuscleGroups` / `MovementTypes`, and compound / unilateral with neither preselected, as in
  step 6. Its category values are wrong: it writes `upperBody` / `lowerBody`, but `ExerciseCategory`'s raw values are `upper_body` / `lower_body` / `core` / `cardio` / `full_body`, so the app's loader skips every exercise the React form has made. The form writes those raw values, gains `full_body`, and the exercises already written are corrected (`ExerciseAudit.py` lists unknown categories). The admin app's
  `Exercise` decodes every field as required, so an exercise the React dashboard made today does
  not load there.
- **Starting tags come from one server function, `seedExerciseTags`**, on `Exercises/{id}`
  writes. It unions the existing `tags` with the normalised `muscleGroups`, `movementPatterns`
  and `category` — the rule `SeedExerciseTags.py` applies today — capped at 20, and writes only if
  that changes them, so its own write ends the loop. Tags already on an exercise are never
  removed. **The rule then lives only in the function**: the script's derivation is retired, not
  kept alongside, and neither dashboard computes tags. Approving a custom exercise gets its tags
  the same way.
- `ExerciseAudit.py` reports any exercise still missing fields; run it after this ships.

As built:
- **Functions** (`InTheGym-CloudFunctions`, branch `custom-exercises`): `seedExerciseTags` on
  `Exercises/{id}`, with the rule in `Discover/Tags/CuratedExerciseTags.ts`
  (`curatedExerciseTags`) — existing tags first, then body parts and category, each through
  `tagRejection`, capped at 20, written only on change.
- **Scripts** (`InTheGym-Scripts`, branch `custom-exercises`, stacked on `emulator-body-parts`):
  `SeedExerciseTags.py` deleted.
- **React dashboard** (`inthegym-dashboard`, branch `complete-exercises`): the upload form asks for
  every field, with categories read from `ExerciseCategories` (so the values are right), and
  saves with a merge; `catalogueExercise.js` holds what complete means; incomplete exercises are
  outlined in the list with what they lack, which is how the old `upperBody` ones get fixed.
  **It had no sign-in**, so under the 25 October rules it could neither read nor write the
  catalogue — every page is now behind Firebase sign-in (`RequireSignIn`).
- **Admin app** (`InTheGym-Admin`, branch `complete-exercises`): Save needs every field; compound
  and unilateral start unanswered on a new exercise. Its loader still skips any document missing a
  field (`try?`), so exercises the React form made before this do not show there — fix them in the
  React dashboard.

### 10. Review — admin app and React dashboard — **built** (body suggestions queue moves to step 11)
- **Pending queue**, grouped by normalised name across users, so five people's "landmine press" is
  one decision.
- Each entry shows the creator's fields and the closest catalogue exercises.
- **Actions:**
  - **Approve**: edit the fields if needed, then write `Exercises/{id}` with the same id as a
    **merge**, and set status `approved`.
  - **Duplicate of X**: set status `duplicate` with `duplicateOf`. The creator's copy stays theirs.
  - **Reject**: set status `rejected`.
- **Body suggestions queue**: catalogue exercises whose votes (step 11) disagree with what is
  stored. Each shows the vote counts beside the current values, and an Apply button that merges the
  chosen values into `Exercises/{id}`.

As built — the review queue in both dashboards; the body suggestions queue is built with step 11,
since until votes exist it has nothing to show:
- **React** `ReviewCustomExercises.js` on `customExerciseReview.js`; **admin app** a Review tab,
  `CustomExerciseReviewView` / `…DetailView` on `CustomExerciseReviewViewModel`. Each dashboard
  keeps its own small copy of the grouping and "closest" rules — both are due a rework.
- **A group is one decision.** Approve writes the group's **oldest** submission to
  `Exercises/{id}` under its own id (merged, in one batch with the verdicts) and marks the rest
  `duplicate` with `duplicateOf` it. Duplicate-of and Reject apply to every submission in the group.
- **The name is locked at approval**; category, muscle groups, patterns and the two flags can be
  corrected first.
- **Closest** = a shared name word (3+ letters) scores 3, plus the shared muscle groups when a
  movement pattern is shared too.
- Creators are shown by `@username` from `Profiles`.
- The rules now allow `duplicateOf` to be present on a creator's merged write (never changed), or a
  creator could not archive an exercise reviewed as a duplicate.
- Verified on the emulator: submit → both copies `pending`; approve → both `approved`, and the new
  catalogue entry tagged by `seedExerciseTags`.

### 11. DISCOVER — showing and voting on body parts — **built**
- The exercise card projection gains `muscleGroups` / `movementPatterns`. The exercise page shows
  "Works: Chest · Triceps · Horizontal push". Display names come from the `MuscleGroups` /
  `MovementTypes` documents, never prettified ids.
- **Suggest a change** opens the same chip pickers as step 6, pre-filled with the current values.
  It stores one document per user, `Exercises/{id}/BodyVotes/{uid}` (their whole set, like
  `TagVotes`). Only fixed ids, never free text, so there is nothing to moderate.
- A function recounts the votes (a recount, never a delta, as every DISCOVER count is) into a
  server-owned `BodySuggestions/{exerciseId}`, which only the dashboard reads. **Nothing writes
  `Exercises` fields from votes.**
- Votes go into the deletion module too.

As built:
- **Functions**: `discoverExerciseBodyVotes` (on a vote) and `discoverExerciseBodySuggestions` (on
  the exercise) both run `syncBodySuggestions`: a recount, ids not in `MuscleGroups` /
  `MovementTypes` dropped, `proposed` = what at least half chose, `disagrees` = differs from what is
  stored. **Keep current** writes `dismissedProposal` with `disagrees: false` (the only fields a
  curator may write); while the votes still propose that, it stays out of the queue. The card
  projection carries `muscleGroups` / `movementPatterns` (cards only — not the tag directory's
  entries). Account deletion removes a user's `BodyVotes`; `firestore.indexes.json` exempts their
  `authorId`.
- **DiscoverKit**: `DiscoverBodyPartsSection` on the exercise page ("Works: Chest · Triceps · Push
  Horizontal", names from the lists), `DiscoverBodyPartsSheet` (chips; each tap saves the whole set
  once it has one of each, Done only dismisses), `DiscoverBodyPartsViewModel` (tests). Protocols
  `BodyPartsLoader` / `MyBodyVoteLoader` / `BodyVoteWriter`, answered in the composition root —
  names by MyDay's cached loaders, built for both compositions by `CachedExerciseBodyLoaders`.
- **Dashboards**: the body suggestions queue (moved here from step 10) — React
  `BodySuggestions.js`, admin app Suggestions tab — vote counts beside each choice, the majority
  preselected, Apply (merge into `Exercises/{id}`) or Keep current.
- Verified on the emulator: card carries body parts; a vote with an invented id counts only the real
  ones and joins the queue; applying removes it; keeping current keeps it out until the proposal
  changes.

## Rollout
Order matters — the app must not ship before the server it writes to.
1. Merge and deploy the functions repo: rules, indexes, and the functions `syncCustomExerciseStatus`,
   `seedExerciseTags`, `discoverExerciseBodyVotes`, `discoverExerciseBodySuggestions`,
   `deleteAccount`, `discoverExerciseCard`.
2. Rebuild existing exercise cards so they carry body parts:
   `python RebuildDiscoverCards.py <admin> exercises` from `InTheGym-Scripts`.
3. Fix existing incomplete catalogue exercises in the dashboard (the old `upperBody` ones).
4. Ship the dashboards; then the app.

### Also decided
- **The creator sees two statuses only: "In review" and "Added to the catalogue."** A rejected or
  duplicate exercise reads as simply theirs, with no verdict shown. A function mirrors the
  top-level `status` onto the user copy, so the client still never writes it.
- **Editable while pending, read-only once reviewed.** Category, muscle groups, movement patterns
  and the two flags can change while `pending`; the name never can. Edits go through the same
  composed writer, so both copies change together. Logs keep what they were counted under either
  way.
- **Delete is an archive.** It hides the exercise from the picker and withdraws it from review if
  it is still pending. Logs, templates and stats keep the id. An approved exercise is catalogue by
  then, so archiving the user's copy changes nothing they see.
- **No cap on submissions.** Revisit only if the review queue is abused.

## Open
Nothing. Everything above is decided; what is left is building it.
