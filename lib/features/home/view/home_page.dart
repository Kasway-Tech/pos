import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/network/network_state.dart';
import 'package:kasway/app/table/table_cubit.dart';
import 'package:kasway/app/widgets/macos_title_bar.dart';
import 'package:kasway/data/models/product.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:kasway/features/home/bloc/home_state.dart';
import 'package:kasway/features/home/view/additions_page.dart';
import 'package:kasway/features/home/view/widgets/additions_side_view.dart';
import 'package:kasway/features/home/view/widgets/order_side_view.dart';
import 'package:kasway/features/home/view/widgets/products_view.dart';
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
    with TickerProviderStateMixin {
  TabController? _tabController;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
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
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
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
          return Scaffold(
            body: Center(child: Text(context.l10n.homeFailedToLoad)),
          );
        }

        if (state.categories.isEmpty) {
          return Scaffold(body: Center(child: Text(context.l10n.homeNoProducts)));
        }

        final tabController = _tabController;
        if (tabController == null) {
          return const Scaffold(body: SizedBox.shrink());
        }

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLargeScreen = constraints.maxWidth >= 800;

              if (isLargeScreen) {
                return Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Scaffold(
                        appBar: _buildAppBar(
                          state,
                          tabController,
                          isLargeScreen,
                        ),
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
                              : const OrderSideView(
                                  key: ValueKey('order'),
                                  showAppBar: true,
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
                    _buildProductsBody(
                      state,
                      tabController,
                      bottomPadding: state.cartItems.isEmpty
                          ? 0.0
                          : kToolbarHeight + 16.0,
                    ),
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
                                      disabledBackgroundColor:
                                          Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          context.l10n.homeConfirmSelection,
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
          ),
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
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Center(
          child: SvgPicture.asset(
            'assets/svg/brand_icon.svg',
            height: 24,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      title: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        constraints: BoxConstraints(maxWidth: _isSearchFocused ? 280 : 140),
        height: _isSearchFocused ? 36 : 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: _isSearchFocused
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: GestureDetector(
          onTap: () => _searchFocusNode.requestFocus(),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                alignment: _isSearchFocused
                    ? Alignment.centerLeft
                    : Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(left: _isSearchFocused ? 12 : 0),
                  child: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.outline,
                    size: 16,
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isSearchFocused ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 36, right: 8),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: Theme.of(context).textTheme.bodySmall,
                    decoration: const InputDecoration(
                      hintText: '',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      context.read<HomeBloc>().add(
                        HomeSearchTermChanged(value),
                      );
                    },
                  ),
                ),
              ),
              if (_isSearchFocused && state.searchTerm.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _searchController.clear();
                        context.read<HomeBloc>().add(
                          const HomeSearchTermChanged(''),
                        );
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/profile'),
          padding: EdgeInsets.zero,
          icon: const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person, size: 20),
          ),
        ),
        const SizedBox(width: 14.0),
      ],
      bottom: state.searchTerm.isNotEmpty
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(kTextTabBarHeight),
              child: TabBar(
                controller: tabController,
                tabs: state.categories.map((c) => Tab(text: c)).toList(),
                isScrollable: state.categories.length >= 5,
                tabAlignment: state.categories.length >= 5
                    ? TabAlignment.start
                    : TabAlignment.fill,
                dividerColor: isLargeScreen
                    ? Theme.of(context).colorScheme.surfaceContainerHigh
                    : null,
              ),
            ),
    );
  }

  Widget _buildTestnetBanner() {
    return BlocBuilder<NetworkCubit, NetworkState>(
      buildWhen: (previous, current) => previous.network != current.network,
      builder: (context, networkState) {
        if (networkState.network != KaspaNetwork.testnet10) {
          return const SizedBox.shrink();
        }
        return Container(
          width: double.infinity,
          color: Colors.amber,
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            context.l10n.homeTestnetBanner,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
              fontSize: 13.0,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsBody(
    HomeState state,
    TabController tabController, {
    double bottomPadding = 0.0,
  }) {
    final grid = state.searchTerm.isNotEmpty
        ? ProductsView(
            items:
                state.itemsByCategory.values.expand((items) => items).toList(),
            onTap: (product) => _handleProductTap(product),
            onLongPress: (product) {
              context.read<HomeBloc>().add(HomeProductRemoved(product));
            },
            bottomPadding: bottomPadding,
          )
        : TabBarView(
            dragStartBehavior: DragStartBehavior.down,
            controller: tabController,
            children: state.categories.map((category) {
              return ProductsView(
                items: state.itemsByCategory[category] ?? [],
                onTap: (product) => _handleProductTap(product),
                onLongPress: (product) {
                  context.read<HomeBloc>().add(HomeProductRemoved(product));
                },
                bottomPadding: bottomPadding,
              );
            }).toList(),
          );

    return Column(
      children: [
        _buildTestnetBanner(),
        Expanded(child: grid),
      ],
    );
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
        title: Text(context.l10n.homeClearOrderTitle),
        content: Text(context.l10n.homeClearOrderContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.homeCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              context.l10n.homeClearOrder,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(HomeCartCleared());
      if (context.mounted) {
        context.read<TableCubit>().clearSelection();
      }
    }
  }

}
