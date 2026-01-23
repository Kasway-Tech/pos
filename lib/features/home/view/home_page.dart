import 'package:atomikpos/features/home/bloc/home_bloc.dart';
import 'package:atomikpos/features/home/bloc/home_event.dart';
import 'package:atomikpos/features/home/bloc/home_state.dart';
import 'package:atomikpos/features/home/view/widgets/products_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeView();
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

        return Scaffold(
          appBar: AppBar(
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
                      context.read<HomeBloc>().add(
                        HomeSearchTermChanged(value),
                      );
                    },
                  )
                : SvgPicture.asset('assets/svg/brand_icon.svg', height: 30),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      context.read<HomeBloc>().add(
                        const HomeSearchTermChanged(''),
                      );
                    }
                  });
                },
                icon: Icon(_isSearching ? Icons.close : Icons.search),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.lock_outline),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mail_outline),
              ),
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
                : TabBar(
                    controller: tabController,
                    tabs: state.categories.map((c) => Tab(text: c)).toList(),
                    isScrollable: state.categories.length >= 5,
                    tabAlignment: TabAlignment.start,
                  ),
          ),
          body: Stack(
            children: [
              if (_isSearching || state.searchTerm.isNotEmpty)
                ProductsView(
                  items: state.itemsByCategory.values
                      .expand((items) => items)
                      .toList(),
                  cartItems: state.cartItems,
                  onTap: (product) {
                    context.read<HomeBloc>().add(HomeProductAdded(product));
                  },
                  onLongPress: (product) {
                    context.read<HomeBloc>().add(HomeProductRemoved(product));
                  },
                )
              else
                TabBarView(
                  controller: tabController,
                  children: state.categories.map((category) {
                    return ProductsView(
                      items: state.itemsByCategory[category] ?? [],
                      cartItems: state.cartItems,
                      onTap: (product) {
                        context.read<HomeBloc>().add(HomeProductAdded(product));
                      },
                      onLongPress: (product) {
                        context.read<HomeBloc>().add(
                          HomeProductRemoved(product),
                        );
                      },
                    );
                  }).toList(),
                ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                bottom: state.cartItems.isEmpty ? -kToolbarHeight - 16.0 : 0,
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
                          onPressed: () async {
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
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
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
                          },
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
                                  const Text(
                                    'Confirm Selection',
                                    style: TextStyle(fontSize: 16),
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
  }
}
