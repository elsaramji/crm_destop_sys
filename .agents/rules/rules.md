---
trigger: always_on
---

# AI Agent Implementation Guide — CRM Desktop App

**Purpose of this file:** This is a technical instruction set for an AI coding agent (e.g., Claude Code) implementing the CRM system described in the companion PRD (`CRM-PRD.md`). It defines the tech stack, architecture rules, folder structure, build order, and testing scope. Follow this file literally — it encodes the author's explicit engineering decisions, not suggestions to reconsider.

**Reference:** Product requirements, data model, and feature list live in `CRM-PRD.md`. This file is the "how to build it," that file is the "what to build."

---

## 1. Non-Negotiable Technical Decisions

These come directly from the author and must not be substituted with alternatives, even if you think another package is "better":

| Decision | Choice | Notes |
|---|---|---|
| State management | **Cubit** (from `bloc`) | Not full Bloc with events — Cubit only, for simplicity |
| State persistence/cache | **hydrated_bloc** | Every Cubit that needs to survive app restarts extends `HydratedCubit` |
| Platform | **Desktop only** | Windows primary target; keep macOS/Linux buildable since Flutter Desktop supports both, but do not build mobile-specific UI |
| UI system | **Material Design (Material 3)** | Use Flutter's built-in Material widgets — no Cupertino, no custom design system unless explicitly asked later |
| Local storage | **drift** (SQLite) | Not Hive, not shared_preferences for data (only hydrated_bloc's own cache uses its default storage) |
| Dependency Injection | **get_it + injectable** | Code-generated DI registration, not manual `GetIt.instance.registerSingleton` calls scattered around |
| Architecture | **Clean Architecture + SOLID** | Domain → Data → Presentation, dependency rule strictly enforced (see §4) |
| Testing scope | **Unit tests only, logic only** | Test use cases, Cubits, repositories, mappers. **Do not** write widget tests, golden tests, or integration tests unless explicitly requested later |
| Flutter version management | **FVM** | Pin the project to one Flutter version via `fvm`, never rely on a globally-installed Flutter |

---

## 2. Pinned Package Versions (stable, as of Sept 2026)

Run `flutter pub outdated` before you start coding to confirm nothing newer-but-still-stable has landed since this doc was written — pin to the latest **stable** (non-prerelease) version at implementation time, using these as the floor:

```yaml
environment:
  sdk: ">=3.13.0 <4.0.0"
  flutter: ">=3.47.1"

dependencies:
  flutter:
    sdk: flutter

  # State management
  bloc: ^9.0.0
  flutter_bloc: ^9.1.1
  hydrated_bloc: ^11.0.0
  path_provider: ^2.1.5        # required by hydrated_bloc storage on desktop

  # Dependency Injection
  get_it: ^9.2.1
  injectable: ^2.7.1

  # Local storage (drift)
  drift: ^2.32.1
  drift_flutter: ^0.2.8        # simplifies desktop DB file setup
  sqlite3_flutter_libs: ^0.5.30 # bundles native sqlite3 for desktop builds
  path: ^1.9.0

  # Excel import/export (from the PRD's P0-10/P0-11)
  excel: ^4.0.6                # or syncfusion_flutter_xlsio if richer formatting is needed later

  # Value equality / immutability
  equatable: ^2.0.7
  freezed_annotation: ^2.4.4

  # Functional error handling (Either/Failure pattern — fits Clean Architecture)
  fpdart: ^1.1.1               # modern, actively maintained alternative to dartz

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code generation
  build_runner: ^2.4.15
  injectable_generator: ^2.6.2
  drift_dev: ^2.32.1
  freezed: ^2.5.8

  # Testing (unit tests only — see §7)
  bloc_test: ^10.0.0
  mocktail: ^1.0.4

  # Linting
  flutter_lints: ^5.0.0
```

**Do not add:** `provider`, `riverpod`, `hive`, `shared_preferences` (for domain data), `get` (GetX), or any other state management/DI/storage package — they conflict with the decisions in §1.

---

## 3. FVM Setup (do this first, before any code)

```bash
dart pub global activate fvm
fvm install 3.47.1
fvm use 3.47.1 --force
```

Then always prefix Flutter/Dart commands with `fvm`:
```bash
fvm flutter pub get
fvm flutter run -d windows
fvm dart run build_runner build --delete-conflicting-outputs
```

Add `.fvm/` to version control per FVM's standard convention (commit `.fvm/fvm_config.json`, ignore the cached SDK symlink itself). Add a `.fvmrc` or confirm `fvm_config.json` pins exactly `3.47.1` so any machine (or CI) that clones the repo builds with the identical Flutter version.

---

## 4. Project Structure — Feature-First + Clean Architecture

Use a **feature-first** top-level structure, with each feature internally split into the three Clean Architecture layers. This is what point #7 in the brief means by "start with implementation domains in features" — every feature's **domain layer is built before its data or presentation layer**, because domain has zero dependencies on the other two (dependency rule: `presentation → domain ← data`, domain depends on nothing).

```
lib/
├── main.dart
├── injection.dart                     # injectable @InjectableInit setup
│
├── core/
│   ├── di/
│   │   └── injection.config.dart      # generated by injectable
│   ├── error/
│   │   ├── failures.dart              # sealed Failure classes (Freezed)
│   │   └── exceptions.dart
│   ├── usecase/
│   │   └── usecase.dart               # abstract UseCase<Type, Params> base class
│   ├── database/
│   │   ├── app_database.dart          # drift @DriftDatabase class, all tables registered here
│   │   └── tables/
│   │       ├── customers_table.dart
│   │       ├── services_table.dart
│   │       ├── activities_table.dart
│   │       ├── orders_table.dart
│   │       └── bills_table.dart
│   ├── theme/
│   │   └── app_theme.dart             # Material 3 ThemeData
│   └── utils/
│
├── features/
│   ├── customer/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── customer.dart
│   │   │   ├── repositories/
│   │   │   │   └── customer_repository.dart      # abstract interface
│   │   │   └── usecases/
│   │   │       ├── create_customer.dart
│   │   │       ├── update_customer.dart
│   │   │       ├── search_customers.dart
│   │   │       └── get_customer_by_id.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── customer_model.dart            # maps drift row ↔ domain entity
│   │   │   ├── datasources/
│   │   │   │   └── customer_local_datasource.dart # wraps drift DAO calls
│   │   │   └── repositories/
│   │   │       └── customer_repository_impl.dart  # implements domain interface
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── customer_list_cubit.dart        # extends HydratedCubit
│   │       │   ├── customer_list_state.dart
│   │       │   ├── customer_form_cubit.dart
│   │       │   └── customer_form_state.dart
│   │       ├── pages/
│   │       │   ├── customer_list_page.dart
│   │       │   └── customer_form_page.dart
│   │       └── widgets/
│   │
│   ├── service/          # same domain/data/presentation split
│   ├── activity/         # same domain/data/presentation split
│   ├── order/            # same domain/data/presentation split
│   ├── billing/          # same domain/data/presentation split
│   ├── excel_io/         # export/import feature — depends on customer/service/etc. repositories
│   └── auth/             # simple local admin login (P0-12)
│
└── test/
    └── (mirrors lib/features/*/domain and */presentation for unit tests only)
```

**Rule for every feature:** domain layer has **zero imports** from `data/` or `presentation/`, and **zero imports** from `package:drift` or `package:flutter_bloc`. If you find yourself importing Flutter or drift into a domain file, you've broken the architecture — stop and fix it before continuing.

---

## 5. SOLID Mapping (so the "showing my skills" goal in §1 is explicit, not implied)

Apply these concretely, not just as a checklist to claim compliance:

- **Single Responsibility** — each UseCase class does exactly one thing (`CreateCustomer`, not a generic `CustomerService` god-class). Each Cubit manages exactly one screen/flow's state.
- **Open/Closed** — repositories are abstract interfaces in `domain/`; adding a cloud implementation later (v2 per the PRD) means adding `CustomerRepositoryCloudImpl` without modifying any existing use case or Cubit.
- **Liskov Substitution** — any `CustomerRepository` implementation (local or future cloud) must be swappable in the DI container without breaking a single use case.
- **Interface Segregation** — don't create one giant `Repository` interface for everything; each feature (`customer`, `service`, `activity`, `order`, `billing`) gets its own repository interface.
- **Dependency Inversion** — Cubits depend on domain-layer UseCase abstractions, never directly on `CustomerRepositoryImpl` or drift. Wire the concrete implementation only in `injection.dart`/`@LazySingleton(as: CustomerRepository)` annotations.

Additional patterns worth demonstrating intentionally:
- **Repository pattern** — already covered above; this is the seam that makes local→cloud migration (PRD §11, v2) painless.
- **Factory / mapper pattern** — `CustomerModel.fromDrift(row)` / `.toCompanion()` methods that convert between drift's generated row objects and domain entities, so drift-specific types never leak into `domain/` or `presentation/`.
- **Strategy pattern (optional, P1)** — if you implement the Excel import duplicate-handling logic (create vs. update on match), model it as a swappable strategy rather than an `if/else` chain, since the PRD's open question on this may change the strategy later.

---

## 6. State Management & Persistence Pattern

Every Cubit that should survive app restarts (e.g., a "last viewed customer" or draft form state) extends `HydratedCubit<State>` instead of `Cubit<State>`:

```dart
class CustomerFormCubit extends HydratedCubit<CustomerFormState> {
  CustomerFormCubit(this._createCustomer, this._updateCustomer)
      : super(const CustomerFormState.initial());

  @override
  CustomerFormState? fromJson(Map<String, dynamic> json) =>
      CustomerFormState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(CustomerFormState state) => state.toJson();
}
```

Initialize `HydratedBloc.storage` once in `main()` before `runApp`, using a desktop-appropriate storage directory via `path_provider`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationSupportDirectory()).path,
    ),
  );
  configureDependencies(); // injectable
  runApp(const CrmApp());
}
```

Not every Cubit needs hydration — a transient `CustomerListCubit` that just holds a loaded list doesn't need to persist across restarts (it should re-fetch from drift on launch). Use plain `Cubit` for those; reserve `HydratedCubit` for state where persisting the *last UI state* (not the underlying data — that lives in drift) genuinely helps the user experience (e.g., a partially-filled form, last search filter).

---

## 7. Implementation Order

Build in this exact sequence — each step depends on the previous one being in place:

1. **Project scaffold**: `fvm flutter create`, add all pinned dependencies, set up `analysis_options.yaml` with `flutter_lints`.
2. **Core layer**: `Failure`/`Exception` types, base `UseCase` abstraction, drift `AppDatabase` with all 5 tables (empty, no DAOs yet), `injection.dart` skeleton.
3. **Customer feature — domain first**: entity, repository interface, use cases (with no implementation behind them yet — this is intentional, domain layer must compile standalone).
4. **Customer feature — data layer**: drift DAO, local datasource, repository implementation, model mappers.
5. **Customer feature — presentation layer**: Cubit(s), states (use `freezed` for sealed state classes), pages/widgets using Material 3.
6. **Wire DI for customer feature**, confirm end-to-end (create → list → edit) works before moving on.
7. **Repeat steps 3–6 for Service, Activity, Order, Billing features** — each follows the identical domain → data → presentation → DI order.
8. **Excel import/export feature** (depends on all repositories above being in place).
9. **Admin login (auth feature)** — simple local credential check, gates the app shell.
10. **Bilingual UI (Arabic/English toggle)** — apply after core screens exist, using `intl` + `Directionality`, not before (retrofitting localization onto finished widgets is cheaper than building it in blind).
11. **Polish**: dashboard/home summary (P1), custom fields (P1), soft delete (P1) — only after all P0s work end-to-end.

Do not start Service/Activity/Order/Billing presentation layers before Customer's full vertical slice (domain→data→presentation→DI, working) is done — this proves the architecture pattern once, correctly, before repeating it four more times.

---

## 8. Testing Strategy (unit tests only — logic, not widgets)

Per the explicit scope in §1: **write unit tests for logic only.** No widget tests, no golden tests, no integration tests unless asked later.

**What to test:**
- Every UseCase (`domain/usecases/*`) — mock the repository interface with `mocktail`, assert correct calls and correct `Either<Failure, T>` results (success and failure paths).
- Every Cubit (`presentation/cubit/*`) — use `bloc_test`'s `blocTest()`, mock the use cases, assert the exact state sequence emitted.
- Repository implementations (`data/repositories/*`) — mock the local datasource, assert correct mapping and correct failure translation (e.g., a drift exception becomes a `CacheFailure`).
- Model mappers (`CustomerModel.fromDrift` / `.toCompanion()`) — pure function tests, no mocking needed.

**What NOT to test in this version:** Widget rendering, navigation, drift's own generated SQL correctness (trust the generator), Excel file byte-level output (assert on the parsed/round-tripped data instead, not the raw file format).

Example test structure mirrors the source:
```
test/
└── features/
    └── customer/
        ├── domain/
        │   └── usecases/
        │       └── create_customer_test.dart
        ├── data/
        │   └── repositories/
        │       └── customer_repository_impl_test.dart
        └── presentation/
            └── cubit/
                └── customer_form_cubit_test.dart
```

---

## 9. Definition of Done (per feature)

A feature (e.g., "Customer") is not done until:
- [ ] Domain layer compiles with zero Flutter/drift imports
- [ ] Repository interface has a local (drift) implementation registered via `injectable`
- [ ] All use cases have unit tests covering success + failure paths
- [ ] Cubit(s) have `bloc_test` coverage for every public method
- [ ] UI is built with Material 3 widgets, works on desktop window resizing (no fixed pixel widths that break on resize)
- [ ] Data round-trips correctly through drift after app restart
- [ ] `fvm flutter analyze` passes with zero warnings

---

## 10. Open Items to Resolve Before/During Build

Carried over from the PRD — resolve these before the affected feature is built, not after:
- Excel import: create-only vs. create-or-update on existing National ID match (blocks Excel import feature, step 8).
- Phone number format validation rules (Egyptian mobile format) — affects `Customer` entity validation logic.
- Custom fields (P1) data shape — free-text vs. typed — affects the drift schema for that table if/when built.
