import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'app/simple_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure macOS window
  if (Platform.isMacOS) {
    // Initialize window_manager
    await windowManager.ensureInitialized();

    await WindowManipulator.initialize(enableWindowDelegate: true);

    // Make title bar transparent and hide default title
    WindowManipulator.makeTitlebarTransparent();
    WindowManipulator.hideTitle();

    // Enable full size content view
    WindowManipulator.enableFullSizeContentView();

    // Delay showing the window until Flutter has painted its first frame.
    // Without this, the native window appears with a black background for a
    // brief moment before the splash screen renders (transparent titlebar +
    // full-size content view removes the default white window chrome).
    windowManager.waitUntilReadyToShow(null, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  Bloc.observer = const SimpleBlocObserver();

  final prefs = await SharedPreferences.getInstance();

  runApp(App(prefs: prefs));
}
