import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/wallet/wallet_cubit.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/data/services/kaspa_wallet_service.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _LoginError { none, invalidWord, invalidChecksum, invalidWordCount, generic }

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.prefs,
    required this.onboardingNotifier,
  });

  final SharedPreferences prefs;
  final ValueNotifier<bool> onboardingNotifier;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = TextEditingController();

  bool _isValidating = false;
  _LoginError _error = _LoginError.none;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_error != _LoginError.none) setState(() => _error = _LoginError.none);
  }

  _LoginError _parseError(String raw) {
    if (raw.contains('InvalidWord') || raw.contains('invalid word')) {
      return _LoginError.invalidWord;
    }
    if (raw.contains('InvalidChecksum') || raw.contains('checksum')) {
      return _LoginError.invalidChecksum;
    }
    if (raw.contains('InvalidWordCount') || raw.contains('word count')) {
      return _LoginError.invalidWordCount;
    }
    return _LoginError.generic;
  }

  String? _errorText(AppLocalizations l10n) {
    return switch (_error) {
      _LoginError.none => null,
      _LoginError.invalidWord => l10n.loginErrorInvalidWord,
      _LoginError.invalidChecksum => l10n.loginErrorInvalidChecksum,
      _LoginError.invalidWordCount => l10n.loginErrorInvalidWordCount,
      _LoginError.generic => l10n.loginErrorGeneric,
    };
  }

  List<String> get _words {
    return _controller.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  bool get _canSubmit {
    final count = _words.length;
    return (count == 12 || count == 24) && !_isValidating;
  }

  void _submit() {
    if (!_canSubmit) return;
    final phrase = _words.join(' ');
    setState(() {
      _isValidating = true;
      _error = _LoginError.none;
    });

    final result = KaspaWalletService().validateMnemonic(phrase);
    if (result.valid) {
      _onValidationSuccess(phrase);
    } else {
      setState(() {
        _isValidating = false;
        _error = _parseError(result.error);
      });
    }
  }

  Future<void> _onValidationSuccess(String phrase) async {
    await widget.prefs.setString('wallet_mnemonic', phrase);
    await widget.prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    // Derive address before navigation so no page ever sees an empty address.
    await context.read<WalletCubit>().loadWallet(phrase);
    if (!mounted) return;
    widget.onboardingNotifier.value = true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final wordCount = _words.length;
    final hasEnoughWords = wordCount == 12 || wordCount == 24;

    return TitlebarSafeArea(
      child: Scaffold(
        appBar: BlurAppBar(
          title: Text(l10n.loginTitle),
          centerTitle: true,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.loginEnterPhrase,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.loginPhraseHint,
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.outline),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    minLines: 4,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: l10n.loginHintText,
                      border: const OutlineInputBorder(),
                      errorText: _errorText(l10n),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              tooltip: l10n.loginClear,
                              onPressed: () {
                                _controller.clear();
                                setState(() => _error = _LoginError.none);
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      l10n.loginWordCount(wordCount),
                      style: textTheme.bodySmall?.copyWith(
                        color: wordCount == 0
                            ? colorScheme.outline
                            : hasEnoughWords
                                ? colorScheme.primary
                                : colorScheme.error,
                        fontWeight: hasEnoughWords ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _canSubmit ? _submit : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: _isValidating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.loginButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
