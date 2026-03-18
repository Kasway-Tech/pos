import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/data/repositories/product_repository.dart';
import 'package:kasway/data/services/data_service.dart';
import 'package:kasway/features/home/bloc/home_bloc.dart';
import 'package:kasway/features/home/bloc/home_event.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

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
    _dataService = DataService(ProductRepository());
  }

  Future<void> _export() async {
    setState(() => _loading = true);
    try {
      await _dataService.exportData(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catalog exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
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
            content: Text('Import failed: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (result.imported > 0) {
        context.read<HomeBloc>().add(HomeStarted());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.imported} items imported successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
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
    return TitlebarSafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Data Transfer'), centerTitle: true),
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
                            horizontal: 16.0, vertical: 4.0),
                        child: Text(
                          'Export',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.upload_file),
                        title: const Text('Export Catalog'),
                        subtitle:
                            const Text('Save all items to a CSV file'),
                        trailing:
                            const Icon(Icons.chevron_right, size: 20),
                        onTap: _export,
                      ),
                      const SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4.0),
                        child: Text(
                          'Import',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.download),
                        title: const Text('Import Catalog'),
                        subtitle:
                            const Text('Restore items from a CSV file'),
                        trailing:
                            const Icon(Icons.chevron_right, size: 20),
                        onTap: _import,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          'Note: Existing items with the same ID will be overwritten.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
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
