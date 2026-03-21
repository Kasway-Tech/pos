# Contributing to Kasway

Thank you for your interest in contributing. This document covers everything you need to know to get started.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Pull Request Process](#pull-request-process)
- [Commit Message Format](#commit-message-format)
- [Code Style](#code-style)
- [Trademark](#trademark)

---

## Code of Conduct

By participating in this project you agree to abide by the [Code of Conduct](CODE_OF_CONDUCT.md).

---

## Reporting Bugs

Before filing a bug report, search [existing issues](https://github.com/furatamasensei/pos/issues) to avoid duplicates.

When filing a new issue, include:

- **Device / platform** (e.g. macOS 14, Android 13, iPhone 15)
- **Flutter version** (`flutter --version`)
- **Steps to reproduce** — be specific; include screenshots or screen recordings if helpful
- **Expected behavior** vs **actual behavior**
- **Relevant logs** (run with `flutter run --verbose` and paste the relevant section)

---

## Suggesting Features

Open a [feature request issue](https://github.com/furatamasensei/pos/issues/new) and describe:

1. The problem you are trying to solve
2. The solution you have in mind
3. Any alternatives you considered

Features related to real-world merchant needs for Kaspa acceptance are prioritized.

---

## Development Setup

### Prerequisites

- Flutter ≥ 3.22 (`flutter doctor` should show no errors)
- Dart ≥ 3.4 (bundled with Flutter)
- An IDE with Flutter support (VS Code + Flutter extension, or Android Studio)

### Clone and run

```bash
git clone https://github.com/furatamasensei/pos.git
cd pos
flutter pub get
flutter run -d macos        # or -d android / -d ios
```

### Code generation

After editing any Freezed model (files in `lib/data/models/`):

```bash
dart run build_runner build --delete-conflicting-outputs
```

After editing any ARB translation file (`lib/l10n/app_*.arb`):

```bash
flutter gen-l10n
```

---

## Making Changes

1. **Fork** the repository and create a branch from `main`:

   ```bash
   git checkout -b feat/my-feature
   # or
   git checkout -b fix/my-bugfix
   ```

2. **Write code** following the conventions below.

3. **Add or update tests** for any new logic in `test/`.

4. **Run checks** before pushing:

   ```bash
   flutter analyze          # must show zero issues
   flutter test             # must pass
   ```

5. Push your branch and open a pull request against `main`.

---

## Pull Request Process

- Keep PRs focused — one feature or fix per PR. Large refactors should be discussed in an issue first.
- Fill out the PR template (title, summary, test plan).
- All CI checks must pass before a PR will be reviewed.
- A maintainer will review within a reasonable time. Be prepared to revise based on feedback.
- Once approved and all checks pass, a maintainer will merge.

---

## Commit Message Format

Use the [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>: <short summary>

[optional body]
```

**Types:**

| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructure with no behaviour change |
| `test` | Adding or fixing tests |
| `docs` | Documentation only |
| `chore` | Build scripts, dependencies, CI |

**Examples:**

```
feat: add THB currency support
fix: prevent duplicate order on rapid double-tap
refactor: extract WalletCard into separate widget
docs: update wRPC protocol notes in CLAUDE.md
```

Commits should be atomic — each commit should represent a single logical change and leave the codebase in a buildable, passing state.

---

## Code Style

- Follow the architecture described in [CLAUDE.md](CLAUDE.md) — feature-based clean architecture, BLoC for state management, go_router for navigation.
- All business logic goes in BLoC/Cubit classes; views only dispatch events and render state.
- Use `PriceText(idrPrice)` for all price display — never hardcode `NumberFormat.currency(...)`.
- All UI strings must use `context.l10n.*` — never hardcode English strings in widgets. Add new keys to **all six** ARB files (`app_en.arb`, `app_id.arb`, `app_ja.arb`, `app_ko.arb`, `app_ms.arb`, `app_zh.arb`).
- SVG assets must use inline presentation attributes — no `<style>` blocks (see CLAUDE.md).
- Do not call `context.read<T>()` inside `MaterialPageRoute.builder` — see the Imperative Navigation Rule in CLAUDE.md.
- `flutter analyze` must report **zero issues** (errors and warnings) before a PR is considered ready.

---

## Trademark

"Kasway" is a trademark of the project author. Contributions you submit are licensed under the Apache License 2.0, but this does not grant you the right to use the Kasway name or branding in any derived product or service. See [LICENSE](LICENSE) for details.
