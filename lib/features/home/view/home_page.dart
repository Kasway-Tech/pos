import 'package:atomikpos/app/widgets/macos_title_bar.dart';
import 'package:atomikpos/data/models/product.dart';
import 'package:atomikpos/features/home/bloc/home_bloc.dart';
import 'package:atomikpos/features/home/bloc/home_event.dart';
import 'package:atomikpos/features/home/bloc/home_state.dart';
import 'package:atomikpos/features/home/view/additions_page.dart';
import 'package:atomikpos/features/home/view/select_payment_method_page.dart';
import 'package:atomikpos/features/home/view/widgets/additions_side_view.dart';
import 'package:atomikpos/features/home/view/widgets/order_side_view.dart';
import 'package:atomikpos/features/home/view/widgets/products_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MacOSTitleBar(child: HomeView());
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isSearching = false;
  final _searchController = TextEditingController();
  Product? _selectedProductForAdditions;

  @override
  void initState() {
    super.initState();
    final state = context.read<HomeBloc>().state;
    if (state.categories.isNotEmpty) {
      _tabController = TabController(
        length: state.categories.length,
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          previous.categories != current.categories,
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.categories != current.categories ||
          previous.searchTerm != current.searchTerm ||
          previous.itemsByCategory != current.itemsByCategory ||
          previous.cartItems.isEmpty != current.cartItems.isEmpty,
      listener: (context, state) {
        if (state.categories.isNotEmpty) {
          _tabController?.dispose();
          _tabController = TabController(
            length: state.categories.length,
            vsync: this,
          );
        }
      },
      builder: (context, state) {
        if (state.status == HomeStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == HomeStatus.failure) {
          return const Scaffold(
            body: Center(child: Text('Failed to load products')),
          );
        }

        if (state.categories.isEmpty) {
          return const Scaffold(body: Center(child: Text('No products found')));
        }

        final tabController = _tabController;
        if (tabController == null) {
          return const Scaffold(body: SizedBox.shrink());
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isLargeScreen = constraints.maxWidth >= 800;

            if (isLargeScreen) {
              return Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Scaffold(
                      appBar: _buildAppBar(state, tabController, isLargeScreen),
                      body: _buildProductsBody(state, tabController),
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                  Expanded(
                    flex: 4,
                    child: ClipRect(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        reverseDuration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final isAdditionsPanel =
                              child.key == const ValueKey('additions');
                          final slideOffset = isAdditionsPanel
                              ? Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                )
                              : Tween<Offset>(
                                  begin: const Offset(-1, 0),
                                  end: Offset.zero,
                                );
                          return SlideTransition(
                            position: slideOffset.animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.fastOutSlowIn,
                              ),
                            ),
                            child: child,
                          );
                        },
                        child: _selectedProductForAdditions != null
                            ? AdditionsSideView(
                                key: const ValueKey('additions'),
                                product: _selectedProductForAdditions!,
                                onConfirm: (selectedAdditions) {
                                  context.read<HomeBloc>().add(
                                    HomeProductWithAdditionsAdded(
                                      _selectedProductForAdditions!,
                                      selectedAdditions,
                                    ),
                                  );
                                  setState(() {
                                    _selectedProductForAdditions = null;
                                  });
                                },
                                onBack: () {
                                  setState(() {
                                    _selectedProductForAdditions = null;
                                  });
                                },
                              )
                            : OrderSideView(
                                key: const ValueKey('order'),
                                showAppBar: true,
                                onProceedToPayment: () =>
                                    _showPaymentDialog(context),
                              ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Scaffold(
              appBar: _buildAppBar(state, tabController, isLargeScreen),
              body: Stack(
                children: [
                  _buildProductsBody(state, tabController),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    bottom: state.cartItems.isEmpty
                        ? -kToolbarHeight - 16.0
                        : 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        height: kToolbarHeight + 16.0,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => _confirmClearOrder(context),
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              icon: SizedBox(
                                width: kToolbarHeight + 16.0,
                                height: double.infinity,
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            VerticalDivider(
                              width: 1,
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                            ),
                            Expanded(
                              child: SizedBox(
                                height: double.infinity,
                                child: ElevatedButton(
                                  // INTENDED CHANGES, DO NOT FUCKING REMOVE
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Confirm Selection',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.arrow_forward),
                                    ],
                                  ),
                                  onPressed: () {
                                    context.push('/order-confirmation');
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    HomeState state,
    TabController tabController,
    bool isLargeScreen,
  ) {
    return AppBar(
      toolbarHeight: kToolbarHeight + 16.0,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                context.read<HomeBloc>().add(HomeSearchTermChanged(value));
              },
            )
          : SvgPicture.asset('assets/svg/brand_icon.svg', height: 28),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                context.read<HomeBloc>().add(const HomeSearchTermChanged(''));
              }
            });
          },
          icon: Icon(_isSearching ? Icons.close : Icons.search),
        ),
        const SizedBox(width: 4),
        IconButton(onPressed: () {}, icon: const Icon(Icons.lock_outline)),
        const SizedBox(width: 4),
        IconButton(onPressed: () {}, icon: const Icon(Icons.mail_outline)),
        const SizedBox(width: 16.0),
        IconButton(
          onPressed: () {
            context.push('/profile');
          },
          padding: EdgeInsets.zero,
          icon: const CircleAvatar(child: Icon(Icons.person)),
        ),
        const SizedBox(width: 14.0),
      ],
      bottom: _isSearching || state.searchTerm.isNotEmpty
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(kTextTabBarHeight),
              child: Stack(
                children: [
                  TabBar(
                    controller: tabController,
                    tabs: state.categories.map((c) => Tab(text: c)).toList(),
                    isScrollable: state.categories.length >= 5,
                    tabAlignment: TabAlignment.start,
                    dividerColor: isLargeScreen
                        ? Theme.of(context).colorScheme.surfaceContainerHigh
                        : null,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProductsBody(HomeState state, TabController tabController) {
    if (_isSearching || state.searchTerm.isNotEmpty) {
      return ProductsView(
        items: state.itemsByCategory.values.expand((items) => items).toList(),
        onTap: (product) => _handleProductTap(product),
        onLongPress: (product) {
          context.read<HomeBloc>().add(HomeProductRemoved(product));
        },
      );
    } else {
      return TabBarView(
        dragStartBehavior: DragStartBehavior.down,
        controller: tabController,
        children: state.categories.map((category) {
          return ProductsView(
            items: state.itemsByCategory[category] ?? [],
            onTap: (product) => _handleProductTap(product),
            onLongPress: (product) {
              context.read<HomeBloc>().add(HomeProductRemoved(product));
            },
          );
        }).toList(),
      );
    }
  }

  void _handleProductTap(Product product) {
    if (product.additions.isEmpty) {
      context.read<HomeBloc>().add(HomeProductAdded(product));
    } else {
      final screenWidth = MediaQuery.of(context).size.width;
      final isLargeScreen = screenWidth >= 800;

      if (isLargeScreen) {
        // Show in side panel on large screens
        setState(() {
          _selectedProductForAdditions = product;
        });
      } else {
        // Navigate to additions page on smaller screens
        _navigateToAdditionsPage(product);
      }
    }
  }

  void _navigateToAdditionsPage(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdditionsPage(
          product: product,
          onConfirm: (selectedAdditions) {
            Navigator.of(context).pop();
            context.read<HomeBloc>().add(
              HomeProductWithAdditionsAdded(product, selectedAdditions),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmClearOrder(BuildContext context) async {
    final bloc = context.read<HomeBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Order?'),
        content: const Text(
          'Are you sure you want to remove all items from the order list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Clear Order',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(HomeCartCleared());
    }
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: const SelectPaymentMethodPage(isDialog: true),
        ),
      ),
    );
  }
}
