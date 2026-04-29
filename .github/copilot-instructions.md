<!-- .github/copilot-instructions.md: Guidance for AI coding agents working on this Flutter app -->
# House Money Calculator — Copilot Instructions

Purpose: provide concise, actionable context so AI coding agents are productive immediately.

- Quick start
  - Install deps: `flutter pub get`
  - Run app: `flutter run -d <device_id>` (entry: [lib/main.dart](lib/main.dart#L1-L40))
  - Run tests: `flutter test`
  - Generate Hive adapters: `flutter pub run build_runner build --delete-conflicting-outputs`

- Big picture (why this structure)
  - Flutter app split into presentation/features, domain (pure logic), and data (persistence). See README for the tree.
  - App bootstrap: [lib/main.dart](lib/main.dart#L1-L40) initializes Hive, registers adapters, opens boxes, initializes Supabase and starts `ProviderScope`.
  - Router & onboarding gate: [lib/router/app_router.dart](lib/router/app_router.dart#L1-L200) uses `Hive.box('app_settings').get('onboarding_done')` to redirect to `/onboarding` on first run.
  - App widget: [lib/app.dart](lib/app.dart#L1-L120) wraps app with `OfflineBanner` and provides `MaterialApp.router` using `AppRouter.router`.

- Key files and folders (start here)
  - [lib/main.dart](lib/main.dart#L1-L40) — initialization (Hive, Supabase, ProviderScope).
  - [lib/app.dart](lib/app.dart#L1-L120) — root widget and theme.
  - [lib/router/app_router.dart](lib/router/app_router.dart#L1-L200) — go_router configuration and onboarding redirect.
  - `lib/features/*` — feature screens (home, rent_compare, semi_rent, loan_interest, monthly_expense, tax_deduction).
  - `lib/data/` — models and local persistence (Hive). See `calculation_history` model and `calculation_history_store`.
  - `lib/domain/` — pure calculation/business logic (reusable, unit-testable functions).
  - `lib/shared/widgets/` — common widgets (e.g., MoneyInputField, HelpIcon).
  - `pubspec.yaml` — dependency list; notable deps: `flutter_riverpod`, `go_router`, `hive`, `supabase_flutter`.

- Conventions and discoverable patterns
  - State management: `flutter_riverpod` (prefer `StateNotifierProvider` where present). Look for providers under `lib/providers` and feature-level providers.
  - Persistence: uses Hive boxes. Common box names: `'app_settings'` (onboarding flag) and a box for `CalculationHistory` (see `lib/data/local`). When adding a Hive model: add model to `lib/data/models`, annotate with `@HiveType`, add adapter generation and register adapter in `main.dart` before opening boxes.
  - Routing: single source of truth in `AppRouter.router`; onboarding gating is implemented as a redirect—update carefully.
  - UI components: money inputs use `MoneyInputField` with built-in formatting and quick adjustment buttons—search `money_input_field.dart` when changing inputs.

- Codegen & tests
  - Run `flutter pub run build_runner build --delete-conflicting-outputs` after model/adapter changes.
  - Unit tests live under `test/` mirroring `lib/` structure; run `flutter test`.

- Integration points and secrets
  - Supabase configuration is centralized at `lib/core/config/supabase_config.dart` — check before changing auth flows.
  - Many platform plugins are used (share_plus, screenshot, connectivity_plus). When modifying native behavior, check `android/` and `ios/` folders.

- Practical editing tips for agents
  - When adding a new persistent model: update `lib/data/models`, run build_runner, register the adapter in `main.dart`, and add migration if necessary.
  - When changing onboarding behavior: adjust redirect logic in [lib/router/app_router.dart](lib/router/app_router.dart#L1-L200) and the `onboarding_done` key in the `app_settings` box.
  - If UI tests or device-only features fail, reproduce locally using `flutter run` on an emulator/device before proposing wide changes.

- What not to assume
  - Do not assume environment variables for Supabase are present; the project initializes `Supabase.initialize` in `main.dart` (inspect `lib/core/config/supabase_config.dart`).
  - Do not remove Hive adapter registration from `main.dart` — tests and runtime rely on adapters being registered before opening boxes.

- If anything is unclear or you'd like examples added (PR template, commit message hints, or automated checks), tell me which part to expand.
