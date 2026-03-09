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

**macOS-specific**: Window chrome is customized at startup in `main.dart` using `macos_window_utils` and `window_manager` (transparent titlebar, full-size content view). The `MacosTitleBar` widget in `lib/app/widgets/` provides the drag region.

## Key Domain Concepts

- **Product**: Has optional `additions` (variants/customizations with extra price).
- **CartItem**: A product + selected additions + quantity. Has a `totalPrice` getter `(product.price + additions sum) * quantity`.
- **HomeBloc**: Central bloc managing the product catalog (5 hardcoded categories), cart, and search. Products are currently seeded in-memory inside `ProductRepository`.
- **Tablet detection**: `app.dart` detects screen width 600–1200px to adapt layout.
