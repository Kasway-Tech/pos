import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/invoice/invoice_cubit.dart';
import 'package:kasway/app/invoice/invoice_state.dart';
import 'package:kasway/app/l10n.dart';

class InvoiceSettingsPage extends StatefulWidget {
  const InvoiceSettingsPage({super.key});

  @override
  State<InvoiceSettingsPage> createState() => _InvoiceSettingsPageState();
}

class _InvoiceSettingsPageState extends State<InvoiceSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _footerCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<InvoiceCubit>().state;
    _nameCtrl = TextEditingController(text: s.businessName);
    _addressCtrl = TextEditingController(text: s.businessAddress);
    _phoneCtrl = TextEditingController(text: s.businessPhone);
    _footerCtrl = TextEditingController(text: s.footerText);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<InvoiceCubit>().setBusinessInfo(
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      footer: _footerCtrl.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.invoiceSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.invoiceTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Business Information ────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.invoiceBusinessInfoTitle,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.invoiceBusinessName,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? l10n.invoiceRequiredField
                                  : null,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.invoiceBusinessAddress,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? l10n.invoiceRequiredField
                                  : null,
                          maxLines: 2,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.invoiceBusinessPhone,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? l10n.invoiceRequiredField
                                  : null,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _footerCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.invoiceFooter,
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 2,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _save,
                            child: Text(l10n.invoiceSave),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Print Settings ──────────────────────────────────────
                Card(
                  child: BlocBuilder<InvoiceCubit, InvoiceState>(
                    builder: (context, state) => SwitchListTile(
                      title: Text(l10n.invoiceEnablePrint),
                      subtitle: state.isConfigured
                          ? null
                          : Text(
                              l10n.invoiceEnableRequiresBiz,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .error,
                              ),
                            ),
                      value: state.enabled,
                      onChanged: state.isConfigured
                          ? (v) =>
                              context.read<InvoiceCubit>().setEnabled(v)
                          : null,
                    ),
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
