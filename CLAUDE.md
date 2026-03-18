# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Code Quality Rule

**Always run `flutter analyze` on modified files before declaring a task done.** Fix all errors **and** deprecation warnings, then run analyze again to confirm zero issues. This catches type errors and deprecated API usage before the user has to re-run and re-report.

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
- **HomeBloc**: Central bloc managing the product catalog (loaded from SQLite), cart, and search. Products and categories are stored in `kasway.db` via `AppDatabase`.
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

## Item Management System

Products and categories are persisted in SQLite (`sqflite`) via `AppDatabase` singleton. On first launch the DB is seeded with the original 50 products across 5 categories.

### Files
| File | Purpose |
|------|---------|
| `lib/data/database/app_database.dart` | SQLite singleton: schema, migrations, seed data |
| `lib/data/repositories/product_repository.dart` | DB-backed CRUD for products and categories |
| `lib/features/items/view/item_management_page.dart` | Tab-based product list, accessible from Profile |
| `lib/features/items/view/item_form_page.dart` | Add/Edit product form (pushed imperatively) |
| `lib/features/items/view/category_management_page.dart` | Category CRUD (pushed imperatively) |

### Navigation
Profile → **Item Management** (`/profile/items`) → `ItemManagementPage`
- Manage categories: `IconButton(Icons.category_outlined)` in AppBar → `CategoryManagementPage` (imperative push)
- Add/edit items: pushed imperatively via `Navigator.of(context).push(MaterialPageRoute(...))` with `BlocProvider.value` to share the parent `HomeBloc`

### Optimistic Updates
All 6 catalog events (`HomeCatalogProduct{Added,Updated,Deleted}`, `HomeCategory{Added,Renamed,Deleted}`) follow the pattern:
1. Emit new state immediately (UI updates instantly)
2. `await _productRepository.persistXxx()`
3. On error: `emit(previous)` — silent rollback

### Schema (kasway.db, version 1)
```sql
categories(name TEXT PK, sort_order INTEGER)
products(id TEXT PK, name TEXT, price REAL, description TEXT, category_name TEXT)
additions(id TEXT PK, product_id TEXT, name TEXT, price REAL)
```
Category rename cascades: DB transaction updates both `categories` and all matching `products.category_name`.

### HomeBloc catalog events
```dart
// Add to catalog
bloc.add(HomeCatalogProductAdded(category: 'Makanan', product: p));

// Edit (handles cross-category moves via oldCategory)
bloc.add(HomeCatalogProductUpdated(oldCategory: 'Makanan', category: 'Promo', product: p));

// Delete (also removes from active cart)
bloc.add(HomeCatalogProductDeleted(category: 'Makanan', productId: 'f1'));

// Categories
bloc.add(HomeCategoryAdded('New Category'));
bloc.add(HomeCategoryRenamed(oldName: 'Old', newName: 'New'));
bloc.add(HomeCategoryDeleted('Empty Category'));  // only when count == 0
```
