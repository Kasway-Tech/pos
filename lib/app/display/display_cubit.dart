import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presentation_displays/display.dart';
import 'package:presentation_displays/displays_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/preference_keys.dart';
import 'display_state.dart';

/// Manages the [presentation_displays] integration.
///
/// All [DisplayManager] calls are guarded by [_isSupported] so that macOS,
/// Windows, and Web never attempt to invoke the Android/iOS-only plugin.
class DisplayCubit extends Cubit<DisplayState> {
  DisplayCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const DisplayState()) {
    _load();
  }

  final SharedPreferences _prefs;

  /// Instantiated lazily and only on supported platforms to avoid
  /// [MissingPluginException] on macOS/desktop.
  DisplayManager? _displayManager;

  bool get _isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  DisplayManager _manager() {
    _displayManager ??= DisplayManager();
    return _displayManager!;
  }

  void _load() {
    final enabled = _prefs.getBool(PreferenceKeys.displayEnabled) ?? false;
    final lastId = _prefs.getInt(PreferenceKeys.displayLastConnectedId);

    emit(state.copyWith(enabled: enabled, lastKnownDisplayId: lastId));

    // Attempt auto-reconnect after a short delay so the widget tree is ready.
    if (_isSupported && enabled && lastId != null) {
      Timer(const Duration(seconds: 2), _tryAutoReconnect);
    }
  }

  Future<void> setEnabled(bool value) async {
    final wasConnected = state.isConnected;
    await _prefs.setBool(PreferenceKeys.displayEnabled, value);
    emit(state.copyWith(enabled: value));
    if (!value && wasConnected) await disconnect();
  }

  Future<void> scanDisplays() async {
    if (!_isSupported) return;

    emit(state.copyWith(status: DisplayStatus.scanning));
    try {
      final all = await _manager()
          .getDisplays(category: displayCategoryPresentation);
      if (isClosed) return;
      final secondary = (all ?? [])
          .where((d) => d.displayId != null && d.displayId != defaultDisplay)
          .map((d) => (id: d.displayId!, name: d.name ?? 'Display ${d.displayId}'))
          .toList();

      emit(state.copyWith(
        status: DisplayStatus.idle,
        availableDisplays: secondary,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: DisplayStatus.error,
        errorMessage: 'Scan failed: $e',
      ));
    }
  }

  Future<void> connect(int displayId, String displayName) async {
    if (!_isSupported) return;

    try {
      final ok = await _manager().showSecondaryDisplay(
        displayId: displayId,
        routerName: 'presentation',
      );
      if (isClosed) return;

      if (ok == true) {
        await _prefs.setInt(PreferenceKeys.displayLastConnectedId, displayId);
        emit(state.copyWith(
          status: DisplayStatus.connected,
          connectedDisplayId: displayId,
          connectedDisplayName: displayName,
          lastKnownDisplayId: displayId,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          status: DisplayStatus.error,
          errorMessage: 'Could not connect to "$displayName".',
        ));
      }
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: DisplayStatus.error,
        errorMessage: 'Connection error: $e',
      ));
    }
  }

  Future<void> disconnect() async {
    if (!_isSupported) return;
    final id = state.connectedDisplayId;
    if (id == null) return;

    try {
      await _manager().hideSecondaryDisplay(displayId: id);
    } catch (_) {
      // Best-effort: hide may fail if already disconnected physically.
    }

    emit(state.copyWith(
      status: DisplayStatus.idle,
      connectedDisplayId: null,
      connectedDisplayName: null,
    ));
  }

  /// Re-connect to the last known display (e.g. after returning to the payment
  /// page or if the connection dropped).
  Future<void> reconnect() async {
    final id = state.lastKnownDisplayId;
    if (id == null) return;

    final name = state.availableDisplays
        .where((d) => d.id == id)
        .map((d) => d.name)
        .firstOrNull;
    await connect(id, name ?? 'Display $id');
  }

  /// Send a [Map] payload to the secondary display engine.
  /// Passing [null] resets the secondary screen to the idle/waiting state.
  Future<void> transferData(Map<String, dynamic>? payload) async {
    if (!_isSupported || !state.isConnected) return;
    try {
      await _manager().transferDataToPresentation(payload);
    } catch (_) {
      // Fire-and-forget; tolerate plugin errors silently.
    }
  }

  Future<void> _tryAutoReconnect() async {
    if (!_isSupported || !state.enabled) return;
    final id = state.lastKnownDisplayId;
    if (id == null) return;

    await scanDisplays();
    if (isClosed) return;
    if (!state.enabled) return;

    final match = state.availableDisplays.where((d) => d.id == id).firstOrNull;
    if (match != null) await connect(match.id, match.name);
  }
}
