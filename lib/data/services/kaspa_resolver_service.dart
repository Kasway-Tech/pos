import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../app/network/network_state.dart';

/// Queries the Kaspa public resolver network to discover the least-loaded
/// available wRPC node for the requested network.
///
/// Route: `GET /v2/kaspa/:network/:tls/:protocol/:encoding`
/// Response: `{"uid": "...", "url": "wss://..."}`
class KaspaResolverService {
  KaspaResolverService({this.overrideNodes});

  /// Inject a custom list of base URLs for testing (bypasses [_resolverNodes]).
  @visibleForTesting
  final List<String>? overrideNodes;

  static const List<String> _resolverNodes = [
    'https://eric.kaspa.stream',
    'https://maxim.kaspa.stream',
    'https://sean.kaspa.stream',
    'https://troy.kaspa.stream',
    'https://john.kaspa.red',
    'https://mike.kaspa.red',
    'https://paul.kaspa.red',
    'https://alex.kaspa.red',
    'https://jake.kaspa.green',
    'https://mark.kaspa.green',
    'https://adam.kaspa.green',
    'https://liam.kaspa.green',
    'https://noah.kaspa.blue',
    'https://ryan.kaspa.blue',
    'https://jack.kaspa.blue',
    'https://luke.kaspa.blue',
  ];

  String _pathFor(KaspaNetwork network) {
    final net = network == KaspaNetwork.mainnet ? 'mainnet' : 'testnet-10';
    return '/v2/kaspa/$net/tls/wrpc/json';
  }

  /// Shuffles resolver nodes and tries each in order, returning the first
  /// `url` value from a successful 200 response. Returns `null` if all
  /// resolvers fail or return unusable responses.
  Future<String?> resolve(
    KaspaNetwork network, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final nodes = List<String>.from(overrideNodes ?? _resolverNodes)..shuffle();
    final path = _pathFor(network);

    for (final node in nodes) {
      try {
        final client = HttpClient();
        final req =
            await client.getUrl(Uri.parse('$node$path')).timeout(timeout);
        final resp = await req.close().timeout(timeout);
        if (resp.statusCode != 200) {
          client.close();
          continue;
        }
        final body =
            await resp.transform(utf8.decoder).join().timeout(timeout);
        client.close();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final url = json['url'] as String?;
        if (url != null && url.isNotEmpty) return url;
      } catch (_) {
        continue;
      }
    }
    return null;
  }
}
