import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/data/repositories/product_repository.dart';
import 'package:kasway/data/repositories/withdrawal_repository.dart';
import 'package:kasway/data/services/data_service.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';

class DataTransferPage extends StatefulWidget {
  const DataTransferPage({super.key});

  @override
  State<DataTransferPage> createState() => _DataTransferPageState();
}

class _DataTransferPageState extends State<DataTransferPage> {
  late final DataService _dataService;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _dataService = DataService(
      ProductRepository(),
      context.read<WithdrawalRepository>(),
    );
  }

  Future<void> _export() async {
    setState(() => _loading = true);
    try {
      await _dataService.exportData(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.dataBackupSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.dataBackupFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _import() async {
    setState(() => _loading = true);
    try {
      final result = await _dataService.importData();
      if (!mounted) return;
      if (result.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.dataRestoreFailed(result.error!)),
            backgroundColor: Colors.red,
          ),
        );
      } else if (result.imported > 0) {
        context.read<HomeBloc>().add(HomeStarted());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.dataRestoreSuccess(result.imported)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.dataRestoreFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: BlurAppBar(
        title: Text(l10n.dataTitle),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Text(
                        l10n.dataBackupSection,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.backup_outlined),
                      title: Text(l10n.dataBackupTitle),
                      subtitle: Text(l10n.dataBackupSubtitle),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: _export,
                    ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Text(
                        l10n.dataRestoreSection,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.restore_outlined),
                      title: Text(l10n.dataRestoreTitle),
                      subtitle: Text(l10n.dataRestoreSubtitle),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: _import,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        l10n.dataRestoreNote,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
