import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../currency/currency_cubit.dart';
import '../currency/currency_state.dart';

class PriceText extends StatelessWidget {
  const PriceText(this.idrPrice, {super.key, this.style});
  final double idrPrice;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, state) =>
          Text(state.formatPrice(idrPrice), style: style),
    );
  }
}
