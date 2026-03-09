import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'app/env.dart';
import 'app/simple_bloc_observer.dart';

/// Global key so the auth error handler can show snackbars outside the
/// widget tree (e.g. when supabase_flutter throws on an expired deep link).
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch AuthExceptions thrown by supabase_flutter's internal deep-link
  // handler before they reach the unhandled-exception logger and crash the app.
  PlatformDispatcher.instance.onError = (error, stack) {
    if (error is AuthException) {
      debugPrint('Auth error (handled): ${error.message}');
      // Defer to the next frame so the widget tree is guaranteed to be ready.
      Future.delayed(Duration.zero, () {
        scaffoldMessengerKey.currentState
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(_authErrorMessage(error)),
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
            ),
          );
      });
      return true; // exception handled — do not crash
    }
    return false; // let other errors propagate normally
  };

  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  // Configure macOS window
  if (Platform.isMacOS) {
    await windowManager.ensureInitialized();

    await WindowManipulator.initialize(enableWindowDelegate: true);

    WindowManipulator.makeTitlebarTransparent();
    WindowManipulator.hideTitle();
    WindowManipulator.enableFullSizeContentView();
  }

  Bloc.observer = const SimpleBlocObserver();

  runApp(App(scaffoldMessengerKey: scaffoldMessengerKey));
}

String _authErrorMessage(AuthException e) {
  return switch (e.code) {
    'otp_expired' || 'access_denied' =>
      'The sign-in link has expired. Please request a new invitation.',
    'user_already_exists' => 'An account with this email already exists.',
    _ => e.message,
  };
}
