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

# Localization (ARB → Dart; runs automatically on flutter pub get too)
flutter gen-l10n
```

## Localization (l10n)

All user-visible strings use `AppLocalizations` via the `context.l10n` extension (`lib/app/l10n.dart`). Never hardcode English strings in widgets.

### Files
| File | Purpose |
|------|---------|
| `lib/l10n/app_en.arb` | English template — add new keys here first |
| `lib/l10n/app_<locale>.arb` | Translations for id, ja, ko, ms, zh |
| `.dart_tool/flutter_gen/gen_l10n/` | Auto-generated `AppLocalizations` class |

### Usage
```dart
import 'package:kasway/app/l10n.dart';

// In build():
Text(context.l10n.someKey)
// Parameterized:
Text(context.l10n.someKey(param1, param2))
// Capture before async gaps to avoid use_build_context_synchronously:
final msg = context.l10n.someKey;
await someAsyncOperation();
showSnackBar(msg);
```

### Key naming convention
`camelCase`, prefixed by feature: `helpXxx`, `dataXxx`, `settingsXxx`, `themeXxx`, `networkXxx`, `donateXxx`, `displayXxx`, `tableLayoutXxx`, `tableSelectXxx`, `orderHistoryXxx`, `withdrawalHistoryXxx`, `profileXxx`, `homeXxx`, `paymentXxx`, `paymentSuccessXxx`, `itemXxx`, `itemFormXxx`, `categoryXxx`

### ARB placeholder syntax (parameterized strings)
```json
"someKey": "Hello {name}",
"@someKey": {
  "placeholders": { "name": { "type": "String" } }
}
```

### After adding/editing ARB keys
Run `flutter gen-l10n` to regenerate the Dart class (separate from build_runner).

## Architecture

Feature-based clean architecture under `lib/`:

```
lib/
├── app/           # App setup: router, theme, global widgets, app-level cubits
├── data/          # Models (Freezed) and repositories
└── features/      # Feature modules (home, profile, items, auth, splash, onboarding)
    └── <feature>/
        ├── bloc/  # BLoC state management
        └── view/  # Pages and widgets
