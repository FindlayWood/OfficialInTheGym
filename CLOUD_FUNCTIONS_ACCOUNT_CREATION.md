# Cloud Functions spec — `createAccount` body fields

Handoff spec for the Cloud Functions team. The iOS side is built and **already sends these keys** —
they are being discarded server-side, so nothing breaks today and nothing is being captured either.

> **What this document is based on.** The function's source is not in this repository, so everything
> below describes the **client contract** — what the app sends, and what it later reads back — plus
> what is inferred from the shape of the data the app decodes. Where a statement is an inference
> rather than something verified in this codebase, it says so. Please correct anything that
> contradicts the function as it actually stands.

---

## Context

`createAccount` is a **callable** invoked once, at the end of onboarding, from
`FunctionsAccountCreator` (`InTheGym/Launch/Composition/AccountCreation/`):

```swift
try await functionsService.callable(named: "createAccount", data: payload(for: account))
```

Onboarding recently changed. Two things matter to you:

1. The flow now collects **height, weight and date of birth** — all optional. These are in the
   payload and need persisting.
2. The flow **no longer asks for account type**. `accountType` is still sent and is now always
   `"individual"`. See *Account type* below — please keep writing it.

`uid` and `email` are **not** in the payload. The app assumes the function takes them from the
authenticated caller (`context.auth`). If that is not what it does, say so — it is the one part of
the existing contract we cannot see.

---

## What the client sends

`FunctionsAccountCreator.payload(for:)`, in full:

| Key                 | Type            | Optional | Notes                                              |
| ------------------- | --------------- | -------- | -------------------------------------------------- |
| `username`          | String          | no       | Already lowercased and trimmed by the client        |
| `displayName`       | String          | no       | Trimmed                                             |
| `bio`               | String          | no       | Trimmed; may be `""`                                |
| `accountType`       | String          | no       | Always `"individual"` now — see below               |
| `isPrivate`         | Bool            | no       | Always `false` today; the flow has no privacy toggle |
| `heightCentimetres` | Number          | **yes**  | **New.** Always centimetres                         |
| `weightKilograms`   | Number          | **yes**  | **New.** Always kilograms                           |
| `heightUnit`        | String          | **yes**  | **New.** `"centimetres"` \| `"feetInches"`          |
| `weightUnit`        | String          | **yes**  | **New.** `"kilograms"` \| `"pounds"`                |
| `dateOfBirth`       | String          | **yes**  | **New.** ISO-8601, e.g. `"1995-05-09T06:13:20Z"`    |

### Optional keys are absent, never null

Assigning `nil` to a Swift dictionary subscript **removes the key**, so an unanswered field does not
arrive as `null` — it does not arrive at all. Verified against the real payload:

```json
{"dateOfBirth":"1995-05-09T06:13:20Z","heightCentimetres":180,"username":"findlaywood"}
```

`weightKilograms`, `heightUnit` and `weightUnit` are simply missing there. Please branch on key
presence, and **do not write an explicit null** into the user document — the client decodes these as
optionals and absent is the value it expects.

### Units: the numbers are always metric

`heightCentimetres` and `weightKilograms` are canonical. The user may have entered feet/inches or
pounds; the client converts before sending. **`heightUnit` and `weightUnit` are display preferences
only** — they say how to render the number back to that user, not what the number means. Do not
convert on the basis of them, and do not treat a missing unit as a different measurement system.

This mirrors how logged training loads are already normalised to kilograms client-side before they
reach `Users/{uid}/ExerciseStats/...`, so bodyweight and lifted load are directly comparable.

### `dateOfBirth`, not age

Stored as a date so it does not go stale. The client floors the picker at 13 years old, but treat
that as a UI constraint, **not an age gate** — if you want a real one, it has to be enforced here.
Ages under 13 are worth rejecting or flagging rather than silently storing.

---

## What needs to change

Write the five new fields onto the user document, using exactly the key names above. Absent input →
absent field.

### ⚠️ There are two user documents, and both are read

The app decodes the **same** `Users` struct from two different stores:

