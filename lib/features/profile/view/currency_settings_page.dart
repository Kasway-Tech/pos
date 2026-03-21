import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/widgets/macos_title_bar.dart';

import '../../../app/currency/currency_cubit.dart';
import '../../../app/currency/currency_state.dart';

class CurrencySettingsPage extends StatelessWidget {
  const CurrencySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MacOSTitleBar(
      child: Scaffold(
        appBar: BlurAppBar(title: const Text('Display Currency')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: BlocBuilder<CurrencyCubit, CurrencyState>(
              builder: (context, state) {
                return ListView.separated(
                  itemCount: CurrencyState.allCurrencies.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final currency = CurrencyState.allCurrencies[index];
                    final isSelected =
                        state.selectedCurrency.code == currency.code;
                    return ListTile(
                      leading: _buildLeading(context, currency),
                      title: Text(currency.displayName),
                      trailing: isSelected ? const Icon(Icons.check) : null,
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
      return Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SvgPicture.asset(currency.iconPath!),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: CountryFlag.fromCurrencyCode(
        currency.code,
        theme: const ImageTheme(width: 40, height: 28),
      ),
    );
  }
}
