import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/data/repositories/order_repository.dart';
import 'package:kasway/features/profile/view/profile_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

Widget _wrap(Widget child, OrderRepository repo) {
  return RepositoryProvider<OrderRepository>(
    create: (_) => repo,
    child: BlocProvider(
      create: (_) => CurrencyCubit(),
      child: MaterialApp(home: child),
    ),
  );
}

void main() {
  late MockOrderRepository orderRepo;

  setUp(() {
    orderRepo = MockOrderRepository();
    when(() => orderRepo.getTodayRevenue()).thenAnswer((_) async => 0.0);
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ProfilePage renders correctly', (tester) async {
    await tester.pumpWidget(_wrap(const ProfilePage(), orderRepo));

    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('ProfilePage has max width constraint logic', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(_wrap(const ProfilePage(), orderRepo));

    final constrainedBoxFinder = find.byWidgetPredicate(
      (widget) =>
          widget is ConstrainedBox && widget.constraints.maxWidth == 600.0,
    );

    expect(constrainedBoxFinder, findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
