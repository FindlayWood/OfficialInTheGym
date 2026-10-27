# Free "This week" on STATS — plan

**Status: scoped 2026-10-26; built 2026-10-27 on `free-stats-week`, with the four decisions below as recommended. Unit-tested; not yet checked in the simulator.** From the 19 October persona reviews (`PERSONA_REVIEWS.md`,
Tier 2 item 7). The reviewers who never paid never saw the thing that would have made them pay:
*their own* numbers. Dave: "did I go twice this week, and am I lifting a bit more than last month?
The app can clearly work that out, it just won't tell me unless I pay." And the welcome screen's
"See it add up" promises something a free user currently never gets.

## What changes

Without pro, the STATS tab stops being a blurred sample behind a lock card. It shows **the user's
own week, for real**, with the pro sections teased underneath.

```
Stats                                   ← no "pro" wordmark
┌ THIS WEEK ─────────────────────────┐
│  M  T  W  T  F  S  S               │  ← this week's seven cells, ActivityGrid's look
│  ■  ·  ■  ·  ·  ·  ·               │
│  2 days trained · 31 sets · 4h 10m │
│  Last week: 3 days                 │
└────────────────────────────────────┘
┌ STREAK ────────────────────────────┐
│  🔥 2 day streak                   │  ← the existing streak row
└────────────────────────────────────┘
┌ YOUR TOP LIFT ─────────────────────┐
│  Back Squat           100 kg  ↑5kg │  ← best set in the last 4 weeks vs the 4 before
└────────────────────────────────────┘
┌ (blurred sample: 12-week chart,    ┐
│  training load)   SAMPLE DATA      │
│   [lock] See your full stats       │  ← the lock card, smaller, lower
│          See INTHEGYM pro          │
└────────────────────────────────────┘
```

**Free:** this week (Monday to Sunday), last week's day count, the streak, one lift's trend.
**Still pro:** the 12-week chart, the four-week activity grid, both ACWRs, training balance, the
exercise list and every detail screen. Nothing in the free view is tappable through to a pro screen.

## Decisions to confirm before building

1. **Which lift.** Recommended: chosen automatically — the weighted exercise with the most sets in
   the last 28 days. A picker is more work and something to explain. Time-based exercises are
   skipped. If nothing qualifies, the card is left out, not drawn empty.
2. **"This week" is Monday to Sunday**, not the last seven days. The copy says "this week", and
   `ActivityGrid` and MyDay's `MyDayWeekCard` both already read Monday-first. (The 12-week chart uses
   a rolling seven days so its newest bar doesn't collapse every Monday. That reason doesn't apply
   to a card that names the days.)
3. **The trend compares best weights**, not volume: best `maxWeight` in the last 28 days vs the 28
   before, in kg. "Your squat is up 5kg" is what Dave asked for; volume needs explaining. No arrow
   colours: up is not "good" here either (see the change chip in *STATS Tab*).
4. **The four-week activity grid stays pro.** The free card shows only this week's row of it, so
   the grid is the obvious next thing pro gives.

## Build

### 1. `StatsFreeSummary` — the numbers, as a value type (StatsKit `Models/`)
- Built from `[DailyTotal]` and `asOf: Date`, like `HomeStats`.
- `thisWeek`: the seven Monday-first day keys, which of them have a `DailyTotal`, and the summed
  sets / reps / time. Last week's active-day count.
- `streak`: **reuse `HomeStats.streak`**, don't re-derive it.
- `topLiftCandidate`: the exercise id with the most sets in the last 28 days, from
  `exerciseSetCounts`.
- **Every day key comes from `StatsDay`, never `Calendar.current`.** The Monday a week starts on
  is worked out in `StatsDay.calendar` too.
  - Known consequence: for a user far from UTC, a late-evening session can land on the next day's
    cell, so this card and MyDay's week card can disagree by a day. That's the same trade the rest
    of STATS already makes. Worth one line in the doc comment.

### 2. `StatsTopLift` — one lift's trend
- Takes `[ExerciseDailyStats]` for one exercise (`ExerciseDailyStatsProviding.fetchDailyStats(exerciseID:from:)`,
  from 56 days ago).
- Returns the best `maxWeight` in each 28-day half and the change between them.
- `nil` when the recent half has no weighted set.
- Name comes from `ExerciseDailyStats.exerciseName`.

### 3. `StatsFreeViewModel` + `StatsFreeScreen` (StatsKit `Screens/`)
- The view model takes `DailyTotalsProviding` and `ExerciseDailyStatsProviding`, the same instances
  the router already holds, and loads on `.task`. **No new reads, rules or indexes**: `DailyTotals`
  and `ExerciseStats/*` are already readable by their owner.
- The lift card loads after the week and fails on its own; if it fails, it is left out.
- Cards are `SectionContainer`s on `pageColor`, as on every stats screen. Header titles are white.
- Below them, the existing blurred `HomeScreenContent` sample, clipped to the chart and training
  load, with a smaller lock card. **The sample must say SAMPLE DATA.** Unlike the old locked screen,
  it now sits directly under real numbers, so blur alone no longer rules out mistaking it for theirs.
- Empty week: "Nothing logged yet this week". **Never "Rest"** — the rule MyDay's timeline follows.

### 4. Wire it in
- `StatsKitRootScreen`: unlocked → `StatsKitHomeScreen`, otherwise `StatsFreeScreen`.
  `StatsGateViewModel` is unchanged and still re-checks on every appearance.
- `StatsKitRouter`'s `.home` case builds the free view model beside the home's.
- `StatsLockedScreen` goes. Its blurred sample and lock card move into `StatsFreeScreen`.
- The welcome screen's "See it add up → Preview" card stays a pro preview. It still shows the full
  pro home, and it is still labelled PRO.

### 5. Tests (`StatsKitTests`)
`StatsFreeSummaryTests` and `StatsTopLiftTests`, with value types tested directly, a fixed `asOf`,
and `accuracy:` on weights. The cases that matter:
- the week starts Monday whatever the device locale;
- a Sunday-night session falls in this week, not next;
- last week's count does not borrow this week's Monday;
- the top lift skips time-based exercises;
- no weighted set → `nil`, not a 0 kg trend.

### 6. Docs
- CLAUDE.md, *What pro gates*: "Pro is the STATS tab" → "Pro is STATS beyond this week".
- CLAUDE.md, *STATS Tab*: rewrite the locked-screen paragraph.
- `ProFeatureList` already says "Your full stats", which stays true.

**Size:** M, a few days. StatsKit only, plus one line in the router. No functions, rules or app-target
changes.
