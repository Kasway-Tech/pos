# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Code Quality Rule

**Always run `flutter analyze` on modified files before declaring a task done.** Fix all errors **and** deprecation warnings, then run analyze again to confirm zero issues. This catches type errors and deprecated API usage before the user has to re-run and re-report.

## Imperative Navigation Rule

**Never call `context.read<T>()` inside a `MaterialPageRoute.builder` closure.** The builder is stored and re-invoked lazily (e.g. when `go_router`'s `refreshListenable` fires a rebuild), at which point the originating `context` is deactivated — causing "Looking up a deactivated widget's ancestor" crashes.

Since `HomeBloc` (and other app-level providers) are provided above `MaterialApp.router`, every imperatively pushed page already has them in its widget tree. Push pages directly — no `BlocProvider.value` wrapper needed:

```dart
// WRONG — context.read inside builder captures a potentially stale context
Navigator.of(context).push(MaterialPageRoute(
  builder: (_) => BlocProvider.value(
    value: context.read<HomeBloc>(),  // crashes on rebuild
    child: SomePage(),
  ),
));

// CORRECT — push the page directly; it reads the bloc from its own context
Navigator.of(context).push(MaterialPageRoute(
  builder: (_) => SomePage(),
));
```

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
| `lib/app/currency/currency_state.dart` | `Currency` model + `CurrencyState` with `formatPrice(idrPrice)` + `formatPriceInFiat(idrPrice, fiat)` |
| `lib/app/currency/currency_cubit.dart` | Fetches CoinGecko rates, 60s refresh timer, SharedPreferences persistence, `setReferenceFiat()` |
| `lib/app/widgets/price_text.dart` | `PriceText(idrPrice)` widget — use this everywhere a price is displayed |
| `lib/features/profile/view/currency_settings_page.dart` | Two-section currency page: **Display Currency** (all 12 incl. KAS) + **Reference Fiat** (11 fiats only) |

### How to display a price
Always use `PriceText(someDoubleInIdr)` instead of formatting directly with `NumberFormat`. It wraps a `BlocBuilder<CurrencyCubit, CurrencyState>` and calls `state.formatPrice(idrPrice)` automatically.

```dart
import 'package:kasway/app/widgets/price_text.dart';

PriceText(product.price, style: someTextStyle)
```

Never hardcode `NumberFormat.currency(locale: 'id_ID', ...)` for prices shown to the user.

### Reference Fiat
`CurrencyState.referenceFiat` is always a fiat `Currency` (never KAS). Defaults to IDR. It is:
- The secondary amount shown in `_RevenuePriceDisplay` when KAS is the display currency (`≈ USD Y.YY`)
- Stored with each withdrawal record (`refFiatCode`, `refFiatAmount`) as a rate snapshot at withdrawal time
- Configurable via the **Reference Fiat** section in `/profile/currency`

Use `state.formatPriceInFiat(idrPrice, state.referenceFiat)` to format in the reference fiat without going through `PriceText`.

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
- **Currency Settings** tile → navigates to `/profile/currency` (two sections: Display Currency + Reference Fiat)
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

### Schema (kasway.db, version 6)
```sql
categories(name TEXT PK, sort_order INTEGER)
products(id TEXT PK, name TEXT, price REAL, description TEXT, category_name TEXT, created_at INTEGER)
additions(id TEXT PK, product_id TEXT, name TEXT, price REAL)
orders(id TEXT PK, total_idr REAL, created_at INTEGER)  -- added in v4
withdrawals(tx_id TEXT PK, to_address TEXT, amount_kas REAL, amount_idr REAL,
            kas_idr_rate REAL, ref_fiat_code TEXT, ref_fiat_amount REAL,
            created_at INTEGER)  -- added in v5; rate snapshot columns added in v6
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

// Record completed order (fire-and-forget, no state change)
bloc.add(HomeOrderCompleted(totalIdr: 25000.0));
```

## Orders System

Completed orders are persisted in SQLite for today's revenue display on the Profile wallet card.

### Files
| File | Purpose |
|------|---------|
| `lib/data/models/order.dart` | Freezed `Order` model (id, totalIdr, createdAt) |
| `lib/data/repositories/order_repository.dart` | `createOrder(double)` + `getTodayRevenue()` |

### Revenue query
`getTodayRevenue()` sums `total_idr` for rows with `created_at >= midnight today` (millisecondsSinceEpoch). Returns 0.0 when no orders.

### When an order is completed
`HomeOrderCompleted` is dispatched in `order_side_view.dart` before `HomeCartCleared`, so the cart total is captured first. The handler is fire-and-forget (no state emitted).

## KaspaWalletService (Pure Dart)

All Kaspa wallet operations are implemented in pure Dart at `lib/data/services/kaspa_wallet_service.dart`. No Rust/FFI bridge is used.

### Dart packages
| Package | Purpose |
|---------|---------|
| `bip39 ^1.0.6` | BIP39 mnemonic generation (`generateMnemonic`) and validation (`validateMnemonic`) |
| `bip32 ^2.0.0` | BIP32 HD key derivation — `BIP32.fromSeed(seed).derivePath(path)` |
| `hex ^0.2.0` | Hex encoding/decoding for scripts and payload |

### API
```dart
final svc = KaspaWalletService();

// 1. Generate mnemonic (synchronous)
final phrase = svc.generateMnemonic(wordCount: 12);

// 2. Validate mnemonic (synchronous)
final (:valid, :error) = svc.validateMnemonic(phrase);
// error contains "InvalidWordCount", "InvalidWord", or "InvalidChecksum" keywords

// 3. Derive Kaspa mainnet address (synchronous, wrap in Future.microtask if needed)
final address = svc.deriveAddress(phrase); // "kaspa:q..."

// 4. Submit transaction (async, REST API)
final (:txId, :error) = await svc.sendTransaction(
  mnemonic: phrase,
  toAddress: 'kaspa:q...',
  amountSompi: 500000000, // 5 KAS
  payloadNote: 'kasway:withdraw:...',
);
```

### Kaspa address encoding
Kaspa uses a **cashaddr-style** encoding (NOT standard bech32): separator `:`, custom 40-bit polymod checksum. Implementation is inline in `KaspaWalletService` — do not use the `bech32` Dart package for Kaspa addresses.

- HRP: `"kaspa"`
- Version byte: `0x00` (PubKey)
- Payload: version_byte + 32-byte x-only pubkey (compressed pubkey[1..]) → convertBits(8→5)
- Derivation path: `m/44'/111111'/0'/0/0` (Kaspa coin type 111111)

### P2PK script format
`OP_DATA_32 (0x20)` + 32-byte x-only pubkey + `OP_CHECKSIG (0xac)` = 34-byte script hex (68 chars).

### Transaction note (known limitation)
`sendTransaction` submits **unsigned** transactions (`signatureScript: ""`). This replicates the former Rust behaviour and means withdrawals may not relay on mainnet. A future task would add Schnorr signing.

## Profile Wallet Card

The profile page header is replaced by `_WalletCard`, a StatefulWidget that:
- Reads `wallet_mnemonic` from SharedPreferences on init
- Calls `KaspaWalletService().deriveAddress(mnemonic)` in a `Future.microtask` to derive the address
- Loads today's revenue via `OrderRepository.getTotalRevenue()` minus `WithdrawalRepository.getTotalWithdrawn()`
- Shows dual-currency revenue: primary in selected currency + secondary KAS↔fiat equivalent (`_RevenuePriceDisplay`)
- Shows **History** (tonal) + **Withdraw** (filled) buttons side by side

`_WithdrawSheet` collects destination address + KAS amount, builds a `payload_note` (`kasway:withdraw:<ISO8601>:<amount>kas:ack:<addr_proof>`), and calls `KaspaWalletService().sendTransaction(...)`. On success, records the withdrawal via `WithdrawalRepository` before closing.

Both `OrderRepository` and `WithdrawalRepository` must be provided in the widget tree (provided at app level via `MultiRepositoryProvider`).

## Withdrawals System

Completed withdrawals are persisted in SQLite. History is accessible from the wallet card.

### Files
| File | Purpose |
|------|---------|
| `lib/data/models/withdrawal.dart` | Freezed `Withdrawal` model (txId, toAddress, amountKas, amountIdr, kasIdrRate, refFiatCode, refFiatAmount, createdAt) |
| `lib/data/repositories/withdrawal_repository.dart` | `recordWithdrawal(...)` + `getWithdrawals()` + `getAllForExport()` |
| `lib/features/profile/view/withdrawal_history_page.dart` | List of past withdrawals with fiat equivalent + copy-TX-ID action |

### Route
`/profile/withdrawals` → `WithdrawalHistoryPage`

### Rate snapshot fields
`kasIdrRate`, `refFiatCode`, `refFiatAmount` are captured at withdrawal time from `CurrencyCubit.state` so historical records are self-contained (not dependent on live rates).

### Export
`DataService` exports both `kasway_data.csv` (catalog) and `kasway_withdrawals.csv` (withdrawals) when the user taps Export in Data Transfer. The withdrawal CSV includes `kas_idr_rate`, `ref_fiat_code`, `ref_fiat_amount` columns.

## Kaspa wRPC Real-Time (Dart WebSocket)

`kaspa-wrpc-client` v0.15.0 is **not usable on native targets** — `kaspa-rpc-core` contains WASM-gated code that fails to compile outside WASM. Rust's `tokio-tungstenite` also fails on macOS Flutter because Rust DNS resolution (`getaddrinfo` via `spawn_blocking`) does not work in the sandboxed Flutter process.

**Solution:** Use `dart:io WebSocket` directly. Dart's networking stack uses macOS-native APIs and works correctly in the Flutter sandbox.

### Public node network — resolver pattern (Dart)
```dart
// Try each resolver in order; fall back to hardcoded URL on failure.
const resolvers = [
  'https://kaspa.stream/v2/kaspa/mainnet/wrpc/json',
  'https://kaspa.red/v2/kaspa/mainnet/wrpc/json',
  'https://kaspa.green/v2/kaspa/mainnet/wrpc/json',
  'https://kaspa.blue/v2/kaspa/mainnet/wrpc/json',
];
const fallback = 'wss://public-pool.kaspa.green:18110';
// Response JSON: {"url": "wss://..."}  (also check "address", "endpoint")
```

### Confirmed wire protocol (getBlockDagInfo polling, 1s interval)
```
Request:  {"id": N, "method": "getBlockDagInfo", "params": {}}
Response: {"id": N, "method": "getBlockDagInfo",
           "params": {"virtualDaaScore": 384349863, "blockCount": ..., ...}}
```
`notifyVirtualDaaScoreChanged` returns "RPC method not found" on this endpoint — use polling instead.
DAA score field: `params["virtualDaaScore"]` (int, no quotes).

### Hardcoded node URL
`wss://rose.kaspa.green/kaspa/mainnet/wrpc/json` — DNS for `public-pool.kaspa.green` fails in this Flutter build environment.

### Dart WebSocket lifecycle pattern
```dart
final ws = await WebSocket.connect(url);
// Poll every second:
Stream.periodic(Duration(seconds: 1)).listen((_) =>
  ws.add(jsonEncode({'id': _reqId++, 'method': 'getBlockDagInfo', 'params': {}})));
await for (final raw in ws) { /* parse params.virtualDaaScore */ }
// Reconnect on close/error with 3s delay; honour _disposed flag.
```

### Route
`/profile/node-status` → `NodeStatusPage` (real-time DAA score, no Rust signals needed)

## Network Switching (Mainnet / Testnet-10)

Runtime network switching without app restart. `NetworkCubit` manages the active network and node URLs.

### Files
| File | Purpose |
|------|---------|
| `lib/app/network/network_state.dart` | `KaspaNetwork` enum + `NetworkState` with `activeUrl`, `networkLabel`, `kasSymbol` getters |
| `lib/app/network/network_cubit.dart` | Persists selected network + custom URLs via SharedPreferences |
| `lib/features/profile/view/network_settings_page.dart` | Settings page: network selector + URL fields + Save button |

### SharedPreferences keys
`kaspa_network` (string: `"mainnet"` / `"testnet10"`), `kaspa_mainnet_url`, `kaspa_testnet10_url`

### Default URLs
- Mainnet: `wss://rose.kaspa.green/kaspa/mainnet/wrpc/json`
- Testnet-10: `wss://electron-10.kaspa.stream/kaspa/testnet-10/wrpc/json`

### KAS symbol
`NetworkState.kasSymbol` returns `'KAS'` on mainnet and `'TKAS'` on testnet-10.
`formatPrice()` in `CurrencyState` accepts an optional `kasSymbol` named parameter (defaults to `'KAS'`).
`PriceText` watches both `CurrencyCubit` and `NetworkCubit` and passes the symbol automatically.

### Auto-reconnect
`NodeStatusPage` wraps its body in `BlocListener<NetworkCubit, NetworkState>` and calls `_reconnect()` whenever `activeUrl` changes. The reconnect sets `_disposed = true`, closes the socket, waits 50 ms, then resets and starts a fresh `_connect()` loop.

### Route
`/profile/network` → `NetworkSettingsPage`
