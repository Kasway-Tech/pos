import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/widgets/explorer_page.dart';
import 'package:kasway/app/widgets/price_text.dart';
import 'package:kasway/data/models/order.dart';
import 'package:kasway/data/models/order_item.dart';
import 'package:kasway/data/repositories/order_repository.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = context.read<OrderRepository>().getOrders();
  }

  Map<String, List<Order>> _groupByDate(List<Order> orders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final result = <String, List<Order>>{};
    for (final order in orders) {
      final d = order.createdAt;
      final day = DateTime(d.year, d.month, d.day);
      final String label;
      if (day == today) {
        label = 'Today';
      } else if (day == yesterday) {
        label = 'Yesterday';
      } else {
        label = DateFormat('d MMM yyyy').format(d);
      }
      result.putIfAbsent(label, () => []).add(order);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return TitlebarSafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Order History')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: FutureBuilder<List<Order>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return const Center(child: Text('No orders yet'));
                }

                final now = DateTime.now();
                final todayMidnight =
                    DateTime(now.year, now.month, now.day);
                final todayOrders = orders
                    .where((o) =>
                        !o.createdAt.isBefore(todayMidnight))
                    .toList();
                final todayTotal = todayOrders.fold<double>(
                    0, (sum, o) => sum + o.totalIdr);

                final groups = _groupByDate(orders);

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatColumn(
                                label: "Today's Orders",
                                value: todayOrders.length.toString(),
                              ),
                            ),
                            Expanded(
                              child: _StatColumnPrice(
                                label: "Today's Revenue",
                                idrAmount: todayTotal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    for (final entry in groups.entries) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                          child: Text(
                            entry.key,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline,
                                ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _OrderCard(
                            order: entry.value[index],
                          ),
                          childCount: entry.value.length,
                        ),
                      ),
                    ],
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                )),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StatColumnPrice extends StatelessWidget {
  const _StatColumnPrice({required this.label, required this.idrAmount});
  final String label;
  final double idrAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                )),
        const SizedBox(height: 4),
        PriceText(
          idrAmount,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final shortId = order.id.length >= 8
        ? order.id.substring(order.id.length - 8).toUpperCase()
        : order.id.toUpperCase();
    final timeStr = DateFormat('HH:mm').format(order.createdAt);

    final networkState = context.read<NetworkCubit>().state;
    final kasSymbol = networkState.kasSymbol;
    final kasStr = order.kasAmount > 0
        ? order.kasAmount
            .toStringAsFixed(4)
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '')
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: const RoundedRectangleBorder(),
        collapsedShape: const RoundedRectangleBorder(),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#$shortId',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(timeStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          )),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PriceText(order.totalIdr,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (kasStr != null &&
                    !context
                        .read<CurrencyCubit>()
                        .state
                        .selectedCurrency
                        .isCrypto)
                  Text(
                    '$kasStr $kasSymbol',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
              ],
            ),
          ],
        ),
        children: [
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.18),
            child: order.items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No item details recorded',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                        ),
                        if (order.txId.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                              icon: const Icon(Icons.open_in_browser_outlined,
                                  size: 16),
                              label: const Text('View on Explorer'),
                              onPressed: () {
                                final url =
                                    '${context.read<NetworkCubit>().state.explorerBaseUrl}${order.txId}';
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => ExplorerPage(url: url),
                                ));
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Column(
                      children: [
                        ...order.items.map((item) => _ItemRow(item: item)),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            PriceText(
                              order.totalIdr,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (order.txId.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                              icon: const Icon(Icons.open_in_browser_outlined,
                                  size: 16),
                              label: const Text('View on Explorer'),
                              onPressed: () {
                                final url =
                                    '${context.read<NetworkCubit>().state.explorerBaseUrl}${order.txId}';
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => ExplorerPage(url: url),
                                ));
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final additionTotal =
        item.additions.fold<double>(0, (sum, a) => sum + a.price);
    final lineTotal = (item.unitPrice + additionTotal) * item.quantity;
    final outlineStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.outline);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: product name + additions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.productName} × ${item.quantity}',
                    style: Theme.of(context).textTheme.bodyMedium),
                if (item.additions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text('No additions', style: outlineStyle),
                  )
                else
                  ...item.additions.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(a.name, style: outlineStyle),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right column: line total + per-addition prices
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PriceText(lineTotal,
                  style: Theme.of(context).textTheme.bodyMedium),
              ...item.additions.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: a.price > 0
                      ? PriceText(a.price, style: outlineStyle)
                      : Text('FREE', style: outlineStyle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
