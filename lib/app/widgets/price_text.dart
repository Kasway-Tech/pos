import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../currency/currency_cubit.dart';
import '../currency/currency_state.dart';
import '../network/network_cubit.dart';
import '../network/network_state.dart';

class PriceText extends StatelessWidget {
  const PriceText(this.idrPrice, {super.key, this.kasPrice, this.style});
  final double idrPrice;
  final double? kasPrice;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, networkState) {
        return BlocBuilder<CurrencyCubit, CurrencyState>(
          builder: (context, state) => Text(
            state.formatPrice(
              idrPrice,
              kasPrice: kasPrice,
              kasSymbol: networkState.kasSymbol,
            ),
            style: style,
          ),
        );
      },
    );
  }
}
