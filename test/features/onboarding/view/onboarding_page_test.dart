import 'package:bloc_test/bloc_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:kasway/features/onboarding/view/onboarding_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

// FilePicker extends PlatformInterface which verifies a token on set.
// MockPlatformInterfaceMixin bypasses that check so we can swap the platform.
class MockFilePicker extends Mock
    with MockPlatformInterfaceMixin
    implements FilePicker {}

// Stub home screen so we can assert navigation occurred (or didn't).
class _HomeStub extends StatelessWidget {
  const _HomeStub();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Text('home-stub'));
}

Widget _buildRouter({
  required MockHomeBloc homeBloc,
  required SharedPreferences prefs,
  required ValueNotifier<bool> onboardingNotifier,
}) {
  final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => BlocProvider<HomeBloc>.value(
          value: homeBloc,
          child: OnboardingPage(
            prefs: prefs,
            onboardingNotifier: onboardingNotifier,
          ),
        ),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const _HomeStub(),
      ),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FileType.any);
  });

  late MockHomeBloc homeBloc;
  late SharedPreferences prefs;
  late ValueNotifier<bool> onboardingNotifier;
  late MockFilePicker mockFilePicker;

  setUp(() async {
    homeBloc = MockHomeBloc();
    when(() => homeBloc.state).thenReturn(const HomeState());

    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    onboardingNotifier = ValueNotifier(false);

    mockFilePicker = MockFilePicker();
    FilePicker.platform = mockFilePicker;
  });

  tearDown(() {
    onboardingNotifier.dispose();
  });

  group('OnboardingPage — import catalog', () {
    testWidgets(
      'stays on onboarding and does not mark onboarding complete '
      'when the file picker is cancelled (returns null)',
      (tester) async {
        // Arrange: user dismisses the file picker without choosing a file.
        when(
          () => mockFilePicker.pickFiles(
            type: any(named: 'type'),
            allowedExtensions: any(named: 'allowedExtensions'),
          ),
        ).thenAnswer((_) async => null);

        await tester.pumpWidget(
          _buildRouter(
            homeBloc: homeBloc,
            prefs: prefs,
            onboardingNotifier: onboardingNotifier,
          ),
        );
        await tester.pump();

        // Confirm we start on the onboarding page.
        expect(find.byType(OnboardingPage), findsOneWidget);
        expect(find.text('home-stub'), findsNothing);

        // Act: tap the "Import from old device" card.
        await tester.tap(find.text('Import from old device'));
        await tester.pumpAndSettle();

        // Assert: still on onboarding — no navigation to '/'.
        expect(find.byType(OnboardingPage), findsOneWidget,
            reason: 'Should stay on OnboardingPage when file picker is cancelled');
        expect(find.text('home-stub'), findsNothing,
            reason: 'Should NOT navigate to home when file picker is cancelled');

        // Assert: onboarding preference was NOT written.
        expect(onboardingNotifier.value, isFalse,
            reason: 'onboardingNotifier must remain false when import is aborted');

        // Assert: HomeStarted was NOT dispatched (no data was imported).
        verifyNever(() => homeBloc.add(HomeStarted()));
      },
    );

  });
}
