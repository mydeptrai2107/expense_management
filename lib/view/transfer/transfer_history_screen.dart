import 'package:expense_management/widget/custom_ElevatedButton_2.dart';
import 'package:expense_management/widget/custom_header_1.dart';
import 'package:expense_management/widget/custom_snackbar_2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../model/transfer_model.dart';
import '../../model/wallet_model.dart';
import '../../utils/utils.dart';
import '../../view_model/transfer/transfer_history_view_model.dart';
import '../../widget/multi_wallet_selection_dialog.dart';
import 'edit_transfer_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class TransferHistoryScreen extends StatefulWidget {
  const TransferHistoryScreen({super.key});

  @override
  _TransferHistoryScreenState createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends State<TransferHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransferHistoryViewModel(),
      child: Scaffold(
        drawer: _buildFilterDrawer(context),
        body: Column(
          children: [
            CustomHeader_1(
              title: tr('history_label'),
              action: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            ),
            Expanded(
              child: Consumer<TransferHistoryViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (viewModel.transfers.isEmpty) {
                    return Center(
                      child: Text(tr('no_transaction'), style: TextStyle(fontSize: 18)),
                    );
                  }
                  if (viewModel.groupedTransfers.isEmpty) {
                    return Center(
                      child: Text(tr('no_results'), style: TextStyle(fontSize: 18)),
                    );
                  }
                  return ListView.builder(
                    itemCount: viewModel.groupedTransfers.length,
                    itemBuilder: (context, index) {
                      String date =
                          viewModel.groupedTransfers.keys.elementAt(index);
                      List<Transfer> transfers =
                          viewModel.groupedTransfers[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              date,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...transfers.map((transfer) {
                            final fromWallet =
                                viewModel.getFromWalletByTransfer(transfer);
                            final toWallet =
                                viewModel.getToWalletByTransfer(transfer);

                            String fromWalletName = tr('no_source_wallet');
                            IconData fromWalletIcon = Icons.wallet;
                            Color fromWalletColor = Colors.grey;
                            if (fromWallet != null) {
                              fromWalletName = fromWallet.name;
                              fromWalletIcon = parseIcon(fromWallet.icon);
                              fromWalletColor = parseColor(fromWallet.color);
                            }

                            String toWalletName = tr('no_destination_wallet');
                            IconData toWalletIcon = Icons.wallet;
                            Color toWalletColor = Colors.grey;
                            if (toWallet != null) {
                              toWalletName = toWallet.name;
                              toWalletIcon = parseIcon(toWallet.icon);
                              toWalletColor = parseColor(toWallet.color);
                            }

                            final formattedAmount =
                                formatAmount_2(transfer.amount);
                            final formattedTime =
                                viewModel.formatHour(transfer.hour);

                            return Dismissible(
                              key: Key(transfer.transferId),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) async {
                                await viewModel.deleteTransfer(
                                    context, transfer.transferId);
                                CustomSnackBar_2.show(
                                  context,
                                  tr('deleted_transaction'),
                                );
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              child: Card(
                                color: Colors.grey.shade200,
                                child: ListTile(
                                  leading:
                                      const Icon(
                                        FontAwesomeIcons.downLong,
                                        color: Colors.green,
                                      ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: fromWalletColor,
                                            child: Icon(
                                              fromWalletIcon,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              fromWalletName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: toWalletColor,
                                            child: Icon(
                                              toWalletIcon,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              toWalletName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(formattedTime),
                                  ),
                                  trailing: Text('$formattedAmount ₫',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                  onTap: () async {
                                    final updatedTransfer =
                                        await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditTransferScreen(
                                                transfer: transfer),
                                      ),
                                    );
                                    if (updatedTransfer != null &&
                                        updatedTransfer is Transfer) {
                                      await viewModel.loadTransfers();
                                    }
                                  },
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDrawer(BuildContext context) {
    return Consumer<TransferHistoryViewModel>(
      builder: (context, viewModel, child) {
        return Drawer(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                 Text(
                  tr('search_filters'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Divider(),
                ListTile(
                  title:  Text(tr('date_range')),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDateRange: viewModel.selectedDateRange,
                    );
                    if (picked != null) {
                      viewModel.filterByDateRange(picked);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                ListTile(
                  title: Text(tr('wallet')),
                  trailing: const Icon(Icons.account_balance_wallet),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return MultiWalletSelectionDialog(
                          wallets: viewModel.walletMap.values.toList(),
                          selectedWallets: viewModel.selectedWallets,
                          onSelect: (List<Wallet> selectedWallets) {
                            viewModel.filterByWallets(selectedWallets);
                          },
                        );
                      },
                    );
                  },
                ),
                CustomElevatedButton_2(
                  text: tr('clear_filters'),
                  onPressed: () {
                    viewModel.clearFilters();
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
