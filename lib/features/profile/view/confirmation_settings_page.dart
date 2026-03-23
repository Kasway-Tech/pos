import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/confirmation/confirmation_cubit.dart';
import 'package:kasway/app/confirmation/confirmation_state.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/widgets/macos_title_bar.dart';

class ConfirmationSettingsPage extends StatefulWidget {
  const ConfirmationSettingsPage({super.key});

  @override
  State<ConfirmationSettingsPage> createState() =>
      _ConfirmationSettingsPageState();
}

class _ConfirmationSettingsPageState extends State<ConfirmationSettingsPage> {
  late final TextEditingController _countController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final state = context.read<ConfirmationCubit>().state;
    _countController = TextEditingController(
      text: state.requiredConfirmations.toString(),
    );
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final value = int.tryParse(_countController.text.trim()) ?? 50;
    context.read<ConfirmationCubit>().setRequiredConfirmations(value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.confirmationSettingsSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MacOSTitleBar(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.confirmationSettingsTitle)),
        body: BlocBuilder<ConfirmationCubit, ConfirmationState>(
          builder: (context, state) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      SwitchListTile(
                        title: Text(l10n.confirmationSettingsEnabled),
                        subtitle: Text(
                          l10n.confirmationSettingsEnabledSubtitle,
                        ),
                        value: state.enabled,
                        onChanged: (val) =>
                            context.read<ConfirmationCubit>().setEnabled(val),
                      ),
                      const Divider(),
                      if (state.enabled) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: TextFormField(
                            controller: _countController,
                            decoration: InputDecoration(
                              labelText: l10n.confirmationSettingsRequiredLabel,
                              hintText: l10n.confirmationSettingsRequiredHint,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (val) {
                              final n = int.tryParse(val?.trim() ?? '');
                              if (n == null || n < 50) {
                                return l10n.confirmationSettingsMinError;
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FilledButton(
                            onPressed: _save,
                            child: Text(l10n.invoiceSave),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
