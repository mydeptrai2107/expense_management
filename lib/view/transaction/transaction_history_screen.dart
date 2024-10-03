import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/enum.dart';
import '../../model/transaction_model.dart';
import '../../model/wallet_model.dart';
import '../../utils/utils.dart';
import '../../view_model/transaction/transaction_history_view_model.dart';
import '../../view_model/wallet/wallet_view_model.dart';
import '../../widget/custom_ElevatedButton_2.dart';
import '../../widget/custom_header_5.dart';
import '../../widget/custom_snackbar_2.dart';
import '../../widget/multi_wallet_selection_dialog.dart';
import 'edit_transaction_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionHistoryViewModel(),
      child: Consumer<TransactionHistoryViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            endDrawer: _buildFilterDrawer(context, viewModel),
            body: Column(
              children: [
                CustomHeader_5(
                  title: tr('transaction_history'),
                  filterAction: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ),
                  searchAction: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        viewModel.isSearching = true;
                      });
                    },
                  ),
                  isSearching: viewModel.isSearching,
                  onSearchChanged: (query) {
                    viewModel.searchTransactions(query);
                  },
                  onSearchClose: () {
                    viewModel.isSearching = false;
                    viewModel.clearSearch();
                  },
                ),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: tr('all')),
                    Tab(text: tr('income')),
                    Tab(text: tr('expense')),
                  ],
                  onTap: (index) {
                    viewModel.filterByTab(index);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildTotals(viewModel),
                ),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      _buildTransactionList(viewModel),
                      _buildTransactionList(viewModel),
                      _buildTransactionList(viewModel),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotals(TransactionHistoryViewModel viewModel) {
    if (_tabController.index == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset('assets/images/income.png'),
                SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: Text(
                      tr('total_income', namedArgs: {
                        'amount': viewModel.formatAmount(viewModel.totalIncome)
                      }),
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset('assets/images/expense.png'),
                SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    tr('total_expense', namedArgs: {
                      'amount': viewModel.formatAmount(viewModel.totalExpense)
                    }),
                    style: const TextStyle(
                        color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_tabController.index == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/income.png'),
          SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: Text(
                tr('total_income', namedArgs: {
                  'amount': viewModel.formatAmount(viewModel.totalIncome)
                }),
                style: const TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      );
    } else if (_tabController.index == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/expense.png'),
          SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              tr('total_expense', namedArgs: {
                'amount': viewModel.formatAmount(viewModel.totalExpense)
              }),
              style: const TextStyle(
                  color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget _buildTransactionList(TransactionHistoryViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.filteredTransactions.isEmpty) {
      return Center(
        child: Text(tr('no_transaction'), style: TextStyle(fontSize: 18)),
      );
    }
    return ListView.builder(
      itemCount: viewModel.groupedTransactions.length,
      itemBuilder: (context, index) {
        if (index >= viewModel.groupedTransactions.length) {
          return const SizedBox(); // Trả về widget trống nếu chỉ số vượt quá giới hạn
        }
        String date = viewModel.groupedTransactions.keys.elementAt(index);
        List<Transactions> transactions = viewModel.groupedTransactions[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                date,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...transactions.map((transaction) {
              final wallet = viewModel.getWalletByTransaction(transaction);
              final category = viewModel.getCategoryByTransaction(transaction);

              String walletName = tr('no_wallet');

              if (wallet != null) {
                walletName = wallet.name;
              }

              String categoryName = tr('no_category');
              IconData categoryIcon = Icons.category;
              Color categoryColor = Colors.grey;

              if (category != null) {
                categoryName = category.name;
                categoryIcon = parseIcon(category.icon);
                categoryColor = parseColor(category.color);
              }

              final formattedTime = formatHour(transaction.hour);
              // final note = transaction.note;

              return Dismissible(
                key: Key(transaction.transactionId),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  final walletViewModel =
                      Provider.of<WalletViewModel>(context, listen: false);
                  await viewModel.deleteTransaction(
                      transaction.transactionId, walletViewModel);
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
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: categoryColor,
                      child: Icon(
                        categoryIcon,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '($walletName)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // if (note.isNotEmpty)
                        //   Padding(
                        //     padding: const EdgeInsets.only(top: 4.0),
                        //     child: Text(
                        //       note,
                        //       style: const TextStyle(
                        //         color: Colors.grey,
                        //         fontSize: 15,
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Text(formattedTime),
                        if (transaction.images.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.image,
                                size: 16, color: Colors.grey[700]),
                          ),
                      ],
                    ),
                    trailing: Text(
                      '${formatAmount_2(transaction.amount)} đ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: transaction.type == Type.income
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditTransactionScreen(transaction: transaction),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          viewModel.loadTransactions();
                        });
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
  }

  Widget _buildFilterDrawer(
      BuildContext context, TransactionHistoryViewModel viewModel) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Text(
              tr('search_filters'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            ListTile(
              title: Text(tr('date_range')),
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
            ),
          ],
        ),
      ),
    );
  }
}
