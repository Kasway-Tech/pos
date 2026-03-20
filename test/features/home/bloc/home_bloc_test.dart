import 'package:kasway/data/models/addition.dart';
import 'package:kasway/data/models/cart_item.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/data/repositories/order_repository.dart';
import 'package:kasway/data/repositories/product_repository.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('HomeBloc', () {
    late ProductRepository productRepository;
    late OrderRepository orderRepository;

    final addition1 = const Addition(
      id: 'a1',
      name: 'Extra Cheese',
      price: 500,
    );
    final addition2 = const Addition(id: 'a2', name: 'Spicy', price: 0);

    final product = Product(
      id: '1',
      name: 'Test Product',
      price: 1000,
      imageUrl: 'image.png',
    );

    final productWithAdditions = Product(
      id: '2',
      name: 'Product With Additions',
      price: 2000,
      imageUrl: 'image.png',
      additions: [addition1, addition2],
    );

    setUp(() {
      productRepository = MockProductRepository();
      orderRepository = MockOrderRepository();
    });

    HomeBloc buildBloc() {
      return HomeBloc(
        productRepository: productRepository,
        orderRepository: orderRepository,
      );
    }

    group('HomeStarted', () {
      test('initial state is correct', () {
        expect(buildBloc().state, const HomeState());
      });

      blocTest<HomeBloc, HomeState>(
        'emits [loading, success] with categories and items when subscription succeeds',
        setUp: () {
          when(
            () => productRepository.getCategories(),
          ).thenAnswer(
            (_) async => ['Promo', 'Makanan', 'Minuman', 'Paket', 'Lainnya'],
          );
          when(
            () => productRepository.getProductsByCategory(any()),
          ).thenAnswer((_) async => [product]);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HomeStarted()),
        expect: () => [
          const HomeState(status: HomeStatus.loading),
          isA<HomeState>()
              .having((s) => s.status, 'status', HomeStatus.success)
              .having((s) => s.categories, 'categories', [
                'Promo',
                'Makanan',
                'Minuman',
                'Paket',
                'Lainnya',
              ])
              .having(
                (s) => s.itemsByCategory['Makanan'],
                'items in Makanan',
                contains(product),
              ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits [loading, failure] when subscription fails',
        setUp: () {
          when(
            () => productRepository.getCategories(),
          ).thenAnswer(
            (_) async => ['Promo', 'Makanan', 'Minuman', 'Paket', 'Lainnya'],
          );
          when(
            () => productRepository.getProductsByCategory(any()),
          ).thenThrow(Exception('failure'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HomeStarted()),
        expect: () => [
          const HomeState(status: HomeStatus.loading),
          const HomeState(status: HomeStatus.failure),
        ],
      );
    });

    group('HomeProductAdded', () {
      blocTest<HomeBloc, HomeState>(
        'adds new product to cart',
        build: buildBloc,
        act: (bloc) => bloc.add(HomeProductAdded(product)),
        expect: () => [
          HomeState(cartItems: [CartItem(product: product, quantity: 1)]),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'increments quantity when same product is added again',
        build: buildBloc,
        seed: () =>
            HomeState(cartItems: [CartItem(product: product, quantity: 1)]),
        act: (bloc) => bloc.add(HomeProductAdded(product)),
        expect: () => [
          HomeState(cartItems: [CartItem(product: product, quantity: 2)]),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'does not exceed max quantity of 99',
        build: buildBloc,
        seed: () =>
            HomeState(cartItems: [CartItem(product: product, quantity: 99)]),
        act: (bloc) => bloc.add(HomeProductAdded(product)),
        expect: () => [],
      );
    });

    group('HomeProductWithAdditionsAdded', () {
      blocTest<HomeBloc, HomeState>(
        'adds product with additions to cart',
        build: buildBloc,
        act: (bloc) => bloc.add(
          HomeProductWithAdditionsAdded(productWithAdditions, [addition1]),
        ),
        expect: () => [
          HomeState(
            cartItems: [
              CartItem(
                product: productWithAdditions,
                quantity: 1,
                selectedAdditions: [addition1],
              ),
            ],
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'increments quantity when same product with same additions is added',
        build: buildBloc,
        seed: () => HomeState(
          cartItems: [
            CartItem(
              product: productWithAdditions,
              quantity: 1,
              selectedAdditions: [addition1],
            ),
          ],
        ),
        act: (bloc) => bloc.add(
          HomeProductWithAdditionsAdded(productWithAdditions, [addition1]),
        ),
        expect: () => [
          HomeState(
            cartItems: [
              CartItem(
                product: productWithAdditions,
                quantity: 2,
                selectedAdditions: [addition1],
              ),
            ],
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'creates new cart item when same product with different additions is added',
        build: buildBloc,
        seed: () => HomeState(
          cartItems: [
            CartItem(
              product: productWithAdditions,
              quantity: 1,
              selectedAdditions: [addition1],
            ),
          ],
        ),
        act: (bloc) => bloc.add(
          HomeProductWithAdditionsAdded(productWithAdditions, [addition2]),
        ),
        expect: () => [
          HomeState(
            cartItems: [
              CartItem(
                product: productWithAdditions,
                quantity: 1,
                selectedAdditions: [addition1],
              ),
              CartItem(
                product: productWithAdditions,
                quantity: 1,
                selectedAdditions: [addition2],
              ),
            ],
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'creates new cart item when same product with no additions is added after one with additions',
        build: buildBloc,
        seed: () => HomeState(
          cartItems: [
            CartItem(
              product: productWithAdditions,
              quantity: 1,
              selectedAdditions: [addition1],
            ),
          ],
        ),
        act: (bloc) =>
            bloc.add(HomeProductWithAdditionsAdded(productWithAdditions, [])),
        expect: () => [
          HomeState(
            cartItems: [
              CartItem(
                product: productWithAdditions,
                quantity: 1,
                selectedAdditions: [addition1],
              ),
              CartItem(
                product: productWithAdditions,
                quantity: 1,
                selectedAdditions: [],
              ),
            ],
          ),
        ],
      );
    });

    group('HomeCartQuantityUpdated', () {
      blocTest<HomeBloc, HomeState>(
        'updates quantity for item without additions',
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
        'updates quantity for specific item with matching additions',
        build: buildBloc,
        seed: () => HomeState(
          cartItems: [
            CartItem(
              product: productWithAdditions,
              quantity: 1,
              selectedAdditions: [addition1],
            ),
            CartItem(
              product: productWithAdditions,
              quantity: 2,
              selectedAdditions: [addition2],
            ),
          ],
        ),
        act: (bloc) => bloc.add(
          HomeCartQuantityUpdated(
            productWithAdditions,
            5,
            selectedAdditions: [addition2],
          ),
        ),
        expect: () => [
          HomeState(
            cartItems: [
              CartItem(
                product: productWithAdditions,
                quantity: 1,
                selectedAdditions: [addition1],
              ),
              CartItem(
                product: productWithAdditions,
                quantity: 5,
                selectedAdditions: [addition2],
              ),
            ],
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'removes specific item when quantity is set to 0 while preserving others',
        build: buildBloc,
        seed: () => HomeState(
          cartItems: [
            CartItem(
              product: productWithAdditions,
              quantity: 1,
              selectedAdditions: [addition1],
            ),
            CartItem(
              product: productWithAdditions,
              quantity: 2,
              selectedAdditions: [addition2],
            ),
          ],
        ),
        act: (bloc) => bloc.add(
          HomeCartQuantityUpdated(
            productWithAdditions,
            0,
            selectedAdditions: [addition1],
          ),
        ),
        expect: () => [
          HomeState(
            cartItems: [
              CartItem(
                product: productWithAdditions,
                quantity: 2,
                selectedAdditions: [addition2],
              ),
            ],
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'clamps quantity to max 99',
        build: buildBloc,
        seed: () =>
            HomeState(cartItems: [CartItem(product: product, quantity: 1)]),
        act: (bloc) => bloc.add(HomeCartQuantityUpdated(product, 150)),
        expect: () => [
          HomeState(cartItems: [CartItem(product: product, quantity: 99)]),
        ],
      );
    });

    group('HomeCartCleared', () {
      blocTest<HomeBloc, HomeState>(
        'clears cart when HomeCartCleared is added',
        build: buildBloc,
        seed: () =>
            HomeState(cartItems: [CartItem(product: product, quantity: 1)]),
        act: (bloc) => bloc.add(HomeCartCleared()),
        expect: () => [const HomeState(cartItems: [])],
      );
    });

    group('HomeSearchTermChanged', () {
      blocTest<HomeBloc, HomeState>(
        'filters products when HomeSearchTermChanged is added',
        build: buildBloc,
        seed: () => HomeState(
          categories: ['Makanan'],
          initialItemsByCategory: {
            'Makanan': [
              Product(id: '1', name: 'Nasi Goreng', price: 1000),
              Product(id: '2', name: 'Mie Ayam', price: 1000),
            ],
          },
          itemsByCategory: {
            'Makanan': [
              Product(id: '1', name: 'Nasi Goreng', price: 1000),
              Product(id: '2', name: 'Mie Ayam', price: 1000),
            ],
          },
        ),
        act: (bloc) => bloc.add(const HomeSearchTermChanged('nasi')),
        expect: () => [
          isA<HomeState>()
              .having(
                (s) => s.itemsByCategory['Makanan'],
                'itemsByCategory',
                contains(
                  predicate((p) => (p as Product).name == 'Nasi Goreng'),
                ),
              )
              .having(
                (s) => s.itemsByCategory['Makanan']?.length,
                'itemsByCategory length',
                1,
              ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'shows all products when search term is empty',
        build: buildBloc,
        seed: () => HomeState(
          searchTerm: 'nasi',
          categories: ['Makanan'],
          initialItemsByCategory: {
            'Makanan': [Product(id: '1', name: 'Nasi Goreng', price: 1000)],
          },
          itemsByCategory: {'Makanan': []},
        ),
        act: (bloc) => bloc.add(const HomeSearchTermChanged('')),
        expect: () => [
          isA<HomeState>().having(
            (s) => s.itemsByCategory['Makanan']?.length,
            'itemsByCategory length',
            1,
          ),
        ],
      );
    });
  });
}
