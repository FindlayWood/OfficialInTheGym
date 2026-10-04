# InTheGym — CLAUDE.md

## Project Overview
iOS fitness app. iPhone only, **iOS 26.0 minimum** — the app and all six active frameworks
(`IPHONEOS_DEPLOYMENT_TARGET = 26.0` everywhere). It used to read iOS 17+ while StatsKit was built
for 26.1 and MyDayKit for 18.4, so the app could not have launched below 26.1. **A framework must
never target a newer iOS than the app.** `ITGWorkoutKit` targets lower,
which is harmless — embedded code may support older versions than the app does.
Lean, minimal UI aesthetic throughout.

## Packages & Frameworks
### Active — modify freely
- `MyDayKit` — framework
- `StatsKit` — framework
- `AccountCreationKit` — framework
- `LoginKit` — framework
- `DiscoverKit` — framework (in progress — see `DISCOVER_PLAN.md`)
- `ProfileKit` — framework (in progress — see `PROFILE_PLAN.md`)

### Inactive — do not modify
- `ITGWorkoutKit` — ignore, do not touch

`ClubKit` and `WorkoutKit` (two legacy SPM packages) were removed from staging. Both were
constructed in `PlayerInitialViewController` and never shown. They are preserved on the
`archive/clubkit-workoutkit` branch — restore from there rather than rebuilding them.

### Project shapes — the four frameworks are not built the same way
Open **`InTheGym.xcworkspace`**, not `InTheGym.xcodeproj`. It stitches the app project to the four
framework projects and the SPM packages.

| Project | Source file references in the pbxproj | New file |
|---|---|---|
| `AccountCreationKit.xcodeproj` | none — 4 refs, all product bundles | nothing to do |
| `LoginKit.xcodeproj` | none — 4 refs, all product bundles | nothing to do |
| `StatsKit.xcodeproj` | 36 | **check target membership** |
| `MyDayKit.xcodeproj` | 149 | **check target membership** |
| `DiscoverKit.xcodeproj` | none — 4 refs, all product bundles | nothing to do |
| `ProfileKit.xcodeproj` | none — 4 refs, all product bundles | nothing to do |

