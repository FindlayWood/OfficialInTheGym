# Readiness — Plan

Three features that belong together: **reminders** that bring people back to check in and rate the
day, **wellness over time** so check-ins become a trend, and **injuries** tracked day by day and
read against training load. Draft, 2026-11-09. **Step 1 is built** (on the `reminders` branch, not merged); the rest is not.

## What exists today
- **The check-in** is four 1–5 questions (`WellnessQuestion.all`: sleep, body, focus, mood) saved as
  `WellnessEntry` on the day, inside `Users/{uid}/MyDay/{yyyy-MM-dd}`. `readinessScore` is their mean
  on 0–1. **Nothing reads it after the day.** There is no history and no chart.
- **Day RPE** is `RPEEntry` (1–10) on the same day document. Same: written, never read back.
- **Schedules** (`SCHEDULES_PLAN.md`) are a day with no time (`ScheduleDay`), due on today only.
- **Notifications**: one local notification in the whole app, the trial reminder
  (`LocalNotificationTrialReminder`). The app never asks for permission at launch, by decision, and
  CLAUDE.md says not to promise a notification for something that does not send one.
- **The legacy Injury Tracker** (`InTheGym/InjuryTracker/`, `InjuryStatus/{uid}`) has had no entry
  point since PERFORMANCE moved. It is a status (fit / injured / rehabbing) and a recovery-time
  guess, with no day-by-day record. **Leave it and its data alone; this starts fresh**, as the jump
  tests did.

## Part 1 — Reminders (local notifications)

### What can be reminded
| Reminder | Default | Fires | Skipped when |
|---|---|---|---|
| Morning check-in | off | chosen time, chosen weekdays | today's check-in is done |
| Rate your day | off | chosen time (evening) | today's RPE is done, or nothing trained (optional) |
| Scheduled activity | off | see *Open questions* | that schedule is done, skipped or stopped today |
| Injury check-in | on while an injury is active | with the morning check-in | the injury was checked today |

Each has its own switch, time and weekdays. Plus a **quiet days** option (e.g. none on Sunday) and
one master switch. That is the customisation; it should not grow into a rules engine.

### How "skipped when" works with local notifications
A local notification cannot check anything when it fires. So:
- **Schedule individual one-off requests for the next 7 days**, not one repeating request. iOS keeps
  at most 64 pending per app; 4 kinds × 7 days plus schedules fits, with room for the trial reminder.
- **Doing the thing cancels today's request.** Saving a check-in removes today's check-in reminder;
  saving an RPE removes today's RPE reminder.
- **Re-plan on every app activation, every save that affects it, and every preference change.**
  One `ReminderPlanner` (pure, testable) turns preferences + what is done today + active schedules
  and injuries into the list of requests; the scheduler diffs that against what is pending.
- **Identifiers are derived** — `reminder.checkIn.2026-11-10` — so re-planning replaces rather than
  stacks, the same idea as the trial reminder's one identifier.
- Sign-out removes every reminder (`AppSignOut`). The device is shared.

### Where the code goes
- **`ReminderPlanner` and the preference model in MyDayKit** — it knows what a check-in, an RPE and
  a schedule are. Pure value types, tested directly.
- **`UNUserNotificationCenter` behind a protocol, in the composition root** (`Launch/Composition/
  Reminders/`), next to the existing trial reminder. Concrete infrastructure stays out of frameworks.
- **The settings screen**: Settings → **Reminders** in ProfileKit, which declares what it needs and
  the composition root answers with MyDayKit's model — the same bridging DISCOVER uses.
- **Tapping a notification opens MyDay on today** with the relevant step (check-in expanded, RPE
  open). `userInfo` carries the kind; `AppDelegate`'s `didReceive` hands it to the tab bar.

### Permission
Asked **in context only**: the first time someone turns a reminder on, and once on MyDay right after
a first check-in ("Want a nudge tomorrow morning?"). Never at launch. CLAUDE.md's rule that the
trial screen is the app's one ask gets updated to say this is the second, and why.

## Part 2 — Wellness over time

### The data has to be readable as a range
Wellness and RPE live inside whole day documents, which also hold every exercise and workout. A
90-day chart would read 90 large documents. **A Cloud Function projects them** on every MyDay write
into a small per-day document:

```
Users/{uid}/Readiness/{yyyy-MM-dd}   <- Cloud Functions only
  sleep, body, focus, mood (1–5), readiness (0–1), dayRPE (1–10)?, injuries: { id: pain }?
```

- **Not on `DailyTotal`.** A `DailyTotal` document is what makes a day count as trained for the
  streak; check-ins on rest days would make every rest day a trained one.
- **Keyed by the MyDay document id**, which is the user's local day. `DailyTotal` keys are UTC, so
  overlaying the two can be a day apart around midnight for users far from GMT. Accepted and noted;
  the chart labels days, not hours.
- A backfill script builds it from existing MyDay documents (`InTheGym-Scripts`), so history
  appears at once rather than from the day this ships.

### What is shown
- **A readiness card on STATS** (`StatsKit`), not PERFORMANCE: the overlay with training load needs
  `ACWR.rolling`, which is StatsKit's one calculation and must not be copied into PerformanceKit.
