import 'package:atomikpos/data/models/cart_item.dart';
import 'package:atomikpos/data/models/product.dart';
import 'package:atomikpos/data/repositories/product_repository.dart';
import 'package:atomikpos/features/home/bloc/home_bloc.dart';
import 'package:atomikpos/features/home/bloc/home_event.dart';
import 'package:atomikpos/features/home/bloc/home_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  group('HomeBloc', () {
    late ProductRepository productRepository;
    final product = Product(
      id: '1',
      name: 'Test Product',
      price: 1000,
      imageUrl: 'image.png',
    );

    setUp(() {
      productRepository = MockProductRepository();
    });

    HomeBloc buildBloc() {
      return HomeBloc(productRepository: productRepository);
    }

    blocTest<HomeBloc, HomeState>(
      'emits updated cartItems when HomeCartQuantityUpdated is added',
      build: buildBloc,
      seed: () =>
          HomeState(cartItems: [CartItem(product: product, quantity: 1)]),
      act: (bloc) => bloc.add(HomeCartQuantityUpdated(product, 5)),
      expect: () => [
        HomeState(cartItems: [CartItem(product: product, quantity: 5)]),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'removes item from cart when quantity is updated to 0',
      build: buildBloc,
      seed: () =>
          HomeState(cartItems: [CartItem(product: product, quantity: 1)]),
      act: (bloc) => bloc.add(HomeCartQuantityUpdated(product, 0)),
      expect: () => [const HomeState(cartItems: [])],
    );

    blocTest<HomeBloc, HomeState>(
      'clears cart when HomeCartCleared is added',
      build: buildBloc,
      seed: () =>
          HomeState(cartItems: [CartItem(product: product, quantity: 1)]),
      act: (bloc) => bloc.add(HomeCartCleared()),
      expect: () => [const HomeState(cartItems: [])],
    );
  });
}
