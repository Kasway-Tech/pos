// display_cubit_test.dart
//
// Tests run on macOS where Platform.isAndroid / Platform.isIOS == false, so
// _isSupported is always false in the test environment. This is intentional:
//
//  - We test that ALL platform-guarded paths (scanDisplays, connect, disconnect,
//    transferData) are true no-ops on unsupported platforms.
//  - We test all SharedPreferences-driven paths (_load, setEnabled) which are
//    not guarded and run on every platform.
//  - We verify guard behaviour (no state change, no exception) for every method
//    that calls DisplayManager.
//
// Because _isSupported==false, the 2-second auto-reconnect timer in _load is
// never scheduled, avoiding FakeAsync / timer-cleanup complexity.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/constants/preference_keys.dart';
import 'package:kasway/app/display/display_cubit.dart';
import 'package:kasway/app/display/display_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DisplayCubit', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    DisplayCubit buildCubit() => DisplayCubit(prefs: prefs);

    // ── _load — default prefs ─────────────────────────────────────────────────

    group('_load — no persisted values', () {
      test('initial state has enabled=false when prefs are empty', () {
        final cubit = buildCubit();
        expect(cubit.state.enabled, isFalse);
        cubit.close();
      });

      test('initial state has status=idle when prefs are empty', () {
        final cubit = buildCubit();
        expect(cubit.state.status, DisplayStatus.idle);
        cubit.close();
      });

      test('initial state has lastKnownDisplayId=null when prefs are empty', () {
        final cubit = buildCubit();
        expect(cubit.state.lastKnownDisplayId, isNull);
        cubit.close();
      });

      test('initial state has empty availableDisplays when prefs are empty', () {
        final cubit = buildCubit();
        expect(cubit.state.availableDisplays, isEmpty);
        cubit.close();
      });

      test('initial state has isConnected=false when prefs are empty', () {
        final cubit = buildCubit();
        expect(cubit.state.isConnected, isFalse);
        cubit.close();
      });
    });

    // ── _load — persisted values restored ────────────────────────────────────

    group('_load — persisted values restored', () {
      test('restores enabled=true from prefs', () async {
        SharedPreferences.setMockInitialValues({
          PreferenceKeys.displayEnabled: true,
        });
        prefs = await SharedPreferences.getInstance();
        final cubit = buildCubit();
        expect(cubit.state.enabled, isTrue);
        await cubit.close();
      });

      test('restores enabled=false from prefs (explicit false)', () async {
        SharedPreferences.setMockInitialValues({
          PreferenceKeys.displayEnabled: false,
        });
        prefs = await SharedPreferences.getInstance();
        final cubit = buildCubit();
        expect(cubit.state.enabled, isFalse);
        await cubit.close();
      });

      test('restores lastKnownDisplayId from prefs', () async {
        SharedPreferences.setMockInitialValues({
          PreferenceKeys.displayLastConnectedId: 2,
        });
        prefs = await SharedPreferences.getInstance();
        final cubit = buildCubit();
        expect(cubit.state.lastKnownDisplayId, 2);
        await cubit.close();
      });

      test('restores both enabled and lastKnownDisplayId from prefs', () async {
        SharedPreferences.setMockInitialValues({
          PreferenceKeys.displayEnabled: true,
          PreferenceKeys.displayLastConnectedId: 5,
        });
        prefs = await SharedPreferences.getInstance();
        final cubit = buildCubit();
        expect(cubit.state.enabled, isTrue);
        expect(cubit.state.lastKnownDisplayId, 5);
        await cubit.close();
      });

      // On the test platform (macOS), _isSupported is false, so the
      // auto-reconnect timer is never scheduled even when enabled=true and
      // lastKnownDisplayId is set. Status should remain idle (not connected).
      test('status remains idle after load even with enabled=true and lastKnownDisplayId set (unsupported platform)', () async {
        SharedPreferences.setMockInitialValues({
          PreferenceKeys.displayEnabled: true,
          PreferenceKeys.displayLastConnectedId: 3,
        });
        prefs = await SharedPreferences.getInstance();
        final cubit = buildCubit();
        // Give ample time to confirm no timer fires on this platform.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(cubit.state.status, DisplayStatus.idle);
        expect(cubit.state.connectedDisplayId, isNull);
        await cubit.close();
      });
    });

    // ── setEnabled ────────────────────────────────────────────────────────────

    group('setEnabled', () {
      blocTest<DisplayCubit, DisplayState>(
        'setEnabled(true) emits state with enabled=true',
        build: buildCubit,
        act: (cubit) => cubit.setEnabled(true),
        expect: () => [
          isA<DisplayState>().having((s) => s.enabled, 'enabled', true),
        ],
      );

      blocTest<DisplayCubit, DisplayState>(
        'setEnabled(true) persists display_enabled=true to prefs',
        build: buildCubit,
        act: (cubit) => cubit.setEnabled(true),
        verify: (_) {
          expect(prefs.getBool(PreferenceKeys.displayEnabled), isTrue);
        },
      );

      blocTest<DisplayCubit, DisplayState>(
        'setEnabled(false) emits state with enabled=false',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.displayEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
        },
        build: buildCubit,
        act: (cubit) => cubit.setEnabled(false),
        expect: () => [
          isA<DisplayState>().having((s) => s.enabled, 'enabled', false),
        ],
      );

      blocTest<DisplayCubit, DisplayState>(
        'setEnabled(false) persists display_enabled=false to prefs',
        build: buildCubit,
        act: (cubit) => cubit.setEnabled(false),
        verify: (_) {
          expect(prefs.getBool(PreferenceKeys.displayEnabled), isFalse);
        },
      );

      // When the platform is unsupported (macOS), disconnect() is a no-op, so
      // setEnabled(false) emits a single enabled=false state with no additional
      // disconnect state transition.
      blocTest<DisplayCubit, DisplayState>(
        'setEnabled(false) does not throw and emits enabled=false on unsupported platform',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.displayEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
        },
        build: buildCubit,
        act: (cubit) => cubit.setEnabled(false),
        expect: () => [
          isA<DisplayState>().having((s) => s.enabled, 'enabled', false),
        ],
      );

      blocTest<DisplayCubit, DisplayState>(
        'calling setEnabled(true) then setEnabled(false) ends with enabled=false',
        build: buildCubit,
        act: (cubit) async {
          await cubit.setEnabled(true);
          await cubit.setEnabled(false);
        },
        verify: (cubit) {
          expect(cubit.state.enabled, isFalse);
        },
      );
    });

    // ── scanDisplays — unsupported platform guard ─────────────────────────────

    group('scanDisplays — unsupported platform (macOS test env)', () {
      blocTest<DisplayCubit, DisplayState>(
        'emits no states and does not throw on unsupported platform',
        build: buildCubit,
        act: (cubit) => cubit.scanDisplays(),
        expect: () => <DisplayState>[],
      );

      blocTest<DisplayCubit, DisplayState>(
        'status remains idle after scanDisplays on unsupported platform',
        build: buildCubit,
        act: (cubit) => cubit.scanDisplays(),
        verify: (cubit) {
          expect(cubit.state.status, DisplayStatus.idle);
          expect(cubit.state.availableDisplays, isEmpty);
        },
      );

      test('scanDisplays completes without throwing on unsupported platform', () async {
        final cubit = buildCubit();
        await expectLater(cubit.scanDisplays(), completes);
        await cubit.close();
      });
    });

    // ── connect — unsupported platform guard ──────────────────────────────────

    group('connect — unsupported platform (macOS test env)', () {
      blocTest<DisplayCubit, DisplayState>(
        'emits no states and does not throw on unsupported platform',
        build: buildCubit,
        act: (cubit) => cubit.connect(1, 'HDMI Display'),
        expect: () => <DisplayState>[],
      );

      blocTest<DisplayCubit, DisplayState>(
        'state remains unchanged after connect on unsupported platform',
        build: buildCubit,
        act: (cubit) => cubit.connect(1, 'HDMI Display'),
        verify: (cubit) {
          expect(cubit.state.status, DisplayStatus.idle);
          expect(cubit.state.connectedDisplayId, isNull);
          expect(cubit.state.connectedDisplayName, isNull);
          expect(cubit.state.isConnected, isFalse);
        },
      );

      blocTest<DisplayCubit, DisplayState>(
        'connect does not persist lastKnownDisplayId on unsupported platform',
        build: buildCubit,
        act: (cubit) => cubit.connect(1, 'HDMI Display'),
        verify: (_) {
          expect(prefs.getInt(PreferenceKeys.displayLastConnectedId), isNull);
        },
      );

      test('connect completes without throwing on unsupported platform', () async {
        final cubit = buildCubit();
        await expectLater(cubit.connect(2, 'External Monitor'), completes);
        await cubit.close();
      });
    });

    // ── disconnect — unsupported platform guard ───────────────────────────────

    group('disconnect — unsupported platform (macOS test env)', () {
      blocTest<DisplayCubit, DisplayState>(
        'emits no states and does not throw on unsupported platform',
        build: buildCubit,
        act: (cubit) => cubit.disconnect(),
        expect: () => <DisplayState>[],
      );

      blocTest<DisplayCubit, DisplayState>(
        'status remains idle after disconnect when nothing is connected',
        build: buildCubit,
        act: (cubit) => cubit.disconnect(),
        verify: (cubit) {
          expect(cubit.state.status, DisplayStatus.idle);
          expect(cubit.state.connectedDisplayId, isNull);
        },
      );

      test('disconnect completes without throwing on unsupported platform', () async {
        final cubit = buildCubit();
        await expectLater(cubit.disconnect(), completes);
        await cubit.close();
      });
    });

    // ── reconnect ─────────────────────────────────────────────────────────────

    group('reconnect', () {
      blocTest<DisplayCubit, DisplayState>(
        'emits no states when lastKnownDisplayId is null',
        build: buildCubit,
        act: (cubit) => cubit.reconnect(),
        expect: () => <DisplayState>[],
      );

      blocTest<DisplayCubit, DisplayState>(
        'state remains idle after reconnect when lastKnownDisplayId is null',
        build: buildCubit,
        act: (cubit) => cubit.reconnect(),
        verify: (cubit) {
          expect(cubit.state.status, DisplayStatus.idle);
          expect(cubit.state.isConnected, isFalse);
        },
      );

      // When lastKnownDisplayId is set but the platform is unsupported,
      // reconnect() delegates to connect() which is a no-op → no state change.
      blocTest<DisplayCubit, DisplayState>(
        'no state change on unsupported platform even when lastKnownDisplayId is set',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.displayLastConnectedId: 2,
          });
          prefs = await SharedPreferences.getInstance();
        },
        build: buildCubit,
        act: (cubit) => cubit.reconnect(),
        verify: (cubit) {
          expect(cubit.state.status, DisplayStatus.idle);
          expect(cubit.state.connectedDisplayId, isNull);
          // lastKnownDisplayId is restored from prefs and preserved
          expect(cubit.state.lastKnownDisplayId, 2);
        },
      );

      test('reconnect completes without throwing when lastKnownDisplayId is null', () async {
        final cubit = buildCubit();
        await expectLater(cubit.reconnect(), completes);
        await cubit.close();
      });

      test('reconnect completes without throwing on unsupported platform with id set', () async {
        SharedPreferences.setMockInitialValues({
          PreferenceKeys.displayLastConnectedId: 3,
        });
        prefs = await SharedPreferences.getInstance();
        final cubit = buildCubit();
        await expectLater(cubit.reconnect(), completes);
        await cubit.close();
      });
    });

    // ── transferData — guards ─────────────────────────────────────────────────

    group('transferData', () {
      blocTest<DisplayCubit, DisplayState>(
        'no-op and no exception on unsupported platform when not connected',
        build: buildCubit,
        act: (cubit) => cubit.transferData({'key': 'value'}),
        expect: () => <DisplayState>[],
      );

      blocTest<DisplayCubit, DisplayState>(
        'no-op when passing null payload on unsupported platform',
        build: buildCubit,
        act: (cubit) => cubit.transferData(null),
        expect: () => <DisplayState>[],
      );

      blocTest<DisplayCubit, DisplayState>(
        'no-op when passing empty map on unsupported platform',
        build: buildCubit,
        act: (cubit) => cubit.transferData({}),
        expect: () => <DisplayState>[],
      );

      blocTest<DisplayCubit, DisplayState>(
        'state does not change after transferData when not connected',
        build: buildCubit,
        act: (cubit) => cubit.transferData({'items': [], 'total': 0}),
        verify: (cubit) {
          expect(cubit.state.isConnected, isFalse);
          expect(cubit.state.status, DisplayStatus.idle);
        },
      );

      // Verify transferData completes without error — the guard
      // !_isSupported || !state.isConnected returns early before any
      // DisplayManager call, so no MissingPluginException is thrown.
      test('transferData completes without throwing on unsupported platform', () async {
        final cubit = buildCubit();
        await expectLater(
          cubit.transferData({'kasAmount': 42.5, 'total': 25000.0}),
          completes,
        );
        await cubit.close();
      });

      test('transferData with null completes without throwing', () async {
        final cubit = buildCubit();
        await expectLater(cubit.transferData(null), completes);
        await cubit.close();
      });
    });

    // ── setEnabled + disconnect interaction ───────────────────────────────────

    group('setEnabled(false) + disconnect interaction', () {
      // On unsupported platforms, disconnect() is a no-op. Setting
      // enabled=false when NOT connected emits only the enabled=false state.
      blocTest<DisplayCubit, DisplayState>(
        'setEnabled(false) when not connected emits one state with enabled=false and idle status',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            PreferenceKeys.displayEnabled: true,
          });
          prefs = await SharedPreferences.getInstance();
        },
        build: buildCubit,
        act: (cubit) => cubit.setEnabled(false),
        expect: () => [
          isA<DisplayState>()
              .having((s) => s.enabled, 'enabled', false)
              .having((s) => s.status, 'status', DisplayStatus.idle),
        ],
      );
    });

    // ── close ─────────────────────────────────────────────────────────────────

    group('close', () {
      test('closes without error when cubit was never used', () async {
        final cubit = buildCubit();
        await expectLater(cubit.close(), completes);
      });

      test('closes without error after setEnabled(true)', () async {
        final cubit = buildCubit();
        await cubit.setEnabled(true);
        await expectLater(cubit.close(), completes);
      });

      test('closes without error after scanDisplays (no-op on macOS)', () async {
        final cubit = buildCubit();
        await cubit.scanDisplays();
        await expectLater(cubit.close(), completes);
      });

      test('closes without error after transferData (no-op on macOS)', () async {
        final cubit = buildCubit();
        await cubit.transferData({'key': 'val'});
        await expectLater(cubit.close(), completes);
      });

      test('closes without error after reconnect with no lastKnownDisplayId', () async {
        final cubit = buildCubit();
        await cubit.reconnect();
        await expectLater(cubit.close(), completes);
      });
    });
  });
}
