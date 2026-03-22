import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/data/services/kaspa_resolver_service.dart';

// ---------------------------------------------------------------------------
// Fake dart:io HTTP infrastructure
// ---------------------------------------------------------------------------

typedef _ResponseFactory = FutureOr<_FakeHttpClientResponse> Function(Uri uri);

class _FakeHttpOverrides extends HttpOverrides {
  _FakeHttpOverrides(this._handler);
  final _ResponseFactory _handler;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _FakeHttpClient(_handler);
}

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient(this._handler);
  final _ResponseFactory _handler;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _FakeHttpClientRequest(url, _handler);

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(this._uri, this._handler);
  final Uri _uri;
  final _ResponseFactory _handler;

  @override
  Future<HttpClientResponse> close() async => _handler(_uri);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A fake [HttpClientResponse] that wraps a string body.
///
/// [HttpClientResponse] extends [Stream<List<int>>] — we extend the same
/// type so there is no conflict.
class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _FakeHttpClientResponse(this.statusCode, String body)
      : _bytes = utf8.encode(body);

  @override
  final int statusCode;

  final List<int> _bytes;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_bytes).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

_FakeHttpClientResponse _fakeResponse(int status, String body) =>
    _FakeHttpClientResponse(status, body);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('KaspaResolverService', () {
    tearDown(() => HttpOverrides.global = null);

    test('returns url from first responding resolver', () async {
      const testNode = 'https://test.node';
      HttpOverrides.global = _FakeHttpOverrides((_) async => _fakeResponse(
            200,
            '{"uid":"abc123","url":"wss://resolved.kaspa.stream/wrpc/json"}',
          ));

      final service = KaspaResolverService(overrideNodes: [testNode]);
      final result = await service.resolve(KaspaNetwork.mainnet);
      expect(result, 'wss://resolved.kaspa.stream/wrpc/json');
    });

    test('skips failed resolver and tries next', () async {
      const failNode = 'https://fail.node';
      const successNode = 'https://success.node';
      var callCount = 0;
      HttpOverrides.global = _FakeHttpOverrides((_) async {
        callCount++;
        if (callCount == 1) throw const SocketException('connection refused');
        return _fakeResponse(
            200, '{"uid":"abc","url":"wss://second.node/"}');
      });

      final service =
          KaspaResolverService(overrideNodes: [failNode, successNode]);
      final result = await service.resolve(KaspaNetwork.mainnet);
      expect(result, 'wss://second.node/');
      expect(callCount, 2);
    });

    test('returns null when all resolvers fail', () async {
      HttpOverrides.global = _FakeHttpOverrides(
          (_) async => throw const SocketException('fail'));

      final service =
          KaspaResolverService(overrideNodes: ['https://a', 'https://b']);
      final result = await service.resolve(KaspaNetwork.mainnet);
      expect(result, isNull);
    });

    test('skips non-200 response', () async {
      var callCount = 0;
      HttpOverrides.global = _FakeHttpOverrides((_) async {
        callCount++;
        if (callCount == 1) return _fakeResponse(503, 'Service Unavailable');
        return _fakeResponse(200, '{"uid":"x","url":"wss://ok.node/"}');
      });

      final service =
          KaspaResolverService(overrideNodes: ['https://a', 'https://b']);
      final result = await service.resolve(KaspaNetwork.mainnet);
      expect(result, 'wss://ok.node/');
    });

    test('skips response with missing url field', () async {
      var callCount = 0;
      HttpOverrides.global = _FakeHttpOverrides((_) async {
        callCount++;
        if (callCount == 1) {
          return _fakeResponse(200, '{"error":"overloaded"}');
        }
        return _fakeResponse(200, '{"uid":"x","url":"wss://ok.node/"}');
      });

      final service =
          KaspaResolverService(overrideNodes: ['https://a', 'https://b']);
      final result = await service.resolve(KaspaNetwork.mainnet);
      expect(result, 'wss://ok.node/');
    });

    test('uses testnet-10 path for testnet network', () async {
      Uri? capturedUri;
      HttpOverrides.global = _FakeHttpOverrides((uri) async {
        capturedUri = uri;
        return _fakeResponse(200, '{"uid":"x","url":"wss://testnet.node/"}');
      });

      final service =
          KaspaResolverService(overrideNodes: ['https://test.node']);
      await service.resolve(KaspaNetwork.testnet10);
      expect(capturedUri?.path, contains('testnet-10'));
    });

    test('uses mainnet path for mainnet network', () async {
      Uri? capturedUri;
      HttpOverrides.global = _FakeHttpOverrides((uri) async {
        capturedUri = uri;
        return _fakeResponse(200, '{"uid":"x","url":"wss://mainnet.node/"}');
      });

      final service =
          KaspaResolverService(overrideNodes: ['https://test.node']);
      await service.resolve(KaspaNetwork.mainnet);
      expect(capturedUri?.path, contains('mainnet'));
      expect(capturedUri?.path, isNot(contains('testnet')));
    });
  });
}
