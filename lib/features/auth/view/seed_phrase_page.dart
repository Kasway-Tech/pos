import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/data/services/kaspa_wallet_service.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeedPhrasePage extends StatefulWidget {
  const SeedPhrasePage({super.key});

  @override
  State<SeedPhrasePage> createState() => _SeedPhrasePageState();
}

class _SeedPhrasePageState extends State<SeedPhrasePage> {
  List<String> _words = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _generateMnemonic();
  }

  void _generateMnemonic() {
    try {
      final mnemonic = KaspaWalletService().generateMnemonic(wordCount: 12);
      setState(() {
        _words = mnemonic.split(' ');
        _error = '';
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _continue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallet_mnemonic', _words.join(' '));
    if (!mounted) return;
    context.push('/auth/currency');
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _words.join(' ')));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.seedPhraseCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return TitlebarSafeArea(
      child: Scaffold(
        appBar: BlurAppBar(
          title: Text(l10n.seedPhraseTitle),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (_words.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: l10n.seedPhraseCopyTooltip,
                onPressed: _copyToClipboard,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        l10n.seedPhraseWarning,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              Expanded(
                child: _error.isNotEmpty
                    ? Center(
                        child: Text(
                          l10n.seedPhraseError(_error),
                          style: TextStyle(color: colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _words.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: _words.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 0,
                            color: colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Text(
                                '${index + 1}. ${_words[index]}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24.0),
              FilledButton(
                onPressed: _words.isEmpty ? null : _continue,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(l10n.seedPhraseConfirm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
