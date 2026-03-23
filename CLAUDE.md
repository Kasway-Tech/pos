# CLAUDE.md

## Rules

**Always run `flutter analyze` before declaring done.** Fix all errors and deprecation warnings.

**Never `context.read<T>()` inside `MaterialPageRoute.builder`.** Re-invoked lazily on stale context → crash. Push pages directly; app-level blocs are already above `MaterialApp.router`.

```dart
// WRONG
Navigator.of(context).push(MaterialPageRoute(
  builder: (_) => BlocProvider.value(value: context.read<HomeBloc>(), child: SomePage()),
));
// CORRECT
Navigator.of(context).push(MaterialPageRoute(builder: (_) => SomePage()));
```

## Commands

```bash
flutter run -d macos
flutter test && flutter analyze
dart run build_runner build --delete-conflicting-outputs  # Freezed/JSON models
flutter gen-l10n                                          # ARB → Dart (run after editing .arb)
```

## Architecture

`lib/app/` — router, theme, app-level cubits | `lib/data/` — Freezed models + repos | `lib/features/<feature>/{bloc,view}/`

State: BLoC/Cubit. Nav: `go_router`. Models: `freezed` + `json_serializable`. SharedPrefs keys: always use `PreferenceKeys` constants (`lib/app/constants/preference_keys.dart`).

## Localization

Never hardcode English strings — use `context.l10n` (`lib/app/l10n.dart`). Add keys to `lib/l10n/app_en.arb` first, run `flutter gen-l10n`.

Key prefix by feature: `homeXxx`, `paymentXxx`, `itemFormXxx`, `profileXxx`, `settingsXxx`, `networkXxx`, `orderHistoryXxx`, `withdrawalHistoryXxx`, `donateXxx`, `displayXxx`, `tableLayoutXxx`, `categoryXxx`, etc.

Capture l10n strings before async gaps to avoid `use_build_context_synchronously`.

## Prices

All prices stored in **IDR**. Always display via `PriceText(idrPrice)` — never `NumberFormat.currency(...)` directly.

## SVG Assets

`flutter_svg` does not support CSS `<style>` selectors. Use **inline** `fill=` attributes only — strip `<defs><style>` blocks.

## Country Flags

Use `country_flags` package — **not** flag emoji (broken on macOS Flutter).

## Kaspa wRPC

Uses `dart:io WebSocket` directly.

- DAA polling: `getBlockDagInfo` every 1s → `params.virtualDaaScore`. `notifyVirtualDaaScoreChanged` not supported on public nodes.
- Payment detection: `getUtxosByAddresses` polling. First response = baseline. New outpoint with `amount >= expectedSompi * 0.99` = confirmed. Amount is a **string** sompi value.

## Splash / Init

All async init (HomeBloc, WalletCubit, CurrencyCubit) completes at `/splash` before routing. **No spinners in feature pages** for app-level state.