- **Daily readiness as dots, a 7-day rolling average as the line**, last 12 weeks, the four
  questions toggleable like `TrainingChartMetric`. Hand-built, matte palette, no Swift Charts.
- **Readiness against load**: the ACWR progression chart gains an optional readiness line underneath,
  sharing the x-axis, so "load spiked, readiness fell" is visible in one place.
- **Free vs pro** follows STATS: this week's check-ins on `StatsFreeScreen`, history is pro.

### The entry itself
- **The four questions stay as they are.** Changing their wording or scale makes old and new
  scores incomparable on the chart.
- **One addition: injuries** (Part 3) — the check-in is where an active injury is rated each day.
- Optional later: a note on the check-in.

## Part 3 — Injuries

### The model
```
Injury                      Users/{uid}/Injuries/{id}
  id, region, side?, startedOn (day), resolvedOn (day)?, note?,
  checkIns: { yyyy-MM-dd: { pain 0–10, impact: none | modified | stopped, updatedAt } },
  createdAt, updatedAt, removedAt?
```
- **Check-ins are a map on the injury, not a subcollection** (changed while building step 2). One
  document keeps the schedules pipeline — one writer, one path, one sync queue — instead of two,
  and reading every injury with its history is one collection read. The cost is that two
  devices can each replace the document with a copy missing the other's day: `Injury.merged`
  unions check-ins day by day, and `InjuryManager.load` writes the merge back. Step 3's
  projection reads the map off the injury's write trigger.
- **Body regions are a fixed list with a side** (hamstring L/R, knee L/R, lower back, shoulder…),
  not `MuscleGroups` — joints and tendons are not muscle groups, and a free-text part would make
  "knee" and "Knee" two injuries.
- **Impact is three steps, not a yes/no**: training as normal, training around it, stopped. That is
  the answer to "is it still affecting me", and the middle step is the common one.
- **An injury ends when the user says so** (`resolvedOn`). Never inferred from pain reaching 0 —
  people feel fine and still protect it.
- **Day ids, so one check-in per injury per day**, and a second save corrects it.
- **Local-first with a sync queue**, as schedules are: it is rated every morning on MyDay.
- **Private, always.** Never on `Profiles`, never in DISCOVER. Rules: owner only, with tests. Added to
  the account deletion module.

### Logging
- **"Anything bothering you?"** at the end of the morning check-in adds an injury in two taps
  (region, side), with a start date defaulting to today.
- **Each active injury gets a row in the check-in**: a pain slider and the three impact pills. It
  pre-fills from yesterday so an unchanged day is one tap.
- **Free**, as all logging is.

### Reading it back (STATS, pro)
- **Injury periods are drawn as shaded bands** across the readiness chart and the ACWR progression
  chart, so they line up with everything else on the x-axis.
- **An injury page**: pain and impact over the injury's life, and two comparisons:
  - **Before** — ACWR on the start date, its peak in the 28 days before, the week-on-week load change
    in the fortnight before, readiness in the week before against the user's own baseline.
  - **During** — sessions, sets and volume per week against the four weeks before it started, and
    which muscle groups were trained.
- **It states facts, never causes.** "Your session ACWR peaked at 1.6 eleven days before" — not "this
  caused your injury". No diagnosis, no medical advice, and a line saying so.

## Steps
1. **Reminders: check-in and day RPE — built 2026-11-09.** `MyDayKit/MyDayKit/Reminders/`
   (model, `ReminderPlanner`, `ReminderManager`), `ProfileKit/…/Screens/Reminders/`,
   `InTheGym/Launch/Composition/Reminders/`; tests in `ReminderPlannerTests`,
   `ReminderManagerTests`, `ReminderSettingsViewModelTests`. Not built yet from this step: the
   in-context offer on MyDay after a first check-in ("Want a nudge tomorrow morning?"). Not
   checked on a device or simulator.
2. **Injury model and logging — built 2026-11-10** on the `injuries` branches of both repos (not
   merged). `MyDayKit/MyDayKit/Models/Injuries/`, `MyDayKit/MyDayKit/Injuries/` (UI), the
   pipeline in `InTheGym/Launch/Composition/MyDay/`; tests in `InjuryTests`, `InjuryMergeTests`,
   `InjuryManagerTests` and the functions' `firestoreRules.test.ts`. **The rule must be
   deployed before an app build that saves injuries ships.** Not checked in the simulator.
3. **Readiness projection** — function, backfill script, rules, STATS readiness card.
4. **Injuries in STATS** — bands on the charts, the injury page.
5. **Reminders: schedules and injuries** — once both exist to remind about.

## Decisions — agreed 2026-11-09
- **Scheduled-activity reminders fire at one chosen time** ("You've got Upper Body today"). Schedules
  keep having no time of day; the `Schedule` model is unchanged.
- **Reminder preferences live on the device** (`UserDefaults`, scoped by user id). A notification is
  a device thing; a new phone starts with reminders off. No Firestore path, no rule.
- **Logging is free, history is pro**: reminders, check-ins and injury logging are free; readiness
  history beyond this week and the injury page are pro, as STATS is.
- **Reminders are built first** (step 1), then injuries.
