import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:kasway/features/home/view/home_page.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

void main() {
  late HomeBloc homeBloc;

  setUp(() {
    homeBloc = MockHomeBloc();
    when(() => homeBloc.state).thenReturn(const HomeState());
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider.value(value: homeBloc, child: const HomePage()),
    );
  }

  testWidgets('renders HomePage', (tester) async {
    when(
      () => homeBloc.state,
    ).thenReturn(const HomeState(status: HomeStatus.success));
    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('shows loading indicator when status is loading', (tester) async {
    when(
      () => homeBloc.state,
    ).thenReturn(const HomeState(status: HomeStatus.loading));
    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