```

**State management**: BLoC (`flutter_bloc`). All business logic lives in BLoC/Cubit classes; views only dispatch events and render states.

**Navigation**: `go_router` — routes defined in `lib/app/app_router.dart`. Nested routes for the order flow and profile section (`/profile/*`).

**Data models**: Immutable classes using `freezed` + `json_serializable`. After changing a model, run `build_runner` to regenerate `.freezed.dart` and `.g.dart` files.

**Theme**: `ThemeCubit` in `lib/app/theme/` manages seed color and theme mode, persisted via `shared_preferences`.

**Currency**: `CurrencyCubit` in `lib/app/currency/` manages selected display currency, live exchange rates, and the Dynamic Pricing toggle, all persisted via `shared_preferences`. See details below.

**Locale**: `LocaleCubit` in `lib/app/locale/` manages the app language, persisted via `shared_preferences`. See details below.

**macOS-specific**: Window chrome is customized at startup in `main.dart` using `macos_window_utils` and `window_manager` (transparent titlebar, full-size content view). The `MacosTitleBar` widget in `lib/app/widgets/` provides the drag region.

## SharedPreferences Keys

All keys are centralized in `lib/app/constants/preference_keys.dart` (`PreferenceKeys` class). Always use constants from this class — never hardcode key strings.

Categories: Theme, Currency, Donation, Network, Wallet, Locale, Onboarding, Display, Table Layout.

## Key Domain Concepts

- **Product**: Has optional `additions` (variants/customizations with extra price). Both `Product` and `Addition` have an optional `kasPrice` field for a fixed KAS price override.
- **CartItem**: A product + selected additions + quantity. Has a `totalPrice` getter `(product.price + additions sum) * quantity`.
- **HomeBloc**: Central bloc managing the product catalog (loaded from SQLite), cart, and search. Products and categories are stored in `kasway.db` via `AppDatabase`.
- **Tablet detection**: `app.dart` detects screen width 600–1200px to adapt layout.

## Currency & Pricing System

All product prices are stored in IDR (Indonesian Rupiah). The currency system converts them at display time.

### Files
| File | Purpose |
|------|---------|
| `lib/app/currency/currency_state.dart` | `Currency` model + `CurrencyState` with `formatPrice()`, `idrToDisplay()`, `displayToKas()`, `displayToIdr()` |
| `lib/app/currency/currency_cubit.dart` | Fetches CoinGecko rates, 60s refresh timer, SharedPreferences persistence |
| `lib/app/widgets/price_text.dart` | `PriceText(idrPrice)` widget — use this everywhere a price is displayed |
| `lib/features/profile/view/currency_settings_page.dart` | Currency selection page (all 12 currencies incl. KAS) |

### How to display a price
Always use `PriceText(someDoubleInIdr)` instead of formatting directly with `NumberFormat`. It wraps a `BlocBuilder<CurrencyCubit, CurrencyState>` and calls `state.formatPrice(idrPrice)` automatically.

```dart
import 'package:kasway/app/widgets/price_text.dart';

PriceText(product.price, style: someTextStyle)
```

Never hardcode `NumberFormat.currency(locale: 'id_ID', ...)` for prices shown to the user.

### CurrencyState methods
```dart
// Format for display (returns a String)
state.formatPrice(idrPrice)
state.formatPrice(idrPrice, kasPrice: product.kasPrice)  // use fixed KAS price if set
state.formatPrice(idrPrice, kasSymbol: 'TKAS')           // testnet symbol

// Raw conversion helpers
state.idrToDisplay(idrPrice)           // → display-currency amount as double
state.displayToKas(displayAmount)      // → KAS as double? (null if rate unavailable)
state.displayToIdr(displayAmount)      // → IDR as double
```

### Conversion formula (KAS as bridge currency)
```
price_in_target = (price_in_idr / kaspa_idr_rate) × kaspa_target_rate
price_in_kas    =  price_in_idr / kaspa_idr_rate
price_in_idr    =  price_in_idr  (shown directly, no conversion)
```

### CoinGecko endpoint (no API key)
```
GET https://api.coingecko.com/api/v3/simple/price?ids=kaspa&vs_currencies=idr,usd,eur,gbp,jpy,sgd,myr,aud,cny,hkd,krw,thb,vnd,php,brl,mxn,cad,chf,nzd,zar,inr,aed,sar,ngn,pkr
Response: {"kaspa": {"idr": 1234.5, "usd": 0.075, ...}}
```
Rates are stored in `CurrencyState.exchangeRates` as `Map<String, double>` keyed by lowercase currency code.

### Supported currencies
KAS (default), IDR, USD, EUR, GBP, JPY, SGD, MYR, AUD, CNY, HKD, KRW, THB, VND, PHP, BRL, MXN, CAD, CHF, NZD, ZAR, INR, AED, SAR, NGN, PKR. Defined in `CurrencyState.allCurrencies`.

### Zero-decimal currencies
JPY, KRW, IDR, VND, PKR, NGN — no decimal places in price display and raw input. Handled in `_rawPrice()` in `item_form_page.dart` and `formatPrice()` in `currency_state.dart`.

### Settings integration
- **Currency Settings** tile → navigates to `/profile/currency`
- **Dynamic Pricing** toggle → calls `CurrencyCubit.setDynamicPricing(bool)` — when off, the 60s timer stops and prices stay at the last fetched rate

### No-network fallback
When `exchangeRates` is empty or `kasIdr <= 0`, `formatPrice` falls back to displaying IDR directly.

## Locale System

App language is managed by `LocaleCubit` / `LocaleState` in `lib/app/locale/`.

### Supported languages
English (default), Indonesian, Malay, Chinese (Simplified), Japanese, Korean.

### Files
| File | Purpose |
|------|---------|
| `lib/app/locale/locale_state.dart` | `AppLanguage` model + `LocaleState` with `supportedLanguages` list |
| `lib/app/locale/locale_cubit.dart` | Loads/persists selected language via `PreferenceKeys.appLanguageCode` |
| `lib/app/widgets/language_picker_sheet.dart` | Bottom sheet for language selection, used in Settings |

Language is configurable from `/profile/settings`.

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
- Add/edit items: pushed imperatively via `Navigator.of(context).push(MaterialPageRoute(...))`

### Optimistic Updates
All 6 catalog events (`HomeCatalogProduct{Added,Updated,Deleted}`, `HomeCategory{Added,Renamed,Deleted}`) follow the pattern:
1. Emit new state immediately (UI updates instantly)
2. `await _productRepository.persistXxx()`
3. On error: `emit(previous)` — silent rollback

### Schema (kasway.db, version 14)
```sql
categories(name TEXT PK, sort_order INTEGER)
products(id TEXT PK, name TEXT, price REAL, description TEXT,
         category_name TEXT, created_at INTEGER, kas_price REAL)   -- kas_price added v11
additions(id TEXT PK, product_id TEXT, name TEXT, price REAL,
          kas_price REAL)                                           -- kas_price added v11
orders(id TEXT PK, total_idr REAL, kas_amount REAL, kas_idr_rate REAL,
       tx_id TEXT, network TEXT, table_label TEXT,
       created_at INTEGER)
       -- kas_amount/kas_idr_rate added v7; tx_id v8; network v10; table_label v12
order_items(id TEXT PK, order_id TEXT, product_name TEXT, unit_price REAL,
            quantity INTEGER, additions TEXT)    -- added v7; additions = JSON array
withdrawals(tx_id TEXT PK, to_address TEXT, amount_kas REAL, amount_idr REAL,
            kas_idr_rate REAL, ref_fiat_code TEXT, ref_fiat_amount REAL,
            network TEXT, created_at INTEGER)
            -- added v5; rate columns v6; network v10
donations(tx_id TEXT PK, amount_kas REAL, is_auto INTEGER,
          network TEXT, created_at INTEGER)     -- added v9; network v10
table_items(id TEXT PK, label TEXT, seats INTEGER DEFAULT 4,
            x REAL, y REAL, rotation REAL, is_occupied INTEGER DEFAULT 0,
            is_served INTEGER DEFAULT 0, group_id TEXT)
            -- added v12; group_id v13; is_served v14
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
bloc.add(HomeOrderCompleted(
  totalIdr: 25000.0,
  cartItems: cartItems,
  kasAmount: 42.5,
  kasIdrRate: 588.0,
));
```

## Orders System

Completed orders are persisted in SQLite. Line items and KAS snapshot data are stored per-order. History is viewable at `/profile/orders` with date grouping and expandable cards.

### Files
| File | Purpose |
|------|---------|
| `lib/data/models/order.dart` | Freezed `Order` model (id, totalIdr, kasAmount, kasIdrRate, createdAt, items) |
| `lib/data/models/order_item.dart` | Freezed `OrderItem` + `OrderItemAddition` models |
| `lib/data/repositories/order_repository.dart` | `createOrder(...)` (transactional) + `getTodayRevenue()` + `getOrders()` (LEFT JOIN) |
| `lib/features/profile/view/order_history_page.dart` | Date-grouped list with expandable order cards showing line items |

### createOrder signature
```dart
await orderRepository.createOrder(
  totalIdr: 25000.0,
  kasAmount: 42.5,
  kasIdrRate: 588.0,
  cartItems: cartItems,
);
```
Inserts into `orders` + all `order_items` in a single DB transaction.

### Revenue query
`getTodayRevenue()` sums `total_idr` for rows with `created_at >= midnight today` (millisecondsSinceEpoch). Returns 0.0 when no orders.

### When an order is completed
`HomeOrderCompleted` is dispatched in `kaspa_confirmation_page.dart`'s `_onConfirmed()` before `HomeCartCleared`. `kasAmount` and `kasIdrRate` are read from `CurrencyCubit` at confirmation time. The handler is fire-and-forget (no state emitted).

### getOrders — LEFT JOIN pattern
Fetches orders with items in one SQL query (`LEFT JOIN order_items`), groups rows by `order_id` in Dart, returns `List<Order>` with `items` list populated. Orders with no items (pre-migration) return `items: []` and show "No item details recorded" in the UI.

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

### Transaction signing
`sendTransaction` signs each input with BIP340 Schnorr (pure Dart, via `kaspa_signing.dart`). Signing is correct and transactions relay on both mainnet and testnet-10.

### Fee / UTXO selection algorithm
Mirrors `rusty-kaspa wallet/core/src/tx/generator/generator.rs calculate_mass()`:
1. **Greedy UTXO selection** until `total >= amount + compute_mass(N, 2)`
2. **Converge fee** (≤ 5 iterations): `changeEstimate = total_input − amount` (before fees, same as rusty-kaspa), then call `_massDisposition` to decide storage mass + absorb flag
3. **Absorb-change logic**: if `C/changeEstimate − C/amount − input_deduction` > `changeEstimate` → drop change output, excess goes to miner fees
4. **Dust threshold**: 600 sompi (from `is_transaction_output_dust` in mass.rs); absorbed silently
5. **Storage mass formula** (wallet arithmetic-mean approximation): `max(0, Σ(C/out_i) − N²×C/total_input)` — conservative vs. consensus harmonic-sum but ensures fees never too low
6. `total_mass = max(compute_mass, storage_mass)`, fee = total_mass sompi

## Splash Screen + WalletCubit (App-Level Preloading)

### Routing flow
```
App start → /splash
  ├─ HomeBloc loading + WalletCubit deriving + CurrencyCubit fetching rates...
  └─ all ready (or 3s rate timeout) → /auth (not onboarded) or / (onboarded)
```

### WalletCubit (`lib/app/wallet/`)
App-level singleton provided in `app.dart` above `MaterialApp.router`. Owns:
- `mnemonic` — read once from SharedPreferences at startup
- `address` — derived via `KaspaWalletService().deriveAddress()` in `Future.microtask`
- `balanceKas` — fetched via wRPC `getUtxosByAddresses` (10s timeout), background
- `addressReady` — `true` once derivation completes (or confirmed no wallet)

Subscribes to `NetworkCubit.stream`; on network change re-derives address and re-fetches balance.
Call `walletCubit.refreshBalance()` after a withdrawal or when the cart is cleared.

### SplashPage (`lib/features/splash/view/splash_page.dart`)
Waits for: `HomeBloc.status != loading/initial` AND `WalletCubit.addressReady` AND (exchange rates loaded OR 3s timeout OR dynamic pricing off). Then navigates via `context.go(done ? '/' : '/auth')`.

### Profile Wallet Card
`_WalletCard` is a `StatelessWidget` that reads from `WalletCubit` via `BlocBuilder`. No local address/balance loading logic — all data is available instantly post-splash. `BlocListener<HomeBloc>` calls `walletCubit.refreshBalance()` when cart is cleared.

### Kaspa Payment QR Page
Reads `_merchantAddress = context.read<WalletCubit>().state.address` in `didChangeDependencies` (no async needed). `BlocListener<WalletCubit>` restarts wRPC on address change (network switch). If address is empty, shows error. If `kasIdr <= 0` (rare post-splash), shows `-- KAS` with no QR.

`_WithdrawSheet` collects destination address + KAS amount, builds a `payload_note` (`kasway:withdraw:<ISO8601>:<amount>kas:ack:<addr_proof>`), and calls `KaspaWalletService().sendTransaction(...)`. On success, records the withdrawal via `WithdrawalRepository` before closing.

Both `OrderRepository` and `WithdrawalRepository` must be provided in the widget tree (provided at app level via `MultiRepositoryProvider`).

## Kaspa Payment QR Code Flow

Cart → "Proceed to Payment" → `/kaspa-payment` (QR page, customer scans and pays)

Cart items are captured in local state on mount via `didChangeDependencies`. Address is read instantly from `WalletCubit` (no spinner).

### File
`lib/features/home/view/kaspa_payment_page.dart` — `StatefulWidget`. Reads address from `WalletCubit.state.address`, builds a QR code using `qr_flutter` (`QrImageView`).

### QR URI format
```
kaspa:<address>?amount=<kas_amount>&p=<base64url_encrypted_blob>
```
- `kas_amount` = `totalIdr / kasIdrRate` (8 decimal places, trailing zeros stripped)
- `p` = `KaswayPayloadCodec.encode(items, totalIdr)` — AES-256-GCM encrypted, zlib-compressed binary payload (see below)
- Old format used `payload=<base64url_json>` (verbose, ~62% larger); `p=` signals the new format to the wallet SDK

### KaswayPayloadCodec (`lib/data/services/payload_codec.dart`)
Compact encrypted payload for order data in QR codes. ~62% smaller than the old base64(JSON) format.

**Blob structure** (after base64url decoding):
```
[12 bytes: random AES-GCM nonce]
[N bytes + 16 bytes: AES-256-GCM ciphertext + tag]   ← zlib-compressed binary
```

**Binary payload** (before compress + encrypt):
```
0x01          version byte
uint8         item count
per item:
  uint8       UTF-8 name length
  N bytes     name (UTF-8)
  uint16 BE   quantity
  uint32 BE   unit price IDR (whole)
  uint8       addition count
  per addition:
    uint8     UTF-8 name length
    N bytes   name (UTF-8)
    uint32 BE addition price IDR (whole)
uint32 BE     total IDR (whole)
```

**Key**: hardcoded 32-byte AES-256 key in `_key` constant. The wallet SDK ships an identical copy to decrypt. Version byte allows future key rotation.

### Package
`qr_flutter: ^4.1.0` added to `pubspec.yaml`.

### States handled
- Loading address → `CircularProgressIndicator`
- Address error → error text
- No exchange rates yet → spinner + "Fetching exchange rates…"
- Ready → KAS amount (above QR) + conditional fiat secondary + QR code + order summary with additions

### Payment confirmation
Not yet implemented. The page is display-only — the customer scans the QR and pays, but the app does not yet auto-detect or manually confirm the payment.

## Withdrawals System

Completed withdrawals are persisted in SQLite. History is accessible from the wallet card.

### Files
| File | Purpose |
|------|---------|
| `lib/data/models/withdrawal.dart` | Freezed `Withdrawal` model (txId, toAddress, amountKas, amountIdr, kasIdrRate, createdAt) |
| `lib/data/repositories/withdrawal_repository.dart` | `recordWithdrawal(...)` + `getWithdrawals()` + `getAllForExport()` |
| `lib/features/profile/view/withdrawal_history_page.dart` | List of past withdrawals with fiat equivalent + copy-TX-ID action |

### Route
`/profile/withdrawals` → `WithdrawalHistoryPage`

### Export
`DataService` exports both `kasway_data.csv` (catalog) and `kasway_withdrawals.csv` (withdrawals) when the user taps Export in Data Transfer.

Withdrawal CSV columns: `tx_id, to_address, amount_kas, amount_idr, kas_idr_rate, created_at`

Note: The `withdrawals` DB table also stores `ref_fiat_code`, `ref_fiat_amount`, and `network` columns (added in migrations v6/v10), but these are not currently read into the `Withdrawal` Dart model or exported.

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

## NodeStatusCubit

Real-time DAA score polling lives in `lib/app/network/node_status_cubit.dart` + `node_status_state.dart`. It is an app-level cubit (not page-scoped).

- Subscribes to `NetworkCubit.stream` and auto-reconnects when `activeUrl` changes
- Uses a generation counter (`_generation`) to self-terminate stale `_connect()` loops on reconnect
- Polls `getBlockDagInfo` every 1s; parses `params.virtualDaaScore`
- State: `connected` (bool), `daaScore` (String), `lastUpdated` (time string), `error` (String)

Node status is displayed inside `/profile/network` → `NetworkPage` (combined network settings + live node status). There is no separate `/profile/node-status` route.

## Network Switching (Mainnet / Testnet-10)

Runtime network switching without app restart. `NetworkCubit` manages the active network and node URLs.

### Files
| File | Purpose |
|------|---------|
| `lib/app/network/network_state.dart` | `KaspaNetwork` enum + `NetworkState` with `activeUrl`, `networkLabel`, `kasSymbol` getters |
| `lib/app/network/network_cubit.dart` | Persists selected network + custom URLs via SharedPreferences |
| `lib/app/network/node_status_cubit.dart` | App-level DAA score polling; auto-reconnects on network switch |
| `lib/features/profile/view/network_page.dart` | Combined network settings + live node status display |

### SharedPreferences keys (via `PreferenceKeys`)
`kaspaNetwork`, `kaspaMainnetUrl`, `kaspaTestnet10Url`

### Default URLs
- Mainnet: `wss://rose.kaspa.green/kaspa/mainnet/wrpc/json`
- Testnet-10: `wss://electron-10.kaspa.stream/kaspa/testnet-10/wrpc/json`

### KAS symbol
`NetworkState.kasSymbol` returns `'KAS'` on mainnet and `'TKAS'` on testnet-10.
`formatPrice()` in `CurrencyState` accepts an optional `kasSymbol` named parameter (defaults to `'KAS'`).
`PriceText` watches both `CurrencyCubit` and `NetworkCubit` and passes the symbol automatically.

### Route
`/profile/network` → `NetworkPage` (settings + node status combined)

## Kaspa Payment Detection (JSON wRPC polling)

Payment confirmation on the Kaspa payment QR page via periodic `getUtxosByAddresses` polling over the existing JSON wRPC WebSocket (same URL as `NodeStatusCubit`). The Borsh subscription approach was attempted but public nodes return error code 3 (not supported) for `NotifyUtxosChanged`.

### Files
| File | Purpose |
|------|---------|
| `lib/data/services/kaspa_wrpc_borsh_codec.dart` | Encode/decode Kaspa wRPC Borsh frames (kept for future use, not used in payment page) |
| `lib/features/home/view/kaspa_payment_page.dart` | QR page + JSON wRPC polling + payment detection |

### `NetworkState.activeBorshUrl`
Converts the active JSON URL to Borsh by replacing `/json` with `/borsh` (kept on `NetworkState` for future use):
```
wss://rose.kaspa.green/kaspa/mainnet/wrpc/json  →  wss://rose.kaspa.green/kaspa/mainnet/wrpc/borsh
```

### Payment detection flow
1. After address is derived, `_connectWrpc()` opens a JSON WebSocket to `activeUrl`
2. Immediately sends `getUtxosByAddresses` request; first response sets the **baseline** set of known outpoints (to avoid false positives from pre-existing UTXOs)
3. Every 1 second, polls `getUtxosByAddresses` again; checks for any NEW outpoint (not in baseline) with `amount >= expectedSompi * 0.99` (1% tolerance for rate drift)
4. On match: dispatches `HomeOrderCompleted(totalIdr)` + `HomeCartCleared()`, shows green overlay, navigates to `/payment-success` after 2 seconds
   - `_requiredConfirmations = 10` → ~1 second at Kaspa's 10 BPS (DAA score increments ~10/sec)
5. Reconnects on close/error with 3-second delay; network switch clears baseline and re-derives address

### JSON wRPC request/response
```
Request:  {"id": N, "method": "getUtxosByAddresses", "params": {"addresses": ["kaspa:q..."]}}
Response: {"id": N, "method": "getUtxosByAddresses",
           "params": {"entries": [{"address": "...", "outpoint": {"transactionId": "...", "index": 0},
                                   "utxoEntry": {"amount": "100000000", ...}}]}}
```
Amount in entries is a **string** representation of sompi (u64).

## Donation System

Merchants can donate KAS to the developer, either manually (one-time) or automatically after each confirmed payment.

### Files
| File | Purpose |
|------|---------|
| `lib/app/donation/donation_state.dart` | `DonationState` + `DonationMode` enum + `DonationConstants.address` (hardcoded dev address) |
| `lib/app/donation/donation_cubit.dart` | Persists settings via SharedPreferences; exposes `setAutoEnabled`, `setMode`, `setPercentage`, `setFixedAmount` |
| `lib/features/profile/view/donation_page.dart` | Two-section page: one-time donation sheet + auto-donate settings |

### Route
`/profile/donate` → `DonationPage`

### Auto-donation
`_tryAutoDonate()` is called fire-and-forget inside `KaspaConfirmationPage._onConfirmed()`, before dispatching `HomeOrderCompleted`. Guards: auto disabled, hrp != 'kaspa' (testnet skip), empty mnemonic, kasIdr <= 0.

### SharedPreferences keys (via `PreferenceKeys`)
`donationAutoEnabled`, `donationMode` (`"percentage"` / `"fixedAmount"`), `donationPercentage`, `donationFixedKas`

### Modes
- **Percentage**: `totalKas * (percentageValue / 100)` donated per transaction
- **Fixed**: `fixedKasAmount` KAS donated per transaction (regardless of cart total)

### Payload format
`kasway:donate:<ISO8601>:<amount>kas` (one-time) or `kasway:donate:<ISO8601>` (auto)

## External Display Integration

Merchants with a tablet connected to an external monitor (USB-C/HDMI or wireless) can mirror the Kaspa payment QR screen so customers can see the amount and QR code without looking at the cashier's device. Feature is Android/iOS only; all `DisplayManager` calls are platform-guarded.

### Package
`presentation_displays: ^1.0.0` — `DisplayManager` (primary) + `SecondaryDisplay` widget (secondary engine).

### Architecture
```
KaspaPaymentPage (primary)
  └─ calls DisplayCubit.transferData(Map) via addPostFrameCallback

DisplayCubit (app-level, prefs-injected)
  └─ wraps DisplayManager; guarded: Android/iOS only

secondaryDisplayMain() — separate Flutter engine (Android/iOS native)
  └─ ValueNotifier<Map?> _secondaryDisplayData  ← updated via SecondaryDisplay.callback
  └─ _SecondaryPaymentScreen(data)             ← renders QR + amounts from the Map
```

The secondary engine has no BLoC access. All display data is serialised into a `Map<String, dynamic>` and sent via `DisplayManager.transferDataToPresentation()`.

### Files
| File | Purpose |
|------|---------|
| `lib/app/display/display_state.dart` | `DisplayStatus` enum + `DisplayState` plain-Dart class with `copyWith` |
| `lib/app/display/display_cubit.dart` | Cubit wrapping `DisplayManager`; platform-guarded |
| `lib/features/profile/view/display_settings_page.dart` | Settings UI: toggle + scan + connect/disconnect |
| `lib/main.dart` | `secondaryDisplayMain()` entry point + `_SecondaryPaymentScreen` widget |

### Route
`/profile/display` → `DisplaySettingsPage`

### SharedPreferences keys (via `PreferenceKeys`)
`displayEnabled` (bool), `displayLastConnectedId` (int)

### Data payload format (Map sent to secondary engine)
```dart
{
  'qr':    String,           // full kaspa:... URI string for QrImageView
  'kas':   String,           // e.g. "KAS 42.5"
  'idr':   String,           // pre-formatted fiat secondary amount (empty if crypto mode)
  'items': List<Map> [       // order line items
    {'name': String, 'qty': int, 'additions': List<String>}
  ]
}
```
Pass `null` to reset the secondary display to the idle "Waiting for payment…" screen.

### Platform guard pattern
```dart
bool get _isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
// Applied in: DisplayCubit methods, KaspaPaymentPage._transferToDisplay/_clearDisplay
```

### Auto-reconnect
On `DisplayCubit` load, if `display_enabled == true` and `display_last_connected_id` is set, a 2-second `Timer` triggers `_tryAutoReconnect()`: scans for displays, then calls `connect()` if the last-known display is still visible.

## Table Layout System

Optional floor-plan feature for restaurants and cafés. When enabled, the cashier must select a table before payment. Empty tables show in primary color; occupied ones are greyed out.

### Files
| File | Purpose |
|------|---------|
| `lib/data/models/table_item.dart` | Freezed `TableItem` model (id, label, seats 1–8, x, y, rotation, isOccupied, isServed, groupId?) |
| `lib/data/repositories/table_repository.dart` | SQLite CRUD for `table_items`; `saveLayout` does full-replace in a single transaction |
| `lib/app/table/table_state.dart` | Plain-class `TableState` (enabled, tables, selectedTableId) with `selectedTable` getter |
| `lib/app/table/table_cubit.dart` | App-level cubit: toggle, saveLayout, selectTable, markOccupied, markServed, freeTable |
| `lib/features/home/view/widgets/table_canvas.dart` | Shared canvas used in editor (editMode=true) and selection page (editMode=false) |
| `lib/features/profile/view/table_layout_page.dart` | Canvas editor: drag/rotate tables, label editing, bottom sheet palette |
| `lib/features/home/view/table_selection_page.dart` | Pre-payment table picker: canvas + chip list |

### Routes
- `/profile/table-layout` → `TableLayoutPage` (nested under `/profile`)
- `/table-selection` → `TableSelectionPage` (top-level, pushed before `/kaspa-payment`)

### Table states
Each table has three visual states managed entirely in-memory (not persisted across restarts):
- **Available** — `isOccupied: false` → primary color. Tapping selects it.
- **Occupied / Waiting** — `isOccupied: true, isServed: false` → amber. Set by `selectTable(id)`.
- **Served** — `isOccupied: true, isServed: true` → green. Set by `markServed(id)` from the long-press menu in `TableSelectionPage`.

Long-pressing an occupied table on `TableSelectionPage` (canvas or chip) shows a bottom sheet with:
- "Mark as Served" (only when not yet served) → `tableCubit.markServed(id)`
- "Free Table" → confirmation dialog → `tableCubit.freeTable(id)`

After payment confirmation (`KaspaConfirmationPage._onConfirmed`), `tableCubit.clearSelection()` is called so the table remains occupied (customer still seated) but is deselected for the next order. The table is freed only when the cashier explicitly taps "Free Table" from the long-press menu.

### Canvas visual details
- Seat circles are drawn around each table body using `_TableWithSeatsPainter` (a `CustomPainter` in `table_canvas.dart`). Constants: `_seatR = 6`, `_seatGap = 3.5`, `_seatPad = _seatR + _seatGap`.
- The label/seat-count text is counter-rotated (`Transform.rotate(angle: -rotation)`) so it stays horizontal regardless of table rotation.
- `_PositionedTable` is offset by `-_seatPad` on both axes to keep the logical `(x, y)` at the table body top-left.

### Payment flow intercept
`OrderSideView._proceedToPayment()` checks `TableCubit.state.enabled` and `selectedTableId`. If enabled and no table selected, pushes `/table-selection` first. After selection, pushes `/kaspa-payment`.

### Table freed after payment
In `KaspaConfirmationPage._onConfirmed()`, after `HomeOrderCompleted` and `HomeCartCleared`, calls `tableCubit.freeTable(selectedTableId)` to mark the table available again.

### SharedPreferences key (via `PreferenceKeys`)
`tableLayoutEnabled` (bool)

## Routes Reference

| Route | Widget | Notes |
|-------|--------|-------|
| `/splash` | `SplashPage` | App entry point |
| `/` | `HomePage` | Main POS screen |
| `/order-confirmation` | `OrderConfirmationPage` | |
| `/kaspa-payment` | `KaspaPaymentPage` | QR + wRPC polling |
| `/payment-success` | `PaymentSuccessfulPage` | |
| `/table-selection` | `TableSelectionPage` | Only when table layout enabled |
| `/profile` | `ProfilePage` | |
| `/profile/orders` | `OrderHistoryPage` | |
| `/profile/settings` | `SettingsPage` | Language picker + other settings |
| `/profile/help` | `HelpSupportPage` | FAQ / expandable tiles |
| `/profile/theme` | `ThemeSettingsPage` | |
| `/profile/currency` | `CurrencySettingsPage` | |
| `/profile/items` | `ItemManagementPage` | |
| `/profile/data-transfer` | `DataTransferPage` | Import / Export CSV |
| `/profile/withdrawals` | `WithdrawalHistoryPage` | |
| `/profile/network` | `NetworkPage` | Network selector + live node status |
| `/profile/donate` | `DonationPage` | |
| `/profile/display` | `DisplaySettingsPage` | Android/iOS only |
| `/profile/table-layout` | `TableLayoutPage` | |
| `/auth` | `AuthPage` | Onboarding entry |
| `/auth/eula` | `EulaPage` | |
| `/auth/seed-phrase` | `SeedPhrasePage` | |
| `/auth/currency` | `OnboardingCurrencyPage` | |
| `/auth/login` | `LoginPage` | |
| `/onboarding` | `OnboardingPage` | |