| Store     | Path            | Read by                                                                 |
| --------- | --------------- | ----------------------------------------------------------------------- |
| Firestore | `Users/{uid}`   | `UserAPIServiceAdapter.loadUser()` — the launch path                     |
| RTDB      | `users/{uid}`   | `FirebaseDatabaseManager.fetchRange` — followers, coaches, requests, comments, player lists |

Note the capitalisation difference: Firestore `Users`, Realtime Database `users`.

**Whether the function currently writes both is the main thing we cannot see from here** — but both
are read against the same model, so any field written to only one of them will be present on some
screens and missing on others. Please write the new fields wherever the function already writes the
existing ones, to both if it writes both.

The Firestore document is the load-bearing one: `loadUser()` returning nothing from
`Users/{uid}` is exactly what routes a verified user into onboarding (`.noAccount`). If that document
is not created, the user is sent back through account creation on next launch.

---

## Account type

The signup step that asked for this is gone. Everyone is created `"individual"`, and coaching will
become something a user takes on later rather than a kind of account declared at signup.

**Keep writing the field.** `Users.accountType` is non-optional in the client model and every
existing document has one, so a user document without it fails to decode entirely. Existing `"coach"`
and `"athlete"` accounts are untouched and must stay as they are.

---

## Idempotency and the username

The client reserves the username **before** calling you, writing `Usernames/{username}` in Firestore
(`{username, uid, dateTaken}`) and only calling `createAccount` if that write succeeded. So you do
not need to reserve it — but it is worth **validating that `Usernames/{username}.uid` matches the
caller** and rejecting if not, since right now nothing server-side stops a client sending a username
it never reserved.

Two known rough edges, both on our side, flagged in case you would rather solve them here:

- **A failed `createAccount` leaves an orphaned reservation.** The client shows an error and lets the
  user retry. Retrying with the *same* username is harmless (same uid overwrites), but if they pick a
  different one, the first name stays reserved to them forever with no account behind it.
- **The call is not idempotent from our side.** A retry after a timeout that actually succeeded would
  invoke it twice. Writing with `uid` as the document id and merging makes that harmless; if the
  function does anything non-idempotent (counters, fan-out, welcome email), it needs a guard.

If you would prefer to move the username reservation **into** the function so reservation and account
creation are one atomic operation, say so — that is a client change we are happy to make, and it
would close both of the above.

---

## Before this is visible in the app

Client-side work, listed so the dependency is clear — **not yours**:

- `Users` (`InTheGym/Models/UserModels/Users.swift`) needs optional `heightCentimetres`,
  `weightKilograms`, `heightUnit`, `weightUnit` and `dateOfBirth`. They **must** be optional: every
  existing user document lacks them, and a non-optional addition stops all of those decoding.
- Nothing displays or edits these yet.

So: this can ship server-side whenever, independently. Until the client model is updated the fields
are simply written and not read — which is the harmless direction.

---

## Testing

The app points at the functions emulator under the `EMULATOR` build configuration
(`FirebaseFunctionsManager`, host `127.0.0.1`, port `5001`); the `InTheGym-EM` scheme builds it.
Worth covering:

- all five new keys present;
- none of them present (skip the whole step) — no nulls written, account still created;
- some present (e.g. weight only);
- feet/inches entry — expect `heightCentimetres: 180.34`, `heightUnit: "feetInches"`, i.e. a
  **non-integer** centimetre value. It is the conversion from 5′11″, not bad input;
- pounds entry — same, a fractional `weightKilograms`.

---

## Open question worth raising now

**Weight should probably not stay a single value on the user document.** It is what
percentage-of-bodyweight training targets are calculated from, so a number captured once at signup
silently goes wrong as the user's weight changes. The likely shape is a small time series
(`Users/{uid}/BodyMetrics/{date}`) with the user document holding the latest.

We have not designed that, and **nothing here is blocked on it** — a single field now is forward
compatible with a series later. Flagging it before you pick a schema, in case it changes where you
would rather put these fields.
