# Cloud Functions spec — assigned workout completions

Handoff spec for the Cloud Functions team. The iOS side is built and shipping; nothing below
requires an app change.

## Context

When a user finishes a workout, the app writes one `CompletedWorkoutSession` document to **two**
paths in a single `WriteBatch`:

```
WorkoutSessions/{sessionId}                 <- analytics copy, all users
Users/{userId}/WorkoutSessions/{sessionId}  <- that user's own history
```

The two are byte-identical except for `deletedAt` (see *Deletion* below).

A workout may have been **assigned by a coach**. When it was, the session document carries
`assignedBy` (the coach's uid). Two things need to happen server-side in that case, and only in that
case:

1. write a **coach-facing projection** the coach can read;
2. **push a notification** to that coach.

Doing this server-side is deliberate. The client keeps writing one collection pair — so a user's own
history is never a union of two collections — while the coach gets a copy they can read **without
any read access to `WorkoutSessions` or to the athlete's day data**. It also means a client cannot
fabricate a completion into a coach's feed.

> The coach↔athlete relationship currently lives in **Realtime Database**
> (`CoachPlayers/{coachId}`, `PlayerCoaches/{playerId}`), not Firestore. Assignment itself is not
> built yet, so **`assignedBy` is absent on every document written today** and these functions will
> no-op until it ships. They can be written, deployed and tested ahead of that.

---

## Function 1 — `onWorkoutSessionCreated`

**Trigger:** Firestore `onCreate`, document path `WorkoutSessions/{sessionId}`

### ⚠️ Trigger on the top-level path only

Both documents are created in the same batch commit. A trigger on
`Users/{userId}/WorkoutSessions/{sessionId}`, or a **collection-group** trigger on
`WorkoutSessions`, will fire **twice per completed workout** — once for each copy. Use the top-level
document path exactly as written above.

### Logic

```
if assignedBy is absent  -> return (self-started workout, nothing to do)
if deletedAt is present  -> return (defensive; should not occur on create)

write   Users/{assignedBy}/AssignedWorkoutCompletions/{sessionId}
push    to the coach's FCM token
```

### The projection

Recommended path: **`Users/{assignedBy}/AssignedWorkoutCompletions/{sessionId}`**

Nesting it under the coach makes the rule trivial — a coach reads their own subtree, no query-scoped
rule and no composite index. A top-level `CompletedAssignedWorkouts` collection filtered by
`assignedBy` would work too but needs a query-constrained read rule. Flag it if you prefer the
latter; the app does not read this collection either way.

**Use `sessionId` as the document id.** Cloud Functions retry on failure, and a fixed id makes the
write idempotent — a retry overwrites rather than duplicating.

Copy the source document wholesale and add:

| field | value |
|---|---|
| `athleteId` | copy of `userId` — clearer name on the coach's side |
| `athleteName` | looked up, see below |
| `projectedAt` | server timestamp |

**`athleteName` is not on the session document.** Read it from `Users/{userId}.displayName`
(the `Users` collection also has `username` if you prefer the handle). Doing the lookup here rather
than denormalising it onto the session keeps the client model lean and means a renamed user shows
correctly on already-written records. If the lookup fails, still write the projection — omit the
name rather than dropping the record.

### The notification

Token location: **`FCMTokens/{userId}`**

```
{ fcmToken: string | null, tokenUpdatedDate: timestamp }
```

`fcmToken` is explicitly nullable — a null means that user has no registered device, which is a
normal state, not an error. Return quietly.

Suggested payload — please confirm the deep-link shape with the iOS side before building the
handler, as the coach-side screen does not exist yet:

```
title: "<athleteName> completed a workout"
body:  "<title> · <setsCompleted> sets" + (rpe ? " · RPE <rpe>" : "")
data:  { type: "assignedWorkoutCompleted", sessionId, athleteId }
```

**Deduplicate.** A retried invocation must not send a second push. Writing the projection first and
sending only when the write actually created the document (or recording a `notifiedAt` on the
projection) both work.

---

## Function 2 — `onWorkoutSessionDeleted`

**Trigger:** Firestore `onUpdate`, document path `WorkoutSessions/{sessionId}`

Removing a workout from a day does **not** delete the analytics document — the app hard-deletes
`Users/{userId}/WorkoutSessions/{sessionId}` and sets `deletedAt` on the top-level one. It is an
update, not a delete, so an `onDelete` trigger will never fire.

```
if before.deletedAt is absent and after.deletedAt is present:
    if after.assignedBy is absent -> return
    retire Users/{assignedBy}/AssignedWorkoutCompletions/{sessionId}
```

Whether "retire" means deleting the projection or setting `deletedAt` on it is the coach-side
product call — deleting is the more honest default, since a coach seeing work that no longer exists
is worse than it vanishing. No notification for this.

---

## Document schema — `WorkoutSessions/{sessionId}`

Written by Swift `Codable` through `Firestore.Encoder`.

### Two encoding facts that will bite

1. **Nil optionals are omitted, not null.** For a self-started workout `assignedBy` is **not present
   in the document at all**. Test for absence, not `=== null`. (The one exception in this codebase
   is `FCMTokens.fcmToken`, which is explicitly nullable and *is* written as `null`.)
2. **All dates are Firestore `Timestamp`s**, not ISO strings or epoch numbers.

### Top level

| field | type | notes |
|---|---|---|
| `id` | string | equals the document id |
| `userId` | string | the **athlete** who performed it |
| `templateId` | string? | |
| `title` | string | workout name |
| `assignedDate` | timestamp | the day it sat on |
| `startedAt` | timestamp | |
| `endedAt` | timestamp? | |
| `durationSeconds` | number? | |
| `rpe` | number? | 1–10, session-level |
| `workload` | number? | duration in minutes × rpe |
| `notes` | string? | free text from the athlete |
| `setsCompleted` | number | |
| `setsTargeted` | number | |
| `exerciseRecords` | array | see below |
| `assignedBy` | string? | **the coach's uid — the field these functions key on** |
| `assignmentId` | string? | |
| `deletedAt` | timestamp? | only ever on the top-level copy |

### `exerciseRecords[]`

| field | type | notes |
|---|---|---|
| `id` | string | |
| `exerciseId` | string | catalogue id, joins to `Exercises` |
| `exerciseName` | string | |
| `rpe` | number? | per-exercise |
| `setRecords` | array | see below |

### `setRecords[]`

| field | type | notes |
|---|---|---|
| `id` | string | unique **within an exercise only** |
| `isCompleted` | bool | false means targeted but not performed |
| `reps` | number? | |
| `weight` | number? | |
| `weightUnit` | string? | `"kg"`, `"lbs"`, `"BW"` |
| `time` | number? | **seconds**, always — no unit field exists |
| `distance` | number? | |
| `distanceUnit` | string? | `"m"`, `"km"`, `"mi"` |
| `tempo` | object? | `{ eccentric, eccentricHold, concentric, concentricHold }`, all ints |
| `note` | string? | |
| `completedAt` | timestamp? | |

Notes for anyone computing off this:

- `setRecords` includes sets that were **never performed** (`isCompleted: false`). Filter on
  `isCompleted` before aggregating — `setsCompleted` at the top level is the authoritative count.
- `weightUnit` on a *performed* set is only ever `kg`, `lbs` or `BW`. The prescription units
  (`"% of 1RM"`, `"% of BW"`, `"Max"`) describe a target and are never stored against performed work.
- `BW` means bodyweight: `weight` will be absent. Do not read it as zero load.
- `time` is a plain second count in every case.

---

## Security rules

Not in this repository — flagging what these functions imply:

- `Users/{coachId}/AssignedWorkoutCompletions/**` — read by that coach only; **no client writes**,
  the function owns it.
- `WorkoutSessions/**` — no coach read access at all. The projection is the only coach-facing copy,
  which is the whole point of the design.

---

## Test cases

1. Self-started session (no `assignedBy`) → no projection, no push, function returns cleanly.
2. Assigned session → exactly **one** projection document and **one** push. Confirm one, not two —
   this catches a collection-group or user-subcollection trigger.
3. Forced retry of an assigned session → still one projection, still one push.
4. Coach has no registered device (`fcmToken: null`) → projection written, no push, no error.
5. `Users/{userId}` missing or unreadable → projection written without `athleteName`.
6. `deletedAt` set on an assigned session → projection retired, no push.
7. `deletedAt` set on a self-started session → nothing happens.

The app has an emulator build (Firestore on `127.0.0.1:8080`) if end-to-end testing against a real
client is useful. Note it runs with persistence disabled.

## Contact points

- Document shape lives in `MyDayKit/MyDayWorkouts/Models/CompletedWorkoutSession.swift`.
  **If that file changes, this spec is stale.**
- Design rationale and the wider assignment design are in `CLAUDE.md` under *Completed Workout
  Sessions* and *Coach-Assigned Workouts*.