All six use `PBXFileSystemSynchronizedRootGroup`, but only AccountCreationKit, LoginKit,
DiscoverKit and ProfileKit are driven *entirely* by it. DiscoverKit's project was generated from
LoginKit's, with its object ids prefixed `D1C`; ProfileKit's from DiscoverKit's, prefixed `BF10`
(and `BF1A` for its entries in the app's pbxproj). StatsKit synchronises its `StatsKit/` folder and lists `Router/`,
`Screens/`, `Models/` etc. individually; MyDayKit lists most of its tree.

`SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES` is set on **StatsKit, AccountCreationKit,
LoginKit, DiscoverKit and ProfileKit** — the five built from the StatsKit template. **`MyDayKit` does not set it.** A file that
compiles inside MyDayKit can therefore fail on a missing `import` the moment it moves into one of the
other three.

## Auth
Firebase Auth, email and password only.

`LoginKit` owns welcome / login / signup / forgot-password. It is a **framework**, built exactly like
`AccountCreationKit` — one `PBXFileSystemSynchronizedRootGroup` per target and no file references in
the pbxproj — and its UI is on MyDay's design vocabulary, so the screens either side of signup read
as one flow. It has its own `UI/Color+Extension.swift`, as MyDayKit, StatsKit and AccountCreationKit
each do; `LoginFieldCard`, `LoginPrimaryButton` and `LoginErrorBanner` are its copies of the
account-creation equivalents. **Keep the two sets in step** — they are deliberate duplicates across a
module boundary, not one shared component, and see *Shared UI* below.

The framework targets set `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES` (inherited from the
StatsKit template all three were generated from), so a type must import the module that defines it
rather than picking it up transitively. `WelcomeViewModel` needed an explicit `import Combine` for
`ObservableObject` that the package build had not required. **Expect this on any file moved into one
of these frameworks.**

- **The injected `colour: UIColor` is gone** from `MainLoginKitInterface.init`, same as
  AccountCreationKit: the app only ever passed `.darkColour`, which is `#1C496E` — `Color.darkColor`.
  `editNavBarColour()` now takes it from the framework rather than an argument.
- **Password fields are `PasswordField`**, shared by login and signup. The reveal eye was
  `.foregroundColor(.black)` — invisible in dark mode — and neither field had a `textContentType`, so
  iOS never offered a saved or generated password. Login uses `.password`, signup `.newPassword`.
- **Signup states the password rule** ("At least 6 characters") rather than leaving `canSignup` to
  disable the button with nothing saying why. The rule itself is unchanged: `password.count > 5`.
- **The welcome screen has two full-width buttons.** Logging in used to be the word "LOGIN" inside
  "Already have an acccount?" — typo included, now fixed — which made the returning user's action the
  harder of the two to hit.
- **Forgot Password has a Cancel button.** It is presented modally in its own navigation controller
  and had no way out but the sheet's swipe-down, which is not obvious with the keyboard up.

### Verify email — `VerifyAccountView`
Sits between signup and account creation, polling `user.reload()` every two seconds and moving on by
itself once the address is verified.

- **It used to be titled "Account Created".** It isn't — nothing has been created at that point, and
  the title made the two screens after it look like a mistake. It now reads "Check your email", and
  the address is shown in a card of its own: a typo there is the likeliest reason the mail never
  arrives, and it is the only thing on the screen the user can check.
- **Resend has states** (`VerifyEmailResendState`: idle / sending / sent(cooldown) / failed) and a
  **30-second cooldown**. Tapping it used to change nothing at all on screen — the send was fired
  into a `Task` and any error printed — so people tap repeatedly, and repeated sends are exactly what
  Firebase rate-limits. A failure now shows `VerifyEmailErrorBanner`.
- **The polling timer is invalidated** on verification and in `deinit`. It was retained by the run
  loop and never stopped, so it kept calling `reload()` every two seconds for the rest of the
  session, long after the screen was gone.
- The view reads `viewModel.email` rather than `viewModel.user?.email`, so it does not touch the
  Firebase `User` type — it only ever needed the address.

### The screen after account creation is a paywall
`AccountCreatedViewController` shows **`AccountCreatedSubscriptionView`** — INTHEGYM pro, not a
"welcome" screen. `AccountCreatedView.swift` was the welcome screen it sounds like, was never used,
and has been deleted; don't recreate it without wiring it up. Same design vocabulary as the rest of
onboarding, in the app target rather than a framework.

- **`premiumColour` is green, not purple.** There is a `premiumColour` **colorset** (`#79B49F`, with
  a dark variant) *and* a purple `UIColor.premiumColour` `#colorLiteral` in
  `Helper/UIColor+Extension.swift`. `Color(.premiumColour)` resolves to the asset, so every SwiftUI
  screen is green while UIKit callers (`editNavBarColour(to: .premiumColour)`, `UserStampsView`,
  `UIProfileInfoView`) get purple. Pre-existing and app-wide — **not** a paywall bug, so it was left
  alone here. Worth resolving centrally.
- It keeps `premiumColour` as its accent rather than `darkColor`: that is a semantic colour marking
  premium, like the category colours in `ExerciseCategory`, and it matches `PremiumAccountView`.
- **"Not Now" is always on screen.** It used to sit in an `else` branch that any error or a stuck
  `isLoading` removed, and `AccountCreatedViewModel` set `isLoading = true` in its `catch` blocks —
  so a failed purchase hid both the purchase button and the way out, soft-locking onboarding. The
  `catch` blocks now set `false`. **A paywall must always be dismissible.**
- `SubscriptionProductRow` is one component with an `isSelected` flag; it was inlined twice, selected
  and unselected, and the two copies had already drifted. `PurchaseErrorBanner` renders
  `PurchaseError.description` — which already existed and was going unused behind four hand-written
  `case` branches with their own duplicated buttons.
- The feature list copy is unchanged and is data now (`SubscriptionFeatureList.features`). Some
  entries — Vertical Jump, CMJ, Injury tracker, Journal — may no longer match what the app ships;
  that is a product call, not a styling one.

## Account Creation
The post-signup onboarding flow — a paged form between email verification and the tab bar. It was an
SPM package until it moved to a framework built like `MyDayKit` and `StatsKit`, in two passes: the
framework move (structure only), then the flow and design below. Entered from
`BasicBaseFlow.showAccountCreation` → `AccountCreationComposerAdapter`.

- **`AccountCreationKit.xcodeproj` carries no file references.** Both targets are driven entirely by
  a `PBXFileSystemSynchronizedRootGroup`, unlike StatsKit which synchronises only its `StatsKit/`
  folder and lists `Router/`, `Screens/`, `Models/` etc. file by file. New files need no project
  edit — **do not start adding explicit `PBXFileReference`s to it.**
- **One narrow protocol per job, in `Services/`**: `UsernameAvailabilityChecker`, `UsernameReserver`,
  `AccountCreator`, `ProfileImageUploader`, `AccountCreationSignOutService`. This replaced a single
  `NetworkService` with six generic methods (`upload(data:at:)`, `read(at:)`, `callFunction(named:with:)`
  …) that left the view model building Firestore paths — `"Usernames/\(text)"`, `"ProfilePhotos/\(uid)"`
  — and naming the `createAccount` callable. Those all live in
  `InTheGym/Launch/Composition/AccountCreation/` now, one adapter per file. `UsernameModel` is the
  shape of the `Usernames/{username}` document and lives with the adapter that writes it, not in the
  framework.
- **`FirestoreUsernameAvailabilityChecker` must read into an *optional*.**
  `FirestoreManager.read` goes through `getDocument(as:)`, which decodes a missing document's
  `NSNull` into `nil` rather than throwing — so `let existing: UsernameModel?` distinguishes "no such
  document" (free) from a real failure. Asking for a non-optional `UsernameModel` throws for every
  username that is actually **available**, which inverts the check.
- **The framework owns its brand colour** (`UI/Color+Extension.swift`, same as MyDayKit and StatsKit)
  rather than being handed a `colour: UIColor`. The injected value was always `.darkColour`, which is
  `#1C496E` — `Color.darkColor` exactly.
- `AccountCreationKitRouter` replaced `AccountCreationKitInterface` /
  `MainAccountCreationKitInterface` / `BasicAccountCreationFlow` / `ViewControllerFactory` — four
  types that existed to build one view controller. It follows `StatsKitRouter`: `public init` taking
  every dependency, `public func start()`, `viewController(for:)` over `AccountCreationRoutes`.

### Four steps, in `AccountCreationStep`
`details` → `profile` → `body` → `review`. This was seven: a welcome screen, then a step each for
username, display name, bio, account type and photo, then a summary. The enum replaced a bare `Int`
page index so the review step can send the user back to the step that is missing something.

- **The welcome step was cut.** Four cards of text — Account Setup, Privacy, Stamps, Premium — shown
  before the user had done anything, two of them marketing features they could not yet use. Do not
  reinstate a step that only tells.
- **Username and display name share a step; photo and bio share the next.** The pairs group by
  whether they are required — everything after `details` gates nothing, so "Continue" *is* the skip
  and each subtitle says so. A separate Skip button would say the same thing twice.
- **The progress bar is tappable backwards only.** Every segment used to be tappable both ways, so a
  user on step one could land on the summary behind a disabled button with nothing saying why.
- **Each step gates its own button** (`canAdvance`), so the user is stopped where the problem is.
  `canCreateAccount` still gates the final press, and on the review step anything missing renders as
  a **tappable** row that jumps to its step — it used to be flat red text with no way to act on it.
  Height, weight and age never appear in `missing`; they are optional, so they show when present and
  are simply absent when not.

### Account type is no longer asked
There was a step for it. It is gone: everyone is created `.individual`, and coaching is something a
user takes on later rather than a kind of account they declare before they have seen the app.

- **`AccountType` and `CreateAccountModel.accountType` stay.** `Users.accountType` is non-optional
  and every document already written carries one — dropping the field breaks decoding for all of
  them. See the Firestore decode warning under Workout Library Loading.
- **Existing routing is untouched.** `BaseController.swift` still sends `.coach` to
  `CoachInitialViewController`, so accounts already marked coach keep their tab bar. Nothing creates
  a new one.
- **Open, and deliberately unanswered: what "start coaching" does.** Flipping an existing user to
  `.coach` would take away their own training tabs, which is the wrong trade for someone who trains
  *and* coaches. The likely answer is coaching as a mode inside the normal app rather than a separate
  tab bar — which is also what the coach-assigned-workouts design below assumes. Do not resolve this
  by reinstating the signup question.

### Body measurements — height, weight, date of birth
All three optional, all on the `body` step, each a `BodyMeasurementRow` that reads "Not set" until it
has a value.

- **Stored canonically: `heightCentimetres` and `weightKilograms`,** whatever the user entered them
  in, matching `WeightUnit.kilograms(_:unit:)` on the stats path. `heightUnit` / `weightUnit` record
  how to *read them back*, not what the numbers mean. Two bodyweights that cannot be compared without
  unpicking a unit first are not much use to a stat.
- **Date of birth, not an age.** An age is wrong within a year of signup and there is no second
  conversation in which to correct it. `DateOfBirthSheet` floors the picker at 13 years — that is the
  wheel refusing to express a younger date, **not an age gate**, and it is not a substitute for one.
- **The wheel only appears in a sheet, never inline.** A wheel always has something under the marker,
  so an inline picker would make an untouched optional field look answered. `AccountCreationPickerSheet`
  gives all three a Clear, which is the only way back to "not set" once a sheet has been opened.
  Values bind live and Done only dismisses, the same contract as `SessionSetValueSheet`.
- **Switching unit converts, it does not clear** — unlike `MyDayWorkoutBuilderDistanceScreen`, where
  picking the unit is step one. Here you have already dialled a number in by the time you notice.

**Persisted, and editable after signup.** This section used to say the server discarded the body
keys. That has not been true since the functions' 10 August `createAccount` (on `main`), which writes
`heightCentimetres`, `weightKilograms`, `heightUnit`, `weightUnit` and `dateOfBirth` to `Users/{uid}`
and seeds `Users/{uid}/WeightTracking/{yyyy-MM-dd}` with the signup weight. `onCreateAccount`
mirrors the measurements into RTDB `users/{uid}` too.

After signup they live on ProfileKit's **Body Measurements** screen (Settings → Account), which is
private and deliberately not on Edit Profile (`PROFILE_PLAN.md` step 4).
- Height and date of birth are edited there and written to `Users/{uid}`.
- **Weight is a log**, one entry per UTC day in `WeightTracking`. The `syncLatestWeight` function
  copies the newest entry onto `Users.weightKilograms`, so that field stays the latest weight
  without the app writing two places. It is what `WeightUnit.percentBodyweight` prescriptions should
  eventually read; nothing does yet.
- The app's `Users` model still has **no** body properties. ProfileKit's adapters read them by hand.
  If `Users` ever gains them, **they must be optional**, since most documents lack them.

### Fixed here — do not reintroduce
- **Usernames are lowercased** in `AccountCreationHomeViewModel.username`'s `didSet`, and the field
  sets `.textInputAutocapitalization(.never)`. `Usernames/{username}` is a case-sensitive Firestore
  document id, so `Findlay` and `findlay` are two different reservations — and iOS capitalises the
  first letter of a text field by default, which reserved names users never typed. Both halves are
  needed: the modifier for typing, the `didSet` for pastes.
- **The availability check is debounced**, not `.dropFirst(4)`. Dropping the first four published
  values meant a username typed to exactly three characters and left alone was never checked at all,
  so it sat on `.idle` and `canCreateAccount` blocked forever.
- **A failed lookup is `.unchecked`, not `.taken`.** A network blip is not a claimed username, and
  saying so sent users off to invent a name they never needed.
- **Creation failure is reported.** `creationError` renders as `AccountCreationErrorBanner` above the
  bottom button, on whichever step the user is on. It used to fail silently — the spinner vanished
  and nothing else changed. A username lost between check and reservation sends the user back to
  `.details` with a message, and **does not clear the field**, which the old code did.

### Design
Matched to MyDay, which it did not resemble at all: white capsules with `shadow(radius: 8)`, radius-8
cards, drop shadows on selection, and hardcoded `.white` backgrounds that were unreadable in dark
mode. It now uses MyDay's vocabulary — `secondarySystemBackground` cards at radius 14/16 holding
`tertiarySystemBackground` input wells, uppercase caption headers, explicit `.system(size:weight:)`
fonts, no shadows. **The page is `systemBackground` and the cards are `secondarySystemBackground`**
(set in `UI/UIViewController+Extension.swift`); that was the other way round before.
- The forward action is one full-width 52pt button at the bottom, as on every MyDay builder screen;
  back is a 44pt chevron in `AccountCreationTopBar`, like `MyDayWorkoutNavBar`. It used to be two
  60pt filled circles at the bottom.
- Disabled buttons use the gated styling from `SessionSetDetailOverlay` — `Color.secondary` on
  `tertiarySystemFill`, `.easeInOut(0.15)`.
- Sign out is a quiet text button in the top corner, on the first step only. It was red, directly
  under "Get Started", which read as an error rather than an escape hatch.
- The `PhotosPicker` wraps the avatar itself with a camera badge. The placeholder used to be a
  `person.circle.fill` scaled to 300pt with a text link under it.

## Architecture
- Coordinator-based UIKit navigation with SwiftUI views via `UIHostingController`
- Protocol-oriented DI — framework layer owns only protocols and managers
- All concrete infrastructure lives in the composition root
- Local-first: FileManager + JSON for templates and daily entries, Firestore for remote sync
- Session logs stored as `WorkoutSessionRecord` embedded in `DailyWorkoutEntry` (same JSON day file)

### Coordinator and Router are the same pattern under two names
`Coordinator` (MyDayKit, app target) and `Router` (StatsKit, AccountCreationKit) are one shape.
`Router` is the newer naming, adopted where a framework collapsed a stack of interface/flow/factory
types into one — see `AccountCreationKitRouter` under *Account Creation*.

- **Skeleton, in this order**: `// MARK: - Navigation` (the `UINavigationController`) → `Dependencies`
  → `Properties` (child coordinators, `rootViewController`) → `Init` (`public`, taking every
  dependency) → `Root` (`public func start()`, which stores `rootViewController` and calls
  `setViewControllers`). `viewController(for:)` and `navigate(to:)` live in an **extension**, not the
  main declaration.
- **Routes are an enum carrying the screen's inputs as associated values**, including data already
  loaded — `case acwrDetail(totals: [DailyTotal], metric: TrainingLoadMetric)`. A detail screen does
  not re-fetch what the screen before it already holds.
- **`viewController(for:)` builds the view model, fills its navigation closures, wraps it in a host,
  and returns** — all in one `case`. That is the only place the two halves meet. Every closure
  captures `[weak self]`.
- **Managers scoped to one flow are built in the coordinator, not the composition root**, and have
  their callbacks wired on the spot — `WorkoutSessionManager` in the `.workoutSession` case.

### Three ways a SwiftUI screen is hosted
1. **`UIHostingController(rootView:)` inline** in `viewController(for:)` — the default, with
   `hidesBottomBarWhenPushed = true` when the tab bar should go.
2. **A Boundary view controller** — `StatsKitBoundaryViewController`, `MyDayBoundaryViewController`,
   `AccountCreationBoundaryViewController`. A plain `UIViewController` with `var display: SomeScreen!`
   and a `var router`/`coordinator`, embedding through a local `addSwiftUIView<T: View>(_:)` that adds
   the hosting controller as a child and pins its view to all four anchors. It exists to control the
   nav bar (`setNavigationBarHidden` in `viewWillAppear` / `viewWillDisappear`) around a SwiftUI
   screen. Each module carries its own copy of `addSwiftUIView`, like the colour extensions.
3. **`NavBarHidingHostingController`** — see *MYDAY Workout Flow*. Nothing in it is screen-specific.

### Composition root mechanics
- **One `XComposition` class per module**, with a `compose…(_ navigationController:)` method that
  builds the graph bottom-up in commented sections and ends `coordinator.start()` / `router.start()`.
- **Annotate the `let` with the protocol** where the concrete type would otherwise be inferred —
  `let loader: ExerciseLoader = FirebaseExerciseLoader()` — which is what makes the next line's
  decorator substitutable.
- **Behaviour is composed by wrapping, never by a flag inside an implementation.** The wrap labels are
  not standardised: `decoratee:` (`MainThreadExerciseLoaderDecorator`), `wrapping:`
  (`ThumbnailUploadDecorator`), `wrapped:` (`FirestoreMetadataDecorator`), `local:`/`remote:`
  (`LocalAndRemoteMyDaySaver`), `localLoader:`/`remoteLoader:` (`LocalWithRemoteFallBackMyDayLoader`).
  Match the neighbours. The clip upload path is three nested decorators over
  `FirebaseStorageClipUploader`.
- **One writer, one destination — single responsibility, enforced.** A reader or writer that talks to
  infrastructure knows exactly **one** path or store. When data has to land in two places, that is two
  writers, each conforming to the same protocol, composed by a decorator that knows **no paths at
  all** — it only decides that both happen, and in what order — and the composed writer is what the
  composition root hands downstream. Template writes are the reference:
  `FirestoreWorkoutTemplateUploader` (`Users/{uid}/WorkoutTemplates`) and
  `FirestoreTopLevelWorkoutTemplateUploader` (`WorkoutTemplates`), composed by
  `UserAndTopLevelWorkoutTemplateUploader(user:topLevel:)`. The first attempt put both paths in one
  uploader behind a `WriteBatch`; that was rejected — a writer that knows two destinations cannot be
  reused, swapped or tested for one of them, and each new copy grows it again.
  `FirestoreCompletedWorkoutSessionSaver` and `FirestoreCompletedWorkoutSessionDeleter` predate this
  rule and still write two paths in one batch — **do not copy that shape.** Atomicity is not a reason
  to merge writers: the retry path (sync queue, idempotent `setData`) is what closes the gap between
  two writes.
- **A one-use decorator may live at the bottom of the composition file**; anything used twice gets its
  own file.
- **Migrations run before the readers they affect**, with a comment saying so —
  `LegacyWorkoutTemplateStoreMigrator().migrate()` precedes `WorkoutLibraryManager`.
- **The user id is read once, here** (`UserDefaults.currentUser.uid`) and injected downward.

### Legacy UIKit — the app-target triple
905 files. This is how the app target is built, and it is what to follow when **extending an existing
app-target screen**. New features do not go here; they go in a framework as SwiftUI.

One feature folder holds three files with the same prefix — `XView.swift`, `XViewController.swift`,
`XViewModel.swift`.

- **The view controller**: `var display = XView()` as a property (`loadView` is not overridden), with
  `display.frame = getFullViewableFrame()` and `view.addSubview(display)` in `viewDidLayoutSubviews`;
  `weak var coordinator`, set by the coordinator after construction; injected dependencies
  implicitly unwrapped (`var purchaseManager: PurchaseManager!`); `viewDidLoad` calling small named
  wiring methods (`initDisplay()`, `initDataSource()`, `initViewModel()`) rather than inline setup;
  `editNavBarColour(to:)` and `navigationItem.title` in `viewWillAppear`;
  `private var subscriptions = Set<AnyCancellable>()` with `.sink { [weak self] … }.store(in:)`.
- **The view**: every subview a closure-initialised property under `// MARK: - Subviews`, each ending
  `translatesAutoresizingMaskIntoConstraints = false`. **The view registers its own cells** — the view
  that owns the table owns the list of cell types it can show. `lazy var` when the initialiser reads
  another property. `didSet` recomputes layout rather than exposing a `reload()`. Constraints are
  `NSLayoutConstraint.activate([...])` in `setupUI()`.
- **The view model**: `CurrentValueSubject` for state, `PassthroughSubject` for events and errors,
  failure type always `Never` — errors travel as values on their own subject rather than failing the
  stream. Navigation targets are published as subjects too; the VC sinks them and asks its
  coordinator. `apiService` carries a default (`= FirebaseDatabaseManager.shared`) so the type is
  constructible untouched and overridable in tests.
- **Lists are a dedicated `NSObject` data source class**, not an extension on the VC: it owns
  `private lazy var dataSource = makeDataSource()`, conforms to the delegate in an extension, and
  **republishes selection through a `PassthroughSubject`**. Fixed method set — `makeDataSource()`,
  `initialSetup()` (append sections, apply a non-animating empty snapshot), `updateTable(with:)`.
  `SingleSection` is the default one-section enum. Force-cast dequeue is the house style.
- **Cells** expose `static let cellID` (tables) or `reuseID` (collections) — both spellings exist,
  match the folder — and may own a Combine publisher and a cell view model, raising intent upward as
  events. `configure(with:)` is the single entry point.
- The older screens use an `NSObject` **delegate adapter** with a lowercase-initial multi-method
  protocol declared in the same file (`repsTopCollectionProtocol`). That is the predecessor of the
  diffable data source — extend it only inside a screen that already uses it, never write a new one.
- Legacy views hardcode `.white` / `.black` in places. That is a **known dark-mode defect**, not a
  pattern to copy.

## Tech Stack
Swift, SwiftUI, UIKit, Combine, Firebase/Firestore, Firebase Cloud Functions,
Firebase Emulator (Python seeding scripts, --import/--export), NWPathMonitor

Fuller picture, since which half of the app you are in decides what is available:

| Current — use for new work | Legacy — present, do not extend |
|---|---|
| SwiftUI, Combine (`ObservableObject`/`@Published`) | UIKit + Combine bare subjects |
| Firestore + `FirebaseFirestoreSwift` (29 / 8 files) | **Realtime Database** — `FirebaseDatabaseManager`, the whole social/coaching graph |
| Firebase Storage, Functions, Auth, Messaging | CoreData (`InTheGym.xcdatamodeld`, dormant; `ITGWorkoutKit`'s cache) |
| `async`/`await` + `throws` | `Result` completion handlers |
| Hand-built charts | `danielgindi/Charts` 4.1.0 (13 files) + axis formatters in `Helper/ChartAxisFormatter/` |
| RevenueCat 4.44 behind `PurchaseManager`, StoreKit for local testing | `SCLAlertView-Swift` (13 files), `SkyFloatingLabelTextField` (5 files) |
| AVFoundation (clips, jump measuring), PhotosUI | Storyboards / xibs — launch screen and `Main.storyboard` only, **do not add more** |

Only `ITGWorkoutKit` is localised (`.strings` + localisation tests). Everything else hardcodes
English at the point of use — do not introduce a localisation table for one screen.

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

### Files and comments
- **Xcode file header on every file.** App-target files keep the copyright line
  (`Copyright © 2021 FindlayWood. All rights reserved.`); framework files do not.
- **`// MARK: -` section banners in a consistent order.** Frameworks: `Navigation` → `Dependencies` →
  `Properties` → `Init` → `Root`. App target: `Coordinator` → `Publishers` → `Properties` →
  `Subviews` → `Initializer` → `View` → `Display` → `Data Source`. Both `Init` and `Initializer`
  appear — match the file's neighbours.
- **A `///` comment records the decision, not the signature.** The house style is several sentences
  explaining why the shape is what it is and what broke under the previous one, with the rule in
  bold. `WorkoutLibraryManager`, `StatsDay`, `WorkoutSetRecord.statsLogId` and
  `WeightUnit.kilograms` are the reference examples. Inline `//` comments carry the same weight where
  a single line is load-bearing (the ordering inside `cancelSession`).
- **Folder and file names are not sanitised** — `New Group/`, `Feed Feature/`,
  `WorkoutCreation(4.4)/`, `Protocols/CooridnatorFlows/`, `DisplayWorkoutStatsAdater.swift` all exist
  and are referenced from the pbxproj. Do not rename them incidentally.

### A rule that exists in two places is a defect
Each of these is the single definition of something that had previously been inlined at three or four
call sites and drifted apart. Do not re-inline any of them:

`WeightUnit.kilograms(_:unit:)` · `StatsDay.key(for:)` · `ACWR.Zone(ratio:)` ·
`SessionSetInput.target(for:)` · `WorkoutTag.normalized(_:)` · `SessionSetPillValue.values(for:record:)` ·
`WorkoutTemplateStoreLocation` · `WorkoutSetRecord.statsLogId(sessionId:setId:)` · `Tempo.isEmpty` · `AppSignOut`

## Testing
Before writing any tests, read all test files and folders within `ITGWorkoutKit`
and use these as the template for structure, naming, and style.

`ITGWorkoutKit` is read-only but its suite is the reference. `StatsKit/StatsKitTests/` and
`DiscoverKit/DiscoverKitTests/` are the substantial framework suites and the model for new ones —
`LoginKitTests` and `AccountCreationKitTests` are Xcode-generated placeholders, and `MyDayKitTests`
holds only `WorkoutTemplateModelCopyTests` (its scheme had no test action until DISCOVER added one).

- **`test_<method>_<expectedBehaviour><condition>()`**, behaviour first —
  `test_rolling_deliversRatioOfOneOnSteadyLoad`,
  `test_rolling_averagesOverWindowLengthNotOverTrainedDays`. "delivers" is the standard verb for a
  returned value.
- **`let sut = …`** on the first line; `final class`; `@testable import`.
- **Deterministic inputs from private helpers at the bottom of the file** — `fixedDate`,
  `load(100, forLastDays: 28)`.
- **`accuracy:` on every floating-point assertion.**
- **A comment above a non-obvious test naming the behaviour that would break** — written in the same
  voice as the source doc comments, saying what a wrong implementation would produce.
- **Domain maths is tested directly as a value type**; `ACWR.rolling(...)` needs no test double.
- **A spy records an `Equatable` message enum** in `private(set) var receivedMessages` and stores
  completions for the test to drive (`complete(with:at:)`, `at index: Int = 0`). **A spy never
  asserts.** One double per file, under the suite's `Helpers/`.
- **Helpers are `Type+TestHelpers.swift`**, one per file, forwarding `file:`/`line:` so a failure
  points at the test. Assertions are extracted too (`…Tests+Assertions.swift`).
- **`Mock…`/`Preview…` conformers that exist for SwiftUI previews ship in the *framework*, not the
  test target** — `MockDailyTotalsProvider`, `PreviewFirestoreService`, `PreviewExerciseLoader` —
  and are `public` + `@unchecked Sendable`.

### CI
`.github/workflows` → the shared `CI_iOS` scheme → `CI_iOS_TestPlan.xctestplan`, which sets
`testExecutionOrdering: random` (tests must not depend on each other) and `testTimeoutsEnabled`.

**A test target is invisible to CI until it is added to the test plan.** The plan runs
`InTheGymTests`, `ITGWorkoutKitTests`, `ITGWorkoutKitiOSTests`, `ITGWorkoutKitCacheIntegrationTests`,
`WorkoutAPIEndToEndTests` **and every framework suite** — `StatsKitTests`, `MyDayKitTests`,
`AccountCreationKitTests`, `LoginKitTests`, `DiscoverKitTests`, `ProfileKitTests` — with coverage on
the app, ITGWorkoutKit and all six frameworks. **Add any new framework's test target here.**

**CI is not actually running.** Every run since at least August fails before starting on a GitHub
billing error. Once that is fixed the workflow itself still needs updating: it pins Xcode 15.3 (which
cannot open the `objectVersion = 77` framework projects), an iOS 17.4 simulator — the app now
needs iOS 26 — and a workspace path of `InTheGym/InTheGym.xcworkspace` (the workspace is at the repo
root).

## App Structure
5 tabs: NEWSFEED, DISCOVER, MYDAY, STATS, PROFILE.
**PROFILE is `ProfileKit`** on the player tab bar (see `PROFILE_PLAN.md`); the coach tab bar keeps
the legacy `MyProfileCoordinator` until the coach/player split is removed. Performance Center is
reached from ProfileKit's settings through `ProfileAppRoutes` — a separate roadmap task, **never
delete its code**.
Current focus: MYDAY tab — active session UI complete (see roadmap and Feature Areas Complete).
NEWSFEED may be replaced with a dedicated WORKOUTS tab (TBC).

Roadmap order:
1. Fix workout stats → update STATS tab
2. DISCOVER tab (exercises + workouts: display, scoring, user reviews)

Those five are the **player** tab bar (`PlayerInitialViewController`). The **coach** tab bar
(`CoachInitialViewController`) is a different four: NEWSFEED, DISCOVER, **PLAYERS**, MYPROFILE — no
MYDAY and no STATS. `BaseController` routes `.coach` accounts there. Nothing creates a new coach
account (see *Account type is no longer asked*), but existing ones keep that tab bar, so a change to
"the tab bar" is two changes.

A tab is a `UINavigationController` handed to a coordinator that is `start()`ed, with the whole set
assigned to `viewControllers` at the end of `viewDidLoad`.

**DISCOVER is `DiscoverKit`** on both tab bars (see `DISCOVER_PLAN.md`). On the player tab bar it is
composed **after** MyDay and handed `myDayKit.workoutLibrary`, so "Save to Library" writes through
MyDay's own template saver and library manager; the coach tab bar passes `nil` and its workout pages
offer no Save. The old RTDB Discover tab is gone, but `ExerciseDescriptions/`, `WorkoutDiscovery/`
and `ExerciseDiscoveryCoordinator` remain — other legacy flows still reach them.

**`PlayerInitialViewController` builds a tab it never shows.** `WorkoutsCoordinator` has
`.start()` called on it — building an entire view-controller stack — but its navigation controller
never appears in `viewControllers`. It is dead work on every launch. Worth clearing when the
NEWSFEED/WORKOUTS tab question above is settled. (The ClubKit and WorkoutKit tabs that used to sit
beside it are gone — see *Packages & Frameworks*.)

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
  reading `Documents/WorkoutTemplates/{uid}/{id}.json`. **The ISO-8601 date strategy must stay in
  step with the uploader** — changing one side alone silently stops everything decoding. It decodes
  per file and skips failures, exactly as the Firestore fetcher decodes per document.
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

### Local stores are scoped by user id, not cleared on sign-out
The device is shared. `Documents/WorkoutTemplates` used to be flat, so every template from every
account that had ever signed in sat in one directory — and because the library reads local first,
the next user to sign in opened their library and saw the previous user's workouts. It is now
`Documents/WorkoutTemplates/{uid}/{id}.json`, the shape `Documents/MyDays/{uid}/{date}.json` and
`Documents/PendingSync/workoutTemplates_{uid}.json` already had.

- **`WorkoutTemplateStoreLocation` is the one definition of that path.** The uploader, the fetcher
  and the migrator all derive it from there — they each worked it out separately before, which is
  how the two sides of a local store drift apart. **Do not re-derive it at a call site.**
- **The injected `userId` is the signed-in user, never `template.createdBy`.** For a coach-assigned
  workout those differ, and the file belongs in the library of whoever is using the device.
- **Scoping, not wiping on sign-out — deliberately.** A template that has not reached Firestore yet
  is still on disk when its owner signs back in. Wiping would throw that away to solve a problem
  scoping already solves.
- **`LegacyWorkoutTemplateStoreMigrator` files pre-existing root-level templates under their own
  `createdBy`**, run from `MyDayKitComposition` before the library is built. Filing them under the
  user signing in now would hand one person the whole pool — which is the bug. A file that cannot be
  decoded is **left in place, not deleted**: the fetcher has always skipped those, its owner cannot
  be read off it, and destroying it gains nothing.

Not covered, and still open: `WorkoutTemplateSyncService.stop()` has no caller, so signing out leaves
its `NWPathMonitor` running and a second sign-in starts another one. The queue it flushes is
uid-scoped, so it uploads the right data — this is a leak, not a correctness bug.

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
  → `UserAndTopLevelWorkoutTemplateUploader` (`FirestoreWorkoutTemplateUploader` +
  `FirestoreTopLevelWorkoutTemplateUploader`) → `WorkoutTemplateSyncService`
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
- **`WorkoutBuilderManager` resets itself after a successful upload** — title, exercises, `isPublic`
  and `tags` — *before* publishing `.success`, which is what pops the builder. It is built once in
  `MyDayKitComposition` and outlives the screen, so anything left on it is what the next visit opens
  with. A failed upload resets nothing; the input is what the user needs to retry.
  **`WorkoutSettingsSheet` binds to the manager**, not to its own `@State` — it used to hold
  visibility and tags locally while `buildTemplate()` hardcoded `isPublic: false, tags: nil`, so the
  sheet changed nothing. `isPublic` defaults to **public**, and `reset()` restores that default.
  The sheet's "Save to library" toggle is still local state and still does nothing.
- **Tags are lowercase ASCII letters and digits only — `WorkoutTag.normalized(_:)` is the one
  definition.** No spaces, no punctuation; accents are folded ("Café" → "cafe"), anything else
  outside a–z / 0–9 is dropped. The tag field normalises on every keystroke so what is shown is what
  is stored, and `addTag` normalises again so nothing reaches a template unnormalised. Tags are
  matched exactly by Firestore `array-contains`, so "Legs" and "legs" would otherwise be two tags —
  the case-sensitive `Usernames` bug again. **Do not re-inline the rule at a call site.**
  `WorkoutTag` is **`public`** because DISCOVER applies the same rule to the tags people vote onto
  exercises and workouts: DiscoverKit declares a `TagNormalizer` and the composition root's
  `WorkoutTagNormalizer` answers it with `WorkoutTag.normalized` — still one definition.
  `WorkoutTag.maxLength` (32) must stay in step with the server's `MAX_TAG_LENGTH`.
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

## STATS Tab — `StatsKit`
Reads the `DailyTotal` documents and the raw exercise logs written by the MyDay path below, and turns
them into training-load metrics. `StatsKitRouter` follows the shape under *Architecture*; the six read
protocols (`DailyTotalsProviding`, `StatsKitExerciseLoader`, `ExerciseDailyStatsProviding`,
`ExerciseLoader`, `MuscleGroupsLoader`, `MovementTypesLoader`) are implemented in
`InTheGym/Launch/Composition/StatsKit/`, one adapter per file.

### `StatsDay` is the one definition of a day, and it is UTC
`DailyTotal.id` and `ExerciseDailyStats.id` are `yyyy-MM-dd` document ids minted **server-side in
UTC**, and `DateFormatter.yyyyMMdd` reads them back in UTC. Every piece of day arithmetic — the
streak, the activity dots, the rolling ACWR windows — steps days to rebuild those same keys, so it
has to step them in the calendar the keys were written in.

**Do not reach for `Calendar.current` on the stats path.** Stepping with the device calendar means
that for any user east of GMT the key built for "now" is *yesterday's* document for part of every
day: the streak breaks and every rolling window is silently shifted by one. `StatsDay.calendar` is a
Gregorian calendar pinned to UTC and must not drift from `DateFormatter.yyyyMMdd`. If a screen needs
to show a date to the user, format it in their locale **at the point of display** — but look it up
through `StatsDay.key(for:)` / `.key(daysAgo:from:)` / `.date(daysAgo:)`.

### `ACWR` — one calculation, one set of boundaries
Acute:Chronic Workload Ratio — recent load against the baseline the body has adapted to.

**There were four ACWR calculations**: the home card, the workload detail screen, `MetricACWR`, and
the per-exercise weekly chart. Two disagreed on what the chronic window even was, so the same
training read "optimal" on one screen and "high risk" on the next. `ACWR.rolling(loadByDay:endingOn:
acuteDays:chronicDays:)` is now the only one. What varies legitimately is the *load series* going in
— see `TrainingLoadMetric` — never the arithmetic.

- **The mean divides by the window length, not by the number of trained days.** Averaged over trained
  days, one 700-unit day in an otherwise empty month reads 700; over the window it reads 100 acute
  and 25 chronic, which is the behaviour a deload depends on. The acute window has to see rest days
  as zero or a deload never shows.
- **`ratio` is optional.** Chronic zero → `ratio: nil`, zone `.insufficient`, `formattedRatio` `"—"`.
- **`ACWR.Zone(ratio:)` is the only place the boundaries are written down** — `<0.8` low,
  `0.8..<1.3` optimal, `1.3..<1.5` caution, above that danger — and it owns the colours. The charts
  each carried a private `acwrColor(_:)` before this, so the boundaries lived in three places and the
  colours in four. `Zone.color` is why `ACWR.swift` imports SwiftUI; those colours are semantic, not
  accents.
- **The zone colours are the matte palette, not the system ones.** `Color.matteGreen` / `matteAmber`
  / `matteRed` / `matteBlue` / `mattePlum` live in StatsKit's `UI/Color+Extension.swift` beside the
  brand colours; `Zone.color` owns the *mapping*, the extension owns the values — the same split
  brand colours use. `.red` / `.orange` / `.green` at full saturation read as system alerts beside
  `darkColor`, and made the louder zones look more urgent than the marker's position warranted; the
  matte set sits at a similar lightness so no zone grabs the eye purely by being brighter. Mid-tone
  by design, so each holds up in light and dark without a second variant.
  **`ACWRDetailScreen` had hardcoded copies of all of them** — the progression chart's zone bands,
  `ZoneDistributionView`'s four bars, the insight accents and the educational key — despite the rule
  above. They route through `ACWR.Zone.<case>.color` now. The acute/chronic series are `matteAmber` /
  `mattePlum` for the same reason: a sharp orange line over matte zone bands is one screen with two
  palettes.

### `TrainingLoadMetric` — two load series that must not be merged
`.session` (duration × RPE) and `.volume` (reps × weight) are **separate on purpose**. Each is
incomplete in a different way:
- `.session` only exists for work done inside a workout, because RPE is asked for at the end of a
  session. An exercise logged on its own produces a `DailyTotal` with no `totalWorkload` at all.
- `.volume` **under-weights** unloaded work rather than ignoring it. `WeightUnit.kilograms` stores no
  kilogram value for bodyweight, `% of 1RM`, `% of BW` or `Max` (all normalise to 0 — they are
  prescriptions or bodyweight, not loads), but the DailyTotals Cloud Function works the day's volume
  out as **`(1 + weightKg) × reps`**, so a bodyweight set still contributes its rep count. A
  calisthenics session registers, far below a loaded session of the same reps. That is a difference
  of scale, not an absence. The `+ 1` lives in the function, **outside this repository** — do not
  re-derive volume on the client to "fix" a number that looks small. *(This entry previously claimed
  calisthenics scored zero volume, which was wrong: it read `WeightUnit.kilograms` and missed the
  `+ 1`.)*

Averaging them, or falling back from one to the other, hides which kind of work is missing behind a
number that looks complete. **Two ratios that each say what they cover is the honest presentation.**
The enum carries its own `title`, `subtitle` ("Duration × RPE") and `explanation`: a "1.24" with
nothing saying which work it counted is meaningless, so a metric that cannot explain itself is not
shipped.

### The home screen leads with a chart, and the order is deliberate
`TrainingChartSection` → `StreakAndActivityView` → `TrainingLoadSummaryView` → training balance →
recent exercises. It used to be streak → two full-width ACWR cards → a 2×2 week grid, which put the
**emptiest** content in the most prominent slot: both ratios need 28 days of history, `.session`
needs a Cloud Function that has not shipped, and the two cards together ran ~350pt — so on a 6.1"
phone every concrete number began below the fold.

- **`TrainingChartSection` is the only thing on the tab with a shape rather than a number**, and it
  is first for that reason. Twelve weekly buckets, a metric toggle (`TrainingChartMetric`: volume /
  sets / reps / time), the newest week called out as a headline with a week-on-week change chip.
- **Bars, not a line.** A week's total is a discrete sum and a rest week is genuinely zero; a line
  would slope between two weeks and imply values never measured. The ACWR progression chart is a
  line correctly — a rolling ratio really is continuous.
- **The bars are `Color.darkColor` with opacity carrying magnitude**, the same ramp `ActivityGrid`
  uses, which is what makes the two cards read as one system. `TrainingChartMetric` therefore carries
  **no colour** — each case used to own one (volume blue, sets orange…) so the whole chart changed
  hue under the toggle. The newest bar also no longer gets an emphasis opacity: once opacity means
  magnitude, spending it on recency too makes a big old week and the current week indistinguishable.
  The axis labels the newest bar "This week" instead.
- **Weekly buckets, not daily.** At a realistic training frequency a 30-bar daily chart is mostly
  gaps and reads as noise.
- **The change chip is not colour-coded up-good / down-bad.** More load is not better — the ACWR card
  two rows down exists to say a spike is a risk, and a deload showing a red arrow would contradict
  it. It reports direction and leaves the judgement to the ratio.
- **`TrainingWeek.buckets` newest bucket is a rolling seven days (0–6), not a calendar week.** A
  calendar week makes the newest bar a partial one that collapses every Monday and refills — which
  reads as training falling off a cliff rather than a week that has not happened yet.
- **The 2×2 "Last 7 days" grid is gone.** Three of its four figures (sets, reps, volume) are what the
  chart now plots over twelve weeks; the fourth, active days, is a *consistency* figure and moved
  into the activity card beside the streak.
- **`ActivityGrid` replaced a row of thirty dots.** Thirty circles across a card is ~7½pt each — the
  least legible thing on the screen — and a dot could only say trained / did not. It is now a
  calendar-shaped grid: **a column per weekday, a row per week, four weeks**, oldest week at the top,
  intensity in four fixed steps off `totalSets`.
  **Weekdays run horizontally because that is how a calendar reads.** The first version ran the other
  way — a column per week, weekday rows, twelve weeks — which is denser but asks the eye to read
  down-then-across against every calendar the user has ever seen. Seven columns also leaves the cells
  large enough to carry a legible intensity.
  Two rules: columns are pinned **Monday-first** rather than deferring to
  `StatsDay.calendar.firstWeekday`, which is locale-driven and would shift every cell by device
  region while the keys stayed put; and the intensity thresholds are **fixed, never scaled to the
  user's own maximum**, since a relative scale repaints history whenever a heavier week lands. Future
  days in the partial bottom row are blank, not drawn as rest days.
- **`TrainingBalanceSummaryView` draws ranked bars, not a sentence.** It computed `topMuscleGroups` —
  an ordered distribution — and rendered an icon tile beside a paragraph about it. Five bars at
  `Color.darkColor` on a descending opacity ramp (the ramp *is* the ranking; `MuscleGroup` carries
  only `id` and `name`, so five invented colours would add a dimension carrying no information). The
  sentence survives as a caption, because it says the thing bars cannot: what to do about the shape.
  Bars scale against the **leading group**, not the total — five shares of one split are all short
  bars. `MuscleGroupShareRow` is deliberately **not** the detail screen's `MuscleGroupBar`: that one
  stacks header over full-width bar at ~28pt a group, which is 140pt for five on a summary card.
- **Exercise rows carry a solid 44pt `darkColor` tile**, the anchor the workout library rows already
  use and for the same reason. `ExerciseStats` has no category, so the glyph is the one distinction
  the model makes — `timer` for `isTimeBased`, `dumbbell.fill` otherwise. `ExerciseRowContent` is
  shared with `ExerciseListScreen`, so both lists gained it.
- **A `SectionContainer` header sits on the page background, not on the card** — the page is
  `Color.darkColor`, which is why the title is `.white`. Anything put in `headerTrailing` must be
  light. The "View all" button was `.orange` (an accent used nowhere else), then briefly `darkColor`
  — the background colour, so the button was still present and still tappable but **invisible**. It
  is now a white-on-`white.opacity(0.18)` capsule with a chevron, so it reads as the button it is.
- **`TrainingLoadSummaryView` is one card with both ratios as side-by-side tiles**, replacing a
  full-width card each. Side by side they compare, which is the point of having two — a high session
  ratio beside a flat volume one says the extra work was unloaded. The tiles carry **no zone bar**:
  the four-segment 0–2 scale does not survive halving (the Caution band is 10% of the width), and
  the old bar drew its marker at 1.0 when `ratio` was `nil`, parking a grey pointer mid-Optimal under
  a "Not enough data" label — an absence rendered as a reading. The scale lives on the detail screen.

### Every stats screen is `darkColor` behind `SectionContainer` cards
The four screens had drifted into two families. `StatsKitHomeScreen` and `ExerciseDetailScreen` were
on `Color.darkColor` with `SectionContainer`; `ACWRDetailScreen` and `TrainingBalanceScreen` were on
`systemGroupedBackground` with the card chrome —
`.padding(16).background(systemBackground).clipShape(16).overlay(stroke).padding(.horizontal, 16)` —
**written out inline sixteen times between them.** Pushing from the home screen into a detail screen
changed the frame of the whole app. All four now match, and every card goes through
`SectionContainer`.

- **A `SectionContainer` header sits on the page, not on the card**, which is why its title is
  `.white`. Two bugs came from forgetting that, and both were *invisible* rather than ugly:
  `ExerciseListScreen` set **no background at all**, so its section title was white on white in light
  appearance; and the home screen's "View all" was briefly `darkColor`, the page colour. **Anything
  placed on a section header must be light.**
- **`MiniLineChart.title` and `MiniBarChart.title` are optional** (`String? = nil`). Both are used at
  two levels: `ProgressChartSection` stacks three inside one container, so each needs its own
  sub-heading, while on `ACWRDetailScreen` the chart is the card's only content and the container's
  header already names it — a title there printed the heading twice. When `nil`, `MiniLineChart`
  still shows its peak-value label.
- Card titles that were inline uppercase `.secondary` captions *inside* the card moved up into the
  container's header. `AcuteChronicComparisonChart` keeps its acute/chronic legend inside the card,
  because a legend belongs next to the marks it explains.
- **No sharp system accent remains anywhere in the module.** Beyond the ACWR zones, the sweep caught
  `ExerciseDetailScreen`'s four `StatCell` accents and its five `.yellow` personal bests, the
  `ProgressChartSection` series, `colorForMovement`, `WeeklyLineChart` and `SimpleLineChart`. `StatCell`
  icons are `darkColor`; series colours are the matte set. Two stray `print`s in view bodies went with
  them (error logging in the view models is the house pattern and stays).

### Charts and previews
Hand-built, as everywhere. `ProgressChartSection` derives **13 buckets of 7 days = 91 days** from a
private `buildWeeks(from:)` shared by both chart sections *so the x-axis is identical*, and decides
which series to draw from the exercise (`showReps` / `showTime` split on `isTimeBased`).
`buildWeeks` steps days through `StatsDay`, **not `Calendar.current`** — it did, which put every
bucket boundary a day out from the UTC keys it looks up for any user east of GMT, and its label
formatter is pinned to the same zone so a bar's label and its contents cannot disagree.
`WeeklyChartData.hasData` / `ACWRPoint.hasAnyValue` drive the empty states; the first three
`ACWRPoint`s are nil-valued because they exist only as the chronic baseline.

**`MockDailyTotalsProvider` generates 120 days**, not a handful — the same window the real loader
fetches, so previews exercise the full 28-day chronic window rather than a short one that hid the
ACWR's edges. Every third active day is deliberately workload-less, which is the exact case the two
separate ACWRs exist for. A mock that only produces happy data is not useful here.

### On the CI test plan
`StatsKitTests` — `ACWRTests`, `TrainingLoadMetricTests`, `HomeStatsStreakTests`,
`DailyTotalDecodingTests`, `TrainingWeekTests` — is in `CI_iOS_TestPlan.xctestplan`, but CI is not
running. See *Testing → CI*.

## DISCOVER Tab — `DiscoverKit`
Exercises, public workouts and clips, with ratings, comments, likes, tags and moderation. Firestore
only — nothing reads the Realtime Database. The full build history, every rule and index, and the
**rollout checklist** are in `DISCOVER_PLAN.md`; this section is the shape and the reasons.

### Cards — the server owns every count
DISCOVER lists **cards**, never subject documents: `DiscoverExercises/{id}`, `DiscoverWorkouts/{id}`,
`DiscoverClips/{id}`, each a projection of its subject plus counts, written **only by Cloud
Functions**. Counts never live on `Exercises` / `WorkoutTemplates` / `Clips` themselves: authors save
templates and clips with a plain `setData`, which would wipe any count on the next save. Every card
carries `status` (`visible` / `hidden`, moderation's field) and workouts and clips `isPublic`; every
query filters on both, and the rules reject a query that does not.

- **Every count is a recount, never a delta** — ratings, comments, replies, likes, tag votes. Triggers
  are at-least-once; a `+1` per event double-counts every redelivery, permanently.
- **`score` orders "top rated" and is never shown** — a Bayesian average. The displayed average is
  `RatingSummary.average` (`ratingSum / ratingCount`), the one place it is worked out.
- **Every count on a card model is optional.** A new card has none, and a non-optional count would
  fail to decode every card nobody has rated yet.

### Ratings, comments, likes
- Ratings 1–10, one per user (`Ratings/{uid}`), exercises and workouts only — **clips are never
  rated**. You cannot rate your own workout.
- Comments: one level of replies via `parentId` (stored as an explicit `null` on top-level comments —
  Firestore cannot query a missing field). **No editing.** Deleting your own is a soft delete (text
  cleared, `status: removed`) so replies keep a parent. Authors are stored as `authorId` only and
  resolved at display time through `CachingUserProfileLoader`.
- Likes on comments and clips, one document per user. Every action shows before the server confirms
  and is put back on failure.

### Tags — one rule for exercises and workouts
**Base tags** (a workout author's `tags`, or curated tags seeded onto a catalogue exercise) are always
visible and count as one vote; **community tags** (`TagVotes/{uid}`, a user's whole set in one
document, at most 10) become visible at **3 voters**. A user sees their own votes at once, outlined,
before anyone else does. **Private workouts are never indexed.** The directory is `Tags/{tag}`, with
subjects under `Tags/{tag}/TaggedExercises` and `/TaggedWorkouts` — not `Exercises`, because the
functions find a subject's entries by collection-group query and that name would match the catalogue.
`WorkoutTag.normalized` is the one tag rule on the client, reached through `TagNormalizer`.

### Moderation
Report a comment, someone else's public workout or clip, or a tag — a fixed reason list, never free
text. Hidden for everyone at **3 distinct reporters or 1 admin** (the `admin` custom claim, read from
Auth on the server). Hiding a workout or clip hides its **card** only — the author's copy still works
in MyDay. **Blocking is on the device**: `DiscoverModerationStore`, one per flow, filters blocked
users' comments, clips and workouts and anything the user reported, at once. Nothing un-hides
automatically; restoring is the admin app's, from `ModerationQueue`. **Comments must not reach real
users unless moderation is rolled out with them** (Apple guideline 1.2).

### Workout pages — Save to Library, a copy
The workout page's one action is **Save to Library** — never "Add to Today"; a day is MyDay's. The
save is a **copy** (`WorkoutTemplateModel.copy(savedBy:)` — new id, the saver's, private,
`copiedFrom` set), so the author editing theirs never changes it. It goes through **MyDay's own saver
and library manager** (`MyDayWorkoutLibrary`), so it syncs like any template and shows in MyDay's
library at once.

### How the framework meets the app
DiscoverKit imports no other framework and defines its own models. Where it needs something another
framework owns, it declares a protocol and the composition root answers it: `TagNormalizer` →
`WorkoutTag`, `ClipWatchRecorder` → the existing `FirebaseFunctionsViewClipRecorder` (which serves
MyDay's `ViewClipRecorder` too), `WorkoutCopySaver` → MyDay's library. **Every Firestore path is in
the composition root**: `DiscoverSubject+Firestore` (subjects, cards, ratings, comments, tag votes),
`DiscoverLikeTarget+Firestore`, `DiscoverTagPath`, `DiscoverReportTarget+Firestore`,
`DiscoverBlockPath`. `DiscoverSubject` and `DiscoverLikeTarget` are `@frozen` — DiscoverKit builds with
library evolution, and without it every `switch` over them in the app needs an `@unknown default`.

### Emulator
`InTheGym-Scripts/Emulator/SeedDiscover.py` seeds accounts, exercises, workouts and activity; the
functions build every card and count from it, so build the functions on the current branch first.
Run the app with **InTheGym-EM** and sign in as `demo@inthegym.test`.

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

What the code writes today, gathered in one place. **Firestore is the forward store; the Realtime
Database is the legacy one**, and `Users` is decoded from *both* — Firestore `Users/{uid}` on the
launch path, RTDB `users/{uid}` for followers / coaches / requests — so a field written to only one
appears on some screens and not others.

| Path | Store | Written by |
|---|---|---|
| `Users/{uid}` | Firestore | `createAccount` Cloud Function |
| `Profiles/{uid}` | Firestore | **Cloud Functions only** (`syncProfile`) — the public projection of `Users`; others read this, never `Users` |
| `Users/{uid}/WeightTracking/{yyyy-MM-dd}` | Firestore | `createAccount` (signup weight), ProfileKit's `FirestoreWeightEntryWriter`; newest copied to `Users.weightKilograms` by `syncLatestWeight` |
| `Follows/{followerId}_{followeeId}` | Firestore | follower creates (`FirestoreFollowWriter`), either deletes; `mirrorLegacyFollow` bridges legacy RTDB follows in. Counts on `Profiles` by `profileFollowCounts` |
| `Users/{uid}/MyDay/{yyyy-MM-dd}` | Firestore | `MyDayFirestoreSaver` — whole day, `setData(merge: true)` |
| `Users/{uid}/ExerciseStats/{exerciseID}/RawLogs/{logID}` | Firestore | both logging paths, per set |
| `Users/{uid}/WorkoutSessions/{id}` | Firestore | `FirestoreCompletedWorkoutSessionSaver` (batched) |
| `WorkoutSessions/{sessionId}` | Firestore | same batch — analytics copy, the only one to gain `deletedAt` |
| `Users/{uid}/WorkoutTemplates/{id}` | Firestore | `FirestoreWorkoutTemplateUploader` — the author's library, what `FirestoreWorkoutTemplateFetcher` reads |
| `WorkoutTemplates/{id}` | Firestore | `FirestoreTopLevelWorkoutTemplateUploader` — every template, top level; both composed by `UserAndTopLevelWorkoutTemplateUploader` |
| `Usernames/{username}` | Firestore | `FirestoreUsernameReserver` — **case-sensitive document id** |
| `Clips/{clipId}` | Firestore | `FirestoreMetadataDecorator` — **not `TestClips`** (the Storage files still are) |
| `DiscoverExercises/{id}`, `DiscoverWorkouts/{id}`, `DiscoverClips/{id}` | Firestore | **Cloud Functions only** — DISCOVER's cards |
| `{subject}/Ratings/{uid}` | Firestore | `FirestoreRatingWriter` — exercises and workouts |
| `{subject}/Comments/{id}`, `…/Comments/{id}/Likes/{uid}` | Firestore | `FirestoreCommentWriter` / `Remover`, `FirestoreLikeWriter` |
| `Clips/{id}/Likes/{uid}` | Firestore | `FirestoreLikeWriter` |
| `{subject}/TagVotes/{uid}` | Firestore | `FirestoreTagVoteWriter` — the user's whole tag set |
| `Tags/{tag}`, `Tags/{tag}/TaggedExercises\|TaggedWorkouts/{id}` | Firestore | **Cloud Functions only** — the tag directory |
| `Reports/{uid}_{sha256(path)}` | Firestore | `FirestoreReportWriter` — create-only |
| `ModerationQueue/{sha256(path)}` | Firestore | **Cloud Functions only** — read by the admin app |
| `Users/{uid}/BlockedUsers/{uid}` | Firestore | `FirestoreBlockedUsersWriter` |
| `users/{uid}`, posts, followers, requests | RTDB | `FirebaseDatabaseManager` |
| `Following/{uid}`, `Followers/{uid}` | RTDB | the **legacy** follow graph, written only by the old Follow button now; migrated and bridged into `Follows` |
| `CoachPlayers/{coachId}`, `PlayerCoaches/{playerId}` | RTDB | the coach↔athlete link — see *Coach-Assigned Workouts* |
| `Documents/MyDays/{uid}/{date}.json` | disk | `MyDayFileManagerSaver` |
| `Documents/WorkoutTemplates/{uid}/{id}.json` | disk | `FileManagerWorkoutTemplateUploader` |
| `Documents/PendingSync/workoutTemplates_{uid}.json` | disk | `SyncQueueWorkoutTemplateUploader` |

**The path lives on the model, never at the call site.** `FirebaseInstance` requires
`var internalPath: String`, `FirebaseModel` requires `static var path: String`, and
`typealias FirebaseResource = FirebaseInstance & FirebaseModel`; Firestore models conform to
`FirestoreResource` (`collectionPath`, `documentID`). A view model building
`"Users/\(uid)/MyDay/\(date)"` inline is the shape *Account Creation* records moving away from.

`FirestoreManager.shared` (a `private init` singleton behind a `FirestoreService` protocol, with a
no-op `PreviewFirestoreService` in the same file) is the one place a multi-method protocol is
accepted, because it is generic CRUD — `upload<Model: FirestoreResource>`, `upload(data:at:)`,
`read<T: Codable>(at:)`, `readAll<T: Codable>(at:)`, all `async throws`.

**Rules are not in this repository.** A client write to a new top-level collection is denied until
they are deployed elsewhere, and permission-denied is a hard failure the SDK never retries.

## Long-term Architecture Goal
Each tab to become its own framework. Shared core features (e.g. user profile loading)
to be extracted into dedicated frameworks as usage spans multiple tabs.

### Shared UI — the next extraction, not yet built
The four active modules are now all frameworks and all draw the same design, by **copying it**. Today
that means four `Color+Extension.swift` files, four error banners (`AccountCreationErrorBanner`,
`LoginErrorBanner`, `VerifyEmailErrorBanner`, `PurchaseErrorBanner`), two field cards, and the
52pt/radius-14 primary button re-implemented in a dozen places. The note under *Workout Completion
Rules* — "keep new gated buttons in step with it" — is that tax written down.

A shared UI framework (colours, field card, error banner, primary and disabled button) consumed by
MyDayKit, StatsKit, AccountCreationKit and LoginKit would remove all of it, and is exactly the
"shared core features extracted as usage spans multiple tabs" this section already calls for.
**Not started, and not costless**: it adds a dependency edge to every module and every shared
component has to be `public`. Scope it before committing.

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

## Keep in step — index
Every pair below is documented in full in its own section above; this is just somewhere to look them
up. Each exists because changing one side alone has already broken something, and each carries a
comment in the source saying so. **Changing one without the other is the single most repeated defect
in this codebase.**

| This | …and this | Section |
|---|---|---|
| `WorkoutSetRecord.getStats(...)` | `ExerciseCompletions.getStats()` | Exercise Stats Raw Logs |
| `SessionSetPillValue.values(for:record:)` | `SessionSetPillValue.values(for: ExerciseCompletions)` | MYDAY Workout Flow |
| `SessionSetInput.target(for:)` | `SessionSetDetailOverlay.resetInputsToTarget()` | MYDAY Workout Flow |
| `SessionSetPill` | `SessionSetPillPlaceholder` | MYDAY Workout Flow |
| `ExerciseCompletionView` | `MyDayWorkoutSessionExerciseCard` | MYDAY Workout Flow |
| `SetDetailView` | `SessionSetDetailOverlay` (**but not its editing**) | MYDAY Workout Flow |
| `CompletedSetView` | a completed `SessionSetPill` | MYDAY Workout Flow |
| `MyDayHomeScreen.setDetailOverlay` animation | the session screen's overlay animation | MYDAY Workout Flow |
| `FileManagerWorkoutTemplateUploader` date strategy | `FileManagerWorkoutTemplateFetcher` date strategy | Library reads are local-first |
| `StatsDay.calendar` | `DateFormatter.yyyyMMdd` | STATS Tab |
| `StatsDay` (StatsKit) | ProfileKit's `WeightDay` — both UTC, as the server's `dateKey()` | PROFILE_PLAN.md step 4 |
| AccountCreationKit's body sheets, `HeightUnit`, `BodyWeightUnit`, `BodyMeasurementRow` | ProfileKit's copies (`ProfileHeightUnit`, `ProfileWeightUnit`, …) | PROFILE_PLAN.md step 4 |
| `AccountCreationFieldCard` / `AccountCreationErrorBanner` | ProfileKit's `EditProfileFieldCard` / `ProfileErrorBanner` | Shared UI |
| `ProfileDetails` limits (100 / 300) | `AccountCreationHomeViewModel` limits, and the `Users` update rule | PROFILE_PLAN.md step 3 |
| `LoginFieldCard` / `LoginPrimaryButton` / `LoginErrorBanner` | their AccountCreationKit twins | Auth, Shared UI |
| the six `Color+Extension.swift` | each other | Brand Colours, Shared UI |
| DiscoverKit's `SectionContainer` | StatsKit's `SectionContainer` | DISCOVER_PLAN.md step 2 |
| `WorkoutTag.maxLength` | `MAX_TAG_LENGTH` in the Cloud Functions' `Tags/TagRejection.ts` | DISCOVER_PLAN.md step 1 |
| `DiscoverReportTarget+Firestore` path shapes | `Discover/Moderation/ReportTarget.ts` | DISCOVER Tab |
| `FollowPath` (app) | the functions' `followId()` and the `Follows` create rule's id check | PROFILE_PLAN.md step 5 |
| `DiscoverTagPath` subcollection names | `TAGGED_EXERCISES` / `TAGGED_WORKOUTS` in `SyncTagDirectory.ts` | DISCOVER Tab |
| `DiscoverTaggingViewModel.maxMyTags` (10) | `MAX_TAGS_PER_VOTER` in `VoterTags.ts`, and the rules | DISCOVER Tab |
| `DiscoverCommentsViewModel.maxLength` (500) | the comment rules' `text.size()` limit | DISCOVER Tab |
| `DiscoverReportReason` raw values | the rules' accepted `reason` list | DISCOVER Tab |

## Analysis artefacts — `.results/`, gitignored
A generated structural analysis can be produced into `.results/`: `1-techstack.md`,
`2-file-categorization.json` (every file, 55 categories), `3-architectural-domains.json`,
`4-domains/*.md` (15 domain deep-dives with real code), `5-style-guides/*.md` (one per category).

**It is gitignored and will not be in a fresh clone** — it is derived from the source and goes stale
the moment the source moves, so it is regenerated rather than tracked or hand-edited. Regenerate with
the `instruction-generation` prompt chain
(`bitovi/ai-enablement-prompts` → `plugins/code/skills/instruction-generation/`), pointing it at
`.results` with `CLAUDE.md.generated` as the final output so it cannot overwrite this file.

**This file is the authoritative one.** Anything in `.results/` that turns out to matter belongs
here, in prose, with the reason attached.

## What Not To Do
- Do not use Swift Charts
- Do not use `Array(repeating:count:)` for reference types
- Do not use `.insetGrouped` list style
- Do not use `popToRootViewController()`
- Do not modify `ITGWorkoutKit`
- Do not put concrete infrastructure in framework layer — composition root only
- Do not create multi-purpose files — one concept per file
- Do not give one reader or writer two destinations — one writer per path, composed by a decorator
  (see *Composition root mechanics*)
