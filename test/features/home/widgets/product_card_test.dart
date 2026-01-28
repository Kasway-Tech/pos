import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:kasway/features/home/view/widgets/product_card.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

void main() {
  late HomeBloc homeBloc;

  setUp(() {
    homeBloc = MockHomeBloc();
    when(() => homeBloc.state).thenReturn(const HomeState());
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider.value(
        value: homeBloc,
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('ProductCard renders correctly', (tester) async {
    final product = Product(
      id: '1',
      name: 'Test Product',
      price: 10000,
      imageUrl: '',
    );

    await tester.pumpWidget(
      buildTestableWidget(
        ProductCard(product: product, onTap: () {}, onLongPress: () {}),
      ),
    );

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('IDR 10.000'), findsOneWidget);
  });
}
