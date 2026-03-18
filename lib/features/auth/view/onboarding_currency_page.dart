import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/currency/currency_cubit.dart';
import 'package:kasway/app/currency/currency_state.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

class OnboardingCurrencyPage extends StatelessWidget {
  const OnboardingCurrencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return TitlebarSafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.currencyTitle),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  Text(
                    l10n.currencyQuestion,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.currencyHint,
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.outline),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
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
                                ? Icon(Icons.check,
                                    color: colorScheme.primary)
                                : null,
                            onTap: () => context
                                .read<CurrencyCubit>()
                                .setCurrency(currency),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: FilledButton(
                onPressed: () => context.go('/onboarding'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(l10n.currencyContinue),
              ),
            ),
          ],
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
