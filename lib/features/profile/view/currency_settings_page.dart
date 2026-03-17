import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

import '../../../app/currency/currency_cubit.dart';
import '../../../app/currency/currency_state.dart';

class CurrencySettingsPage extends StatelessWidget {
  const CurrencySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TitlebarSafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Default Currency')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: BlocBuilder<CurrencyCubit, CurrencyState>(
              builder: (context, state) {
                return ListView.separated(
                  itemCount: CurrencyState.allCurrencies.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final currency = CurrencyState.allCurrencies[index];
                    final isSelected =
                        state.selectedCurrency.code == currency.code;
                    return ListTile(
                      leading: _buildLeading(context, currency),
                      title: Text(currency.displayName),
                      trailing: isSelected
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () =>
                          context.read<CurrencyCubit>().setCurrency(currency),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context, Currency currency) {
    if (currency.isCrypto && currency.iconPath != null) {
      return SizedBox(
        width: 48,
        height: 40,
        child: Center(
          child: SvgPicture.asset(currency.iconPath!, width: 40, height: 40),
        ),
      );
    }
    return SizedBox(
      width: 48,
      height: 40,
      child: Center(
        child: CountryFlag.fromCurrencyCode(
          currency.code,
          theme: const ImageTheme(width: 48, height: 28),
        ),
      ),
    );
  }
}
