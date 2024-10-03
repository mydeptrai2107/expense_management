import 'package:expense_management/model/transfer_model.dart';
import 'package:expense_management/model/wallet_model.dart';
import 'package:expense_management/utils/utils.dart';
import 'package:expense_management/view/transfer/create_transfer_screen.dart';
import 'package:expense_management/widget/custom_snackbar_1.dart';
import 'package:expense_management/widget/custom_snackbar_2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../view_model/wallet/wallet_view_model.dart';
import '../../widget/custom_header_3.dart';
import '../transfer/transfer_history_screen.dart';
import 'create_wallet_screen.dart';
import 'edit_wallet_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WalletViewModel(),
      child: Consumer<WalletViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Column(
              children: [
                CustomHeader_3(
                  title: tr('utility_wallet'),
                  action: GestureDetector(
                    onTap: () {
                      setState(() {
                        viewModel.isSearching = true;
                      });
                    },
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                  isSearching: viewModel.isSearching,
                  onSearchChanged: (query) {
                    setState(() {
                      viewModel.searchQuery = query;
                      viewModel.filterWallets(query);
                    });
                  },
                  onSearchClose: () {
                    setState(() {
                      viewModel.isSearching = false;
                      viewModel.clearSearch();
                    });
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Text(
                        tr('total'),
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${viewModel.formattedTotalBalance} ₫',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const TransferHistoryScreen())).then((_) {
                          // Cập nhật ví khi quay lại từ màn hình lịch sử chuyển khoản
                          final walletViewModel = Provider.of<WalletViewModel>(
                              context,
                              listen: false);
                          walletViewModel.loadWallets();
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.green,
                            ),
                            child: const Icon(FontAwesomeIcons.clockRotateLeft,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 5),
                           Text(
                            tr('transfer_history'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final newTransfer = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateTransferScreen(),
                          ),
                        );
                        if (newTransfer != null && newTransfer is Transfer) {
                          await viewModel.loadWallets();
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.green,
                            ),
                            child: const Icon(FontAwesomeIcons.rightLeft,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            tr('new_transfer'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: viewModel.wallets.isEmpty && viewModel.isSearching
                      ? Center(
                          child: Text(
                            tr('no_search_results'),
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: viewModel.wallets.length,
                          itemBuilder: (context, index) {
                            final wallet = viewModel.wallets[index];
                            return Dismissible(
                              key: Key(wallet.walletId),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                if (wallet.isDefault) {
                                  CustomSnackBar_1.show(
                                      context, tr('cant_delete_default_wallet'));
                                  return false;
                                }
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title:  Text(tr('attention')),
                                      content: RichText(
                                        text: TextSpan(
                                            text: tr('delete_wallet_warning_part1'),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16),
                                            children: [
                                              TextSpan(
                                                text: tr('delete_wallet_warning_highlight'),
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              TextSpan(
                                                text: tr('delete_wallet_warning_part2'),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        16),
                                              ),
                                            ]),
                                      ),
                                      actions: [
                                        TextButton(
                                          child:  Text(tr('no'),
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 18)),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(false);
                                          },
                                        ),
                                        TextButton(
                                          child: Text(tr('yes'),
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 18)),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(true);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              onDismissed: (direction) async {
                                await viewModel.deleteWallet(wallet.walletId);
                                CustomSnackBar_2.show(
                                    context, '${wallet.name}' + tr('deleted'));
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              child: Card(
                                color: Colors.grey.shade200,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 4.0),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: parseColor(wallet.color),
                                    child: Icon(
                                      parseIcon(wallet.icon),
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  title: Text(
                                    wallet.name,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${formatAmount(wallet.currentBalance)} đ',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  trailing: wallet.excludeFromTotal
                                      ? const Icon(Icons.remove_circle,
                                          color: Colors.red)
                                      : null,
                                  onTap: () async {
                                    final updatedWallet = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditWalletScreen(wallet: wallet),
                                      ),
                                    );
                                    if (updatedWallet != null &&
                                        updatedWallet is Wallet) {
                                      await viewModel.loadWallets();
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final newWallet = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateWalletScreen(),
                  ),
                );
                if (newWallet != null && newWallet is Wallet) {
                  await viewModel.loadWallets();
                }
              },
              backgroundColor: Colors.green,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
