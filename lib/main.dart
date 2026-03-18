import 'package:rinf/rinf.dart';
import 'src/bindings/bindings.dart';
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
  }

  await initializeRust(assignRustSignal);

  Bloc.observer = const SimpleBlocObserver();

  final prefs = await SharedPreferences.getInstance();

  runApp(App(prefs: prefs));
}
