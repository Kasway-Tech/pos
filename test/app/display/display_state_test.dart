import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/display/display_state.dart';

void main() {
  group('DisplayStatus', () {
    test('has four values', () {
      expect(DisplayStatus.values.length, 4);
      expect(
        DisplayStatus.values,
        containsAll([
          DisplayStatus.idle,
          DisplayStatus.scanning,
          DisplayStatus.connected,
          DisplayStatus.error,
        ]),
      );
    });
  });

  group('DisplayState', () {
    // ── Default values ────────────────────────────────────────────────────────

    group('default constructor values', () {
      test('enabled defaults to false', () {
        expect(const DisplayState().enabled, isFalse);
      });

      test('status defaults to idle', () {
        expect(const DisplayState().status, DisplayStatus.idle);
      });

      test('availableDisplays defaults to empty list', () {
        expect(const DisplayState().availableDisplays, isEmpty);
      });

      test('connectedDisplayId defaults to null', () {
        expect(const DisplayState().connectedDisplayId, isNull);
      });

      test('connectedDisplayName defaults to null', () {
        expect(const DisplayState().connectedDisplayName, isNull);
      });

      test('lastKnownDisplayId defaults to null', () {
        expect(const DisplayState().lastKnownDisplayId, isNull);
      });

      test('errorMessage defaults to null', () {
        expect(const DisplayState().errorMessage, isNull);
      });
    });

    // ── isConnected getter ────────────────────────────────────────────────────

    group('isConnected', () {
      test('returns false when status is idle and connectedDisplayId is null', () {
        const state = DisplayState(status: DisplayStatus.idle);
        expect(state.isConnected, isFalse);
      });

      test('returns false when status is scanning and connectedDisplayId is null', () {
        const state = DisplayState(status: DisplayStatus.scanning);
        expect(state.isConnected, isFalse);
      });

      test('returns false when status is error and connectedDisplayId is null', () {
        const state = DisplayState(status: DisplayStatus.error);
        expect(state.isConnected, isFalse);
      });

      test('returns false when status is connected but connectedDisplayId is null', () {
        const state = DisplayState(status: DisplayStatus.connected);
        // connectedDisplayId is null by default
        expect(state.isConnected, isFalse);
      });

      test('returns false when connectedDisplayId is set but status is idle', () {
        final state = DisplayState(
          status: DisplayStatus.idle,
          connectedDisplayId: 1,
        );
        expect(state.isConnected, isFalse);
      });

      test('returns false when connectedDisplayId is set but status is scanning', () {
        final state = DisplayState(
          status: DisplayStatus.scanning,
          connectedDisplayId: 1,
        );
        expect(state.isConnected, isFalse);
      });

      test('returns false when connectedDisplayId is set but status is error', () {
        final state = DisplayState(
          status: DisplayStatus.error,
          connectedDisplayId: 1,
        );
        expect(state.isConnected, isFalse);
      });

      test('returns true when status is connected AND connectedDisplayId is non-null', () {
        final state = DisplayState(
          status: DisplayStatus.connected,
          connectedDisplayId: 2,
        );
        expect(state.isConnected, isTrue);
      });

      test('returns true for display id 1 (first secondary display)', () {
        final state = DisplayState(
          status: DisplayStatus.connected,
          connectedDisplayId: 1,
        );
        expect(state.isConnected, isTrue);
      });

      test('returns true for large display id values', () {
        final state = DisplayState(
          status: DisplayStatus.connected,
          connectedDisplayId: 99999,
        );
        expect(state.isConnected, isTrue);
      });
    });

    // ── copyWith — preserves unset fields ─────────────────────────────────────

    group('copyWith preserves unset fields', () {
      test('returns identical values when no overrides provided', () {
        final original = DisplayState(
          enabled: true,
          status: DisplayStatus.connected,
          availableDisplays: const [(id: 1, name: 'HDMI Display')],
          connectedDisplayId: 1,
          connectedDisplayName: 'HDMI Display',
          lastKnownDisplayId: 1,
          errorMessage: null,
        );

        final copy = original.copyWith();

        expect(copy.enabled, original.enabled);
        expect(copy.status, original.status);
        expect(copy.availableDisplays, original.availableDisplays);
        expect(copy.connectedDisplayId, original.connectedDisplayId);
        expect(copy.connectedDisplayName, original.connectedDisplayName);
        expect(copy.lastKnownDisplayId, original.lastKnownDisplayId);
        expect(copy.errorMessage, original.errorMessage);
      });

      test('preserves nullable fields when not specified', () {
        final state = DisplayState(
          connectedDisplayId: 3,
          connectedDisplayName: 'TV',
          lastKnownDisplayId: 3,
          errorMessage: 'previous error',
        );

        final copy = state.copyWith(enabled: true);

        expect(copy.connectedDisplayId, 3);
        expect(copy.connectedDisplayName, 'TV');
        expect(copy.lastKnownDisplayId, 3);
        expect(copy.errorMessage, 'previous error');
      });

      test('preserves enabled and status when only availableDisplays changes', () {
        final original = DisplayState(
          enabled: true,
          status: DisplayStatus.scanning,
          availableDisplays: const [],
        );

        final copy = original.copyWith(
          availableDisplays: const [(id: 1, name: 'HDMI 1'), (id: 2, name: 'HDMI 2')],
        );

        expect(copy.enabled, isTrue);
        expect(copy.status, DisplayStatus.scanning);
        expect(copy.availableDisplays.length, 2);
      });
    });

    // ── copyWith — updates fields ──────────────────────────────────────────────

    group('copyWith updates individual fields', () {
      test('overrides enabled', () {
        const state = DisplayState(enabled: false);
        final copy = state.copyWith(enabled: true);
        expect(copy.enabled, isTrue);
        expect(copy.status, DisplayStatus.idle); // unchanged
      });

      test('overrides status', () {
        const state = DisplayState(status: DisplayStatus.idle);
        final copy = state.copyWith(status: DisplayStatus.scanning);
        expect(copy.status, DisplayStatus.scanning);
        expect(copy.enabled, isFalse); // unchanged
      });

      test('overrides availableDisplays with non-empty list', () {
        const state = DisplayState();
        final copy = state.copyWith(
          availableDisplays: const [(id: 1, name: 'Screen 1')],
        );
        expect(copy.availableDisplays.length, 1);
        expect(copy.availableDisplays.first.id, 1);
        expect(copy.availableDisplays.first.name, 'Screen 1');
      });

      test('overrides connectedDisplayId with new value', () {
        final state = DisplayState(connectedDisplayId: 1);
        final copy = state.copyWith(connectedDisplayId: 5);
        expect(copy.connectedDisplayId, 5);
      });

      test('overrides connectedDisplayName with new value', () {
        final state = DisplayState(connectedDisplayName: 'Old Name');
        final copy = state.copyWith(connectedDisplayName: 'New Name');
        expect(copy.connectedDisplayName, 'New Name');
      });

      test('overrides lastKnownDisplayId with new value', () {
        final state = DisplayState(lastKnownDisplayId: 2);
        final copy = state.copyWith(lastKnownDisplayId: 4);
        expect(copy.lastKnownDisplayId, 4);
      });

      test('overrides errorMessage with new value', () {
        const state = DisplayState();
        final copy = state.copyWith(errorMessage: 'Scan failed');
        expect(copy.errorMessage, 'Scan failed');
      });

      test('can transition from error to idle by overriding status', () {
        final state = DisplayState(
          status: DisplayStatus.error,
          errorMessage: 'Connection failed',
        );
        final copy = state.copyWith(
          status: DisplayStatus.idle,
          errorMessage: null,
        );
        expect(copy.status, DisplayStatus.idle);
        expect(copy.errorMessage, isNull);
      });
    });

    // ── copyWith — sentinel clears nullable fields ────────────────────────────

    group('copyWith clears nullable fields via explicit null', () {
      test('clears connectedDisplayId when explicitly set to null', () {
        final state = DisplayState(connectedDisplayId: 1);
        final copy = state.copyWith(connectedDisplayId: null);
        expect(copy.connectedDisplayId, isNull);
      });

      test('clears connectedDisplayName when explicitly set to null', () {
        final state = DisplayState(connectedDisplayName: 'HDMI Display');
        final copy = state.copyWith(connectedDisplayName: null);
        expect(copy.connectedDisplayName, isNull);
      });

      test('clears lastKnownDisplayId when explicitly set to null', () {
        final state = DisplayState(lastKnownDisplayId: 3);
        final copy = state.copyWith(lastKnownDisplayId: null);
        expect(copy.lastKnownDisplayId, isNull);
      });

      test('clears errorMessage when explicitly set to null', () {
        final state = DisplayState(errorMessage: 'previous error');
        final copy = state.copyWith(errorMessage: null);
        expect(copy.errorMessage, isNull);
      });

      test('isConnected becomes false after clearing connectedDisplayId', () {
        final connected = DisplayState(
          status: DisplayStatus.connected,
          connectedDisplayId: 1,
        );
        expect(connected.isConnected, isTrue);

        final copy = connected.copyWith(connectedDisplayId: null);
        expect(copy.isConnected, isFalse);
      });

      test('clearing connected state simultaneously resets to idle', () {
        final connected = DisplayState(
          status: DisplayStatus.connected,
          connectedDisplayId: 1,
          connectedDisplayName: 'TV',
        );

        final idle = connected.copyWith(
          status: DisplayStatus.idle,
          connectedDisplayId: null,
          connectedDisplayName: null,
        );

        expect(idle.status, DisplayStatus.idle);
        expect(idle.connectedDisplayId, isNull);
        expect(idle.connectedDisplayName, isNull);
        expect(idle.isConnected, isFalse);
      });
    });

    // ── Full connected-state lifecycle ────────────────────────────────────────

    group('state transition lifecycle', () {
      test('idle → scanning → idle with displays → connected → idle matches typical flow', () {
        const initial = DisplayState();
        expect(initial.status, DisplayStatus.idle);
        expect(initial.isConnected, isFalse);

        final scanning = initial.copyWith(status: DisplayStatus.scanning);
        expect(scanning.status, DisplayStatus.scanning);
        expect(scanning.isConnected, isFalse);

        final foundDisplays = scanning.copyWith(
          status: DisplayStatus.idle,
          availableDisplays: const [(id: 1, name: 'HDMI 1')],
        );
        expect(foundDisplays.availableDisplays.length, 1);

        final connected = foundDisplays.copyWith(
          status: DisplayStatus.connected,
          connectedDisplayId: 1,
          connectedDisplayName: 'HDMI 1',
          lastKnownDisplayId: 1,
          errorMessage: null,
        );
        expect(connected.isConnected, isTrue);
        expect(connected.lastKnownDisplayId, 1);

        final disconnected = connected.copyWith(
          status: DisplayStatus.idle,
          connectedDisplayId: null,
          connectedDisplayName: null,
        );
        expect(disconnected.isConnected, isFalse);
        // lastKnownDisplayId persists after disconnect
        expect(disconnected.lastKnownDisplayId, 1);
      });
    });
  });
}
