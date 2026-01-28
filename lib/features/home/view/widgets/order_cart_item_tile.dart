import 'package:atomikpos/data/models/product.dart';
import 'package:atomikpos/features/home/bloc/home_bloc.dart';
import 'package:atomikpos/features/home/bloc/home_event.dart';
import 'package:atomikpos/features/home/bloc/home_state.dart';
import 'package:atomikpos/features/home/view/widgets/numeric_input_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class OrderCartItemTile extends StatelessWidget {
  const OrderCartItemTile({super.key, required this.product});

  final Product product;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'IDR ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 4.0 : 8.0),
      child: Row(
        children: [
          BlocSelector<HomeBloc, HomeState, int>(
            selector: (state) {
              try {
                return state.cartItems
                    .firstWhere((item) => item.product.id == product.id)
                    .quantity
                    .toInt();
              } catch (_) {
                return 0;
              }
            },
            builder: (context, quantity) {
              return NumericInputGroup(
                value: quantity,
                onChanged: (newQty) {
                  context.read<HomeBloc>().add(
                    HomeCartQuantityUpdated(product, newQty.toDouble()),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    BlocSelector<HomeBloc, HomeState, double>(
                      selector: (state) {
                        try {
                          return state.cartItems
                                  .firstWhere(
                                    (item) => item.product.id == product.id,
                                  )
                                  .quantity *
                              product.price;
                        } catch (_) {
                          return 0;
                        }
                      },
                      builder: (context, itemTotal) {
                        return Text(
                          _currencyFormat.format(itemTotal),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No additions',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(0),
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
