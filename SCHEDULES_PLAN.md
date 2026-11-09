# Schedules — Plan

Set a workout or a sport for a future date, or on a repeating pattern, and it is waiting on MyDay
when the day comes. "I train basketball every Tuesday and Thursday" should not mean tapping through
the Add flow every time, and neither should a morning routine done every day.

**Status: designed 8 November 2026, built 9 November, every step.** The app and the functions are
both on a `schedules` branch, **not merged, deployed or released**. See *Rollout*.

## Decisions — agreed, do not relitigate
- **Exercises are scheduled as workouts.** A morning routine is a workout built in the workout
  builder, then scheduled. There is no separate routine card and no scheduling of single exercises.
- **Two things can be scheduled: a workout or a sport.** One model, `Schedule`: what it is, and when.
- **One-off or repeating.** A toggle: off picks one date; on picks a frequency, then one or more
  weekdays.
- **Frequencies: weekly and every two weeks.** Monthly is left out for now, see *Open questions*.
- **Today only.** A scheduled item appears on today's MyDay and nowhere else. Past days do not
  change, cannot be logged to, and never show "missed". Late logging is deliberately left for later
  and needs thinking through on its own.
- **Free.** Logging is free, and this is a faster way to log.

## A schedule creates nothing in advance
A schedule is its own record. MyDay works out what is due while drawing today, and a day entry is
written only when the user acts on the card.

- **It could not work the other way yet.** `MyDayFileManagerSaver.fileURL()` names its file from
  `Date.now`, so saving a future day would overwrite today's file.
- **A plan is not training.** Stats, streaks, date strip markers, `UserDays` and the rating step all
  read saved data, so an unlogged plan cannot count towards any of them.
- **Changing a schedule rewrites nothing.** There are no future entries to correct.
- It is the display-time merge *Coach-Assigned Workouts* already designs, so that feature can reuse it.

## When a schedule is due
`ScheduleRecurrence` is the one definition, a value type tested directly:

```
.once(day:)
.weekly(weekdays:, start:)
.everyTwoWeeks(weekdays:, start:)
```

- **`occurs(on:)` and `nextOccurrence(onOrAfter:)` are the only recurrence logic.** The schedule
  sheet's "Next: Tue 10 Nov" line comes from the same code as the card, so they cannot disagree.
- **`ScheduleDay` is a day with no time or zone**, stored as a `yyyy-MM-dd` key. A stored instant can
  land on a different day after a change of time zone, so a Tuesday session would move to Monday or
  Wednesday.
- **A `Date` becomes a `ScheduleDay` in the zone of `Calendar.current`, as MyDay's date strip judges
  it, not `StatsDay`'s UTC.** "Tuesday" means the user's Tuesday. The calendar is always Gregorian,
  so a device on another calendar stores the same key.
- **Everything after that is arithmetic on a day number**, which has no clock in it, so a clock
  change cannot shift a day or a week.
- **Every two weeks counts from the Monday of the week holding `start`**, Monday-first whatever the
  locale, as `StatsDay.weekdayColumn` is. Even-numbered weeks since then are on.
- **The sheet's Save stays disabled until a weekday is picked.** A repeat with none, which only a
  damaged document could hold, falls on no day.

## On MyDay
Due items sit in the existing train step, beside anything already logged.

**A due item is hidden when** today already holds an entry with its `scheduleId`, today's
`skippedSchedules` holds its id, or the schedule is stopped. A workout is also hidden when its
template cannot be found, or when it is already on the day, added by hand, since two identical cards
would leave the user guessing which to open.

### Workouts
- The card is `DailyWorkoutCard` with a `.planned` `DailyWorkoutEntry` that is **built for display
  and not saved**, carrying `scheduleId`.
- **Tapping it saves the entry** with a snapshot of the template at that moment, then opens the
  normal session screen. Until then it shows the current template; afterwards, editing the template
  changes only future days. Start, Finish, required RPE and everything after are unchanged.
- **The `⋯` offers "Not Today"** instead of Remove from Today until the workout is started, and
  adds to `skippedSchedules`. Once started it says Remove, since it then discards what was logged.
- **`removeWorkoutFromDay` on an entry with a `scheduleId` must also skip it**, or the card returns
  the moment the entry is gone.
- A schedule whose template cannot be found draws nothing.

### Sports
- A new `ScheduledSportCard`, on `DailySportCard`'s chrome: time filled from the schedule, `RPEScale`
  inline, Done, Not today. Changing the time on the card changes today only.
- **Done needs an RPE**, since a session without one adds nothing to STATS. Nothing is saved until
  Done, through `MyDaySportManager`, so it writes the same two documents as a normal sport session.
- **Scheduled sessions are training sessions.** A game has a result and a score, so it stays in the
  normal Add flow. Logging that sport by hand, game or training, hides the day's card, as a workout
  added by hand does.
- **Removing a logged scheduled sport brings the planned card back.** It is what someone who logged
  by mistake wants, and Not today is one tap away. This differs from workouts on purpose.

