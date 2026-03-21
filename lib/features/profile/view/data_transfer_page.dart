import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          const SnackBar(content: Text('Backup saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
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
            content: Text('Restore failed: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (result.imported > 0) {
        context.read<HomeBloc>().add(HomeStarted());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.imported} items restored successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
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
    return Scaffold(
      appBar: BlurAppBar(
        title: const Text('Backup & Restore'),
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
                        'Backup',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.backup_outlined),
                      title: const Text('Back Up Catalog'),
                      subtitle: const Text(
                        'Save all your items and categories to a CSV file',
                      ),
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
                        'Restore',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.restore_outlined),
                      title: const Text('Restore from Backup'),
                      subtitle: const Text(
                        'Load items from a previously saved CSV file',
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: _import,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        'Note: Items with the same ID in the backup will overwrite existing ones.',
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
