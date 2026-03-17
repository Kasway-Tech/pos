# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app
flutter run                          # default device
flutter run -d macos                 # macOS desktop

# Tests
flutter test                         # all tests
flutter test test/features/home/     # specific directory
flutter test test/features/home/bloc/home_bloc_test.dart  # single file
flutter test --coverage              # with coverage

# Linting
flutter analyze

# Code generation (freezed models, json serializable)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch          # watch mode during development
```

## Architecture

Feature-based clean architecture under `lib/`:

```
lib/
├── app/           # App setup: router, theme, global widgets
├── data/          # Models (Freezed) and repositories
└── features/      # Feature modules (home, profile)
    └── <feature>/
        ├── bloc/  # BLoC state management
        └── view/  # Pages and widgets
```

**State management**: BLoC (`flutter_bloc`). All business logic lives in BLoC/Cubit classes; views only dispatch events and render states.

**Navigation**: `go_router` — routes defined in `lib/app/app_router.dart`. Nested routes for the order flow (`/order-confirmation`, `/select-payment-method`, `/payment-success`) and profile section (`/profile/*`).

**Data models**: Immutable classes using `freezed` + `json_serializable`. After changing a model, run `build_runner` to regenerate `.freezed.dart` and `.g.dart` files.

**Theme**: `ThemeCubit` in `lib/app/theme/` manages seed color and theme mode, persisted via `shared_preferences`.

**Currency**: `CurrencyCubit` in `lib/app/currency/` manages selected display currency, live exchange rates, and the Dynamic Pricing toggle, all persisted via `shared_preferences`. See details below.

**macOS-specific**: Window chrome is customized at startup in `main.dart` using `macos_window_utils` and `window_manager` (transparent titlebar, full-size content view). The `MacosTitleBar` widget in `lib/app/widgets/` provides the drag region.

## Key Domain Concepts

- **Product**: Has optional `additions` (variants/customizations with extra price).
- **CartItem**: A product + selected additions + quantity. Has a `totalPrice` getter `(product.price + additions sum) * quantity`.
- **HomeBloc**: Central bloc managing the product catalog (5 hardcoded categories), cart, and search. Products are currently seeded in-memory inside `ProductRepository`.
- **Tablet detection**: `app.dart` detects screen width 600–1200px to adapt layout.

## Currency & Pricing System

All product prices are stored in IDR (Indonesian Rupiah). The currency system converts them at display time.

### Files
| File | Purpose |
|------|---------|
| `lib/app/currency/currency_state.dart` | `Currency` model + `CurrencyState` with `formatPrice(idrPrice)` |
| `lib/app/currency/currency_cubit.dart` | Fetches CoinGecko rates, 60s refresh timer, SharedPreferences persistence |
| `lib/app/widgets/price_text.dart` | `PriceText(idrPrice)` widget — use this everywhere a price is displayed |
| `lib/features/profile/view/currency_settings_page.dart` | Currency picker page (`/profile/currency`) |

### How to display a price
Always use `PriceText(someDoubleInIdr)` instead of formatting directly with `NumberFormat`. It wraps a `BlocBuilder<CurrencyCubit, CurrencyState>` and calls `state.formatPrice(idrPrice)` automatically.

```dart
import 'package:kasway/app/widgets/price_text.dart';

PriceText(product.price, style: someTextStyle)
```

Never hardcode `NumberFormat.currency(locale: 'id_ID', ...)` for prices shown to the user.

### Conversion formula (KAS as bridge currency)
```
price_in_target = (price_in_idr / kaspa_idr_rate) × kaspa_target_rate
price_in_kas    =  price_in_idr / kaspa_idr_rate
price_in_idr    =  price_in_idr  (shown directly, no conversion)
```

### CoinGecko endpoint (no API key)
```
GET https://api.coingecko.com/api/v3/simple/price?ids=kaspa&vs_currencies=idr,usd,eur,gbp,jpy,sgd,myr,aud,cny,hkd,krw
Response: {"kaspa": {"idr": 1234.5, "usd": 0.075, ...}}
```
Rates are stored in `CurrencyState.exchangeRates` as `Map<String, double>` keyed by lowercase currency code.

### Supported currencies
KAS (default), IDR, USD, EUR, GBP, JPY, SGD, MYR, AUD, CNY, HKD, KRW. Defined in `CurrencyState.allCurrencies`.

### Settings integration
- **Default Currency** tile → navigates to `/profile/currency`
- **Dynamic Pricing** toggle → calls `CurrencyCubit.setDynamicPricing(bool)` — when off, the 60s timer stops and prices stay at the last fetched rate

### No-network fallback
When `exchangeRates` is empty or `kasIdr <= 0`, `formatPrice` falls back to displaying IDR directly.

## SVG Assets

`flutter_svg` **does not support CSS class selectors** in `<style>` tags. Any SVG file using `.cls-*` classes will not render correctly.

**Rule**: All SVG assets must use inline presentation attributes (`fill="#6fc7ba"`) rather than class-based styles. When adding or editing an SVG, strip the `<defs><style>` block and move `fill`/`stroke` values inline onto each element.

The Kaspa logo at `assets/svg/payment_methods/kaspa.svg` was already converted to inline styles.

## Country Flags

Use the `country_flags` package (already in `pubspec.yaml`). Do **not** use flag emoji text — regional indicator emoji do not render on macOS Flutter.

```dart
import 'package:country_flags/country_flags.dart';

// By currency code (preferred — maps automatically, e.g. "IDR" → Indonesia flag)
CountryFlag.fromCurrencyCode('IDR', theme: const ImageTheme(width: 40, height: 28))

// By country code
CountryFlag.fromCountryCode('ID', theme: const ImageTheme(width: 40, height: 28))
```

Size is set via `ImageTheme(width:, height:)`. Wrap in `ClipRRect` for rounded corners.
