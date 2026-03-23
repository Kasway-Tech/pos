import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kasway/app/helpers/format_helpers.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/network/network_cubit.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';
import 'package:kasway/app/widgets/explorer_page.dart';
import 'package:kasway/data/models/withdrawal.dart';
import 'package:kasway/data/repositories/withdrawal_repository.dart';

class WithdrawalHistoryPage extends StatefulWidget {
  const WithdrawalHistoryPage({super.key});

  @override
  State<WithdrawalHistoryPage> createState() => _WithdrawalHistoryPageState();
}

class _WithdrawalHistoryPageState extends State<WithdrawalHistoryPage> {
  late final Future<List<Withdrawal>> _withdrawalsFuture;
  final _dateFormat = DateFormat('d MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    final network = context.read<NetworkCubit>().state.network.name;
    _withdrawalsFuture = context.read<WithdrawalRepository>().getWithdrawals(
      network,
    );
  }

  @override
  Widget build(BuildContext context) {
    final kasSymbol = context.watch<NetworkCubit>().state.kasSymbol;
    return Scaffold(
      appBar: BlurAppBar(
        title: Text(context.l10n.withdrawalHistoryTitle),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Withdrawal>>(
        future: _withdrawalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final withdrawals = snapshot.data ?? [];
          if (withdrawals.isEmpty) {
            return Center(
              child: Text(context.l10n.withdrawalHistoryNoWithdrawals),
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView.builder(
                itemCount: withdrawals.length,
                itemBuilder: (context, index) {
                  final w = withdrawals[index];
                  return ListTile(
                    title: Text('$kasSymbol ${w.amountKas.toStringAsFixed(4)}'),
                    subtitle: Text(
                      '${truncateAddress(w.toAddress)}  •  ${_dateFormat.format(w.createdAt.toLocal())}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy_outlined),
                          tooltip: context.l10n.withdrawalHistoryCopyTxId,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: w.txId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.l10n.withdrawalHistoryTxIdCopied,
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_browser_outlined),
                          tooltip: context.l10n.withdrawalHistoryViewOnExplorer,
                          onPressed: () {
                            final url =
                                '${context.read<NetworkCubit>().state.explorerBaseUrl}${w.txId}';
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ExplorerPage(url: url),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
