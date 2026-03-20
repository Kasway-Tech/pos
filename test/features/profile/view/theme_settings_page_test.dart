import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/theme/theme_cubit.dart';
import 'package:kasway/app/theme/theme_state.dart';
import 'package:kasway/features/profile/view/theme_settings_page.dart';
import 'package:mocktail/mocktail.dart';

class MockThemeCubit extends MockCubit<ThemeState> implements ThemeCubit {}

void main() {
  late ThemeCubit themeCubit;

  setUp(() {
    themeCubit = MockThemeCubit();
    when(
      () => themeCubit.state,
    ).thenReturn(const ThemeState(themeMode: ThemeMode.system));
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider.value(
        value: themeCubit,
        child: const ThemeSettingsPage(),
      ),
    );
  }

  testWidgets('ThemeSettingsPage renders correctly', (tester) async {
    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('Theme Settings'), findsOneWidget);
    expect(find.text('Theme Mode'), findsOneWidget);
    expect(find.text('Primary Color'), findsOneWidget);
  });

  testWidgets(
    'ThemeSettingsPage respects max width constraint on small screens',
    (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildTestableWidget());

      final constrainedBoxFinder = find.byWidgetPredicate(
        (widget) =>
            widget is ConstrainedBox && widget.constraints.maxWidth == 600.0,
      );
      expect(constrainedBoxFinder, findsAtLeastNWidgets(1));

      addTearDown(tester.view.resetPhysicalSize);
    },
  );
}
