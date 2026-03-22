import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/app/network/node_status_cubit.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Stub NetworkCubit — returns a fixed state and an empty stream.
// ---------------------------------------------------------------------------

class MockNetworkCubit extends Mock implements NetworkCubit {}

// ---------------------------------------------------------------------------
// A NetworkState that points to a guaranteed-unreachable URL so
// WebSocket.connect fails immediately with a SocketException.
// ---------------------------------------------------------------------------

// localhost on a high port that is very unlikely to be listening — connection
// refused errors are returned almost instantly by the OS.
const _unreachableUrl = 'ws://localhost:19999/wrpc/json';

NetworkState _unreachableState() =>
    const NetworkState().copyWith(resolvedMainnetUrl: _unreachableUrl);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('NodeStatusCubit failure counter', () {
    late MockNetworkCubit mockNetworkCubit;

    setUp(() {
      mockNetworkCubit = MockNetworkCubit();
      when(() => mockNetworkCubit.state)
          .thenReturn(_unreachableState());
      when(() => mockNetworkCubit.stream)
          .thenAnswer((_) => const Stream<NetworkState>.empty());
      when(() => mockNetworkCubit.triggerResolve())
          .thenAnswer((_) async {});
    });

    test('does not call triggerResolve before 3 failures', () async {
      final cubit = NodeStatusCubit(networkCubit: mockNetworkCubit);

      // Connect attempt is nearly instant (connection refused on 192.0.2.1
      // should fail fast) but we close before accumulating 3 failures.
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await cubit.close();

      verifyNever(() => mockNetworkCubit.triggerResolve());
    });

    test('calls triggerResolve after 3 consecutive failures', () async {
      // Each retry cycle: fast connection failure + 3 s delay.
      // 3 cycles * ~3 s = ~9 s; allow 11 s with buffer.
      final cubit = NodeStatusCubit(networkCubit: mockNetworkCubit);

      await Future<void>.delayed(const Duration(seconds: 11));
      await cubit.close();

      verify(() => mockNetworkCubit.triggerResolve())
          .called(greaterThanOrEqualTo(1));
    }, timeout: const Timeout(Duration(seconds: 20)));
  });
}
