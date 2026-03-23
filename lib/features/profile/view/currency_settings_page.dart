import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kasway/app/l10n.dart';
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
        appBar: BlurAppBar(title: Text(context.l10n.settingsDisplayCurrency)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: BlocBuilder<CurrencyCubit, CurrencyState>(
              builder: (context, state) {
                return ListView.builder(
                  itemCount: CurrencyState.allCurrencies.length,
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
      return SvgPicture.asset(currency.iconPath!, width: 48, height: 48);
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
