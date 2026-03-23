import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/widgets/macos_title_bar.dart';

class EulaPage extends StatefulWidget {
  const EulaPage({super.key});

  @override
  State<EulaPage> createState() => _EulaPageState();
}

class _EulaPageState extends State<EulaPage> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return MacOSTitleBar(
      child: Scaffold(
        appBar: BlurAppBar(
          title: Text(l10n.eulaTitle),
          centerTitle: true,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.eulaMainTitle,
                          style: textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.eulaLastUpdated,
                          style: textTheme.bodySmall
                              ?.copyWith(color: colorScheme.outline),
                        ),
                        const SizedBox(height: 20),
                        _Section(title: l10n.eulaSection1Title, body: l10n.eulaSection1Body),
                        _Section(title: l10n.eulaSection2Title, body: l10n.eulaSection2Body),
                        _Section(title: l10n.eulaSection3Title, body: l10n.eulaSection3Body),
                        _Section(title: l10n.eulaSection4Title, body: l10n.eulaSection4Body),
                        _Section(title: l10n.eulaSection5Title, body: l10n.eulaSection5Body),
                        _Section(title: l10n.eulaSection6Title, body: l10n.eulaSection6Body),
                        _Section(title: l10n.eulaSection7Title, body: l10n.eulaSection7Body),
                        const SizedBox(height: 8),
                      ],
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _agreed,
                                onChanged: (v) =>
                                    setState(() => _agreed = v ?? false),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  l10n.eulaAgreeLabel,
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _agreed
                            ? () => context.push('/auth/seed-phrase')
                            : null,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: Text(l10n.eulaContinue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
