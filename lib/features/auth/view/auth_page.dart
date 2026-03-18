import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/locale/locale_cubit.dart';
import 'package:kasway/app/widgets/language_picker_sheet.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  void _showLanguagePicker(BuildContext context) {
    LanguagePickerSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentLanguage = context.watch<LocaleCubit>().state.language;
    final l10n = context.l10n;

    return TitlebarSafeArea(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/app_icon.png',
                        width: 48,
                        height: 48,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showLanguagePicker(context),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                      ),
                      icon: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: CountryFlag.fromCountryCode(
                          currentLanguage.countryCode,
                          theme: const ImageTheme(width: 24, height: 16),
                        ),
                      ),
                      label: Text(
                        currentLanguage.code.toUpperCase(),
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  l10n.authTagline,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 48.0),
                FilledButton(
                  onPressed: () => context.push('/auth/eula'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(l10n.authCreateAccount),
                ),
                const SizedBox(height: 12.0),
                OutlinedButton(
                  onPressed: () => context.push('/auth/login'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(l10n.authLoginWithSeedPhrase),
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