### Model changes — all optional, see the decode warning under *Workout Library Loading*
- `DailyWorkoutEntry.scheduleId: String?`
- `SportSessionEntry.scheduleId: String?`
- `MyDayFullDayModel.skippedSchedules: [String]?`

These are Codable additions only. Check `WorkoutSessionManager` and anything else that rebuilds an
entry carries `scheduleId` across.

## Creating and managing
- **Workouts:** a **Schedule** button beside **Add to Today** on `MyDayWorkoutTemplateDetailScreen`.
- **Sports:** a **Schedule** button on the sport detail screen for training sessions, using the
  duration set there. That screen lists the sport's schedules too. To change a schedule's usual
  time, stop it and set a new one.
- **`ScheduleSheet`**, shared by both:
  - Repeats toggle. Off: a date, from today on, starting on tomorrow.
  - On: Weekly / Every 2 weeks, then a row of Monday-first weekday chips, one or more, none picked
    at first.
  - Every 2 weeks also asks "This week / Next week", since the weekdays alone cannot say which weeks
    are meant, and those are the only two answers that matter.
  - A "Next: Tue 10 Nov" line, so the result can be checked before saving.
  - Picking today's weekday on a repeat means it is due today.
- **The workout page lists its own schedules** (`WorkoutScheduleRows`), under the metrics. It is the
  confirmation that Save worked, and a row reopens the sheet, which also holds Stop Schedule.
- **`MyDayScheduledScreen`:** every active schedule with its pattern and next date, soonest first. A
  row opens the same sheet to edit or stop it. Finished one-offs drop off. Reached from a quiet row at
  the bottom of MyDay's Add sheet, apart from the four options, since it adds nothing.
- All new fields and selected states follow *Brand Colours*: `Color.darkColor`, with
  `.tint(Color.darkColor)` on any text input.

## Storage
Local first, like templates, because MyDay has to work offline.

| Path | Store | Written by |
|---|---|---|
| `Documents/Schedules/{uid}/{id}.json` | disk | `FileManagerScheduleWriter` — `ScheduleStoreLocation` is the one definition |
| `Documents/PendingSync/schedules_{uid}.json` | disk | `SyncQueueScheduleUploader` |
| `Users/{uid}/Schedules/{id}` | Firestore | `FirestoreScheduleUploader` |

- **Reads merge local and remote by id, later `updatedAt` wins**, as `WorkoutLibraryManager.merge`
  does. A remote failure is not an error once local has produced something.
- **Stopping sets `stoppedAt`, it does not delete.** With a union merge, a deleted local file would
  be brought back by the remote copy. Editing is a write to the same id.
- **The sync service is held for the session by the composition**, and `Notification.signOut` stops
  it. See *The sync services are held for the session*.
- `MyDayKit` lists its files in the pbxproj, so **check target membership on every new file**.

## Steps
Each step ends with what changed per project and what to check.

1. **Recurrence** (app): `Schedule`, `ScheduleRecurrence`, and tests. Cover every-two-weeks across a
   clock change and a year end, a change of time zone, and `nextOccurrence` for a finished
   one-off.
2. **Server** (`InTheGym-CloudFunctions`): a rule for `Users/{uid}/Schedules/{id}` with a test in
   `functions/test/Rules/firestoreRules.test.ts`. Confirm `functions/src/Account/` deletes the
   subcollection, and add it if not.
3. **Store** (app): writers, loader, sync queue and service, composition wiring, and
   `LocalUserDataEraser`.
4. **Sheet** (app): `ScheduleSheet` and the template detail button.
5. **Workouts on MyDay** (app): due-item logic, the display entry, saving on tap, Not today.
6. **Sports** (app): `ScheduledSportCard` and the sport flow's action.
7. **Scheduled screen and docs** (app): `MyDayScheduledScreen`, and a *Schedules* section and table
   rows in `CLAUDE.md`.

## Rollout
Deploy the rule **before** any app build that saves schedules, or every upload is refused. From the
`InTheGym-CloudFunctions` root, once its `schedules` branch is merged:

```bash
firebase deploy --only firestore:rules
```

A build without the rule still saves to the device and shows the cards, then drops the remote copy
as refused, so another device would never see it.

## Open questions
- **Monthly.** Left out because it needs a rule first: "the 31st" does not exist in every month, and
  "the first Tuesday" is a different picker. Nobody has a real monthly session in mind yet. Adding a
  case later is safe, because schedules decode per document and skip what they cannot read.
- **Is a workout too many taps for a morning routine?** Start, tick each set, Finish, RPE, Complete.
  Use it for a week first. If it grates, "Complete all" on the session screen would not touch
  scheduling.
- **Showing the days ahead.** The strip's three future days are dimmed and not tappable. Opening them
  to see "Thursday: Basketball" would be a small addition, not needed for the first version.
- **Late logging**, for sessions that end late and get logged the next morning. See *Decisions*.
- **Reminders.** A morning nudge would be a second honest reason to ask for notifications, once
  someone has a schedule. Not in this plan.
