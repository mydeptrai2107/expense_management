import 'package:expense_management/utils/utils.dart';
import 'package:expense_management/widget/custom_header_2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../model/category_model.dart';
import '../../model/enum.dart';
import '../../model/transaction_model.dart';
import '../../model/wallet_model.dart';
import '../../view_model/statistics/statistics_view_model.dart';
import '../../widget/multi_wallet_selection_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatisticsViewModel(),
      child: Consumer<StatisticsViewModel>(
        builder: (context, viewModel, child) {
          return DefaultTabController(
            length: 5,
            initialIndex: 3,
            child: Builder(
              builder: (context) {
                viewModel.setTabController(DefaultTabController.of(context));
                return Scaffold(
                  body: Column(
                    children: [
                      CustomHeader_2(
                        title: tr('statistics'),
                        rightAction: IconButton(
                          icon: const Icon(FontAwesomeIcons.sackDollar,
                              color: Colors.white),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return MultiWalletSelectionDialog(
                                  wallets: viewModel.wallets,
                                  selectedWallets: viewModel.selectedWallets,
                                  onSelect: (List<Wallet> selectedWallets) {
                                    viewModel.setWallets(selectedWallets);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TabBar(
                                labelColor: Colors.green,
                                unselectedLabelColor: Colors.grey,
                                tabs: [
                                  Tab(text: tr('day')),
                                  Tab(text: tr('week')),
                                  Tab(text: tr('month')),
                                  Tab(text: tr('year')),
                                  Tab(text: tr('custom')),
                                ],
                                onTap: (int index) {
                                  switch (index) {
                                    case 0:
                                      viewModel.setTimeframe('day');
                                      break;
                                    case 1:
                                      viewModel.setTimeframe('week');
                                      break;
                                    case 2:
                                      viewModel.setTimeframe('month');
                                      break;
                                    case 3:
                                      viewModel.setTimeframe('year');
                                      break;
                                    case 4:
                                      showCustomDateRangePicker(
                                          context, viewModel);
                                      break;
                                  }
                                },
                              ),
                              Expanded(
                                child: TabBarView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    StatisticsChart(viewModel: viewModel),
                                    StatisticsChart(viewModel: viewModel),
                                    StatisticsChart(viewModel: viewModel),
                                    StatisticsChart(viewModel: viewModel),
                                    StatisticsChart(viewModel: viewModel),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: viewModel.selectedIncomeTransactions.isNotEmpty
                            ? TransactionList(
                                title:
                                    '${tr('time')}${viewModel.currentIncomeDateKey}',
                                transactions:
                                    viewModel.selectedIncomeTransactions,
                                categoryMap: viewModel.categoryMap,
                                walletMap: viewModel.walletMap,
                                totalAmount: viewModel.currentIncomeTotal,
                                type: Type.income,
                              )
                            : viewModel.selectedExpenseTransactions.isNotEmpty
                                ? TransactionList(
                                    title:
                                        '${tr('time')}${viewModel.currentExpenseDateKey}',
                                    transactions:
                                        viewModel.selectedExpenseTransactions,
                                    categoryMap: viewModel.categoryMap,
                                    walletMap: viewModel.walletMap,
                                    totalAmount: viewModel.currentExpenseTotal,
                                    type: Type.expense,
                                  )
                                : Text(''),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void showCustomDateRangePicker(
      BuildContext context, StatisticsViewModel viewModel) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: viewModel.customStartDate ??
            DateTime.now().subtract(const Duration(days: 7)),
        end: viewModel.customEndDate ?? DateTime.now(),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      viewModel.setCustomDateRange(picked.start, picked.end);
      viewModel.setTimeframe('custom');
    }
  }
}

class StatisticsChart extends StatelessWidget {
  final StatisticsViewModel viewModel;

  const StatisticsChart({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(),
              primaryYAxis: NumericAxis(
                axisLabelFormatter: (AxisLabelRenderDetails details) {
                  final double value = details.value.toDouble();
                  final formattedValue = formatAmount_2(value);
                  return ChartAxisLabel(
                      '$formattedValue đ', const TextStyle(color: Colors.black));
                },
              ),
              title: const ChartTitle(text: ''),
              legend: const Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                builder: (dynamic data, dynamic point, dynamic series,
                    int pointIndex, int seriesIndex) {
                  final double value = point.y;
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${formatAmount(value)} ₫',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
              series: <CartesianSeries>[
                ColumnSeries<ChartData, String>(
                  dataSource: viewModel.incomeData,
                  xValueMapper: (ChartData data, _) => data.date,
                  yValueMapper: (ChartData data, _) => data.amount,
                  name: tr('income'),
                  color: Colors.green,
                  enableTooltip: true,
                  onPointTap: (ChartPointDetails details) {
                    final int pointIndex = details.pointIndex!;
                    final data = viewModel.incomeData[pointIndex];
                    viewModel.setSelectedTransactions(Type.income, data.date);
                  },
                ),
                ColumnSeries<ChartData, String>(
                  dataSource: viewModel.expenseData,
                  xValueMapper: (ChartData data, _) => data.date,
                  yValueMapper: (ChartData data, _) => data.amount,
                  name: tr('expense'),
                  color: Colors.red,
                  enableTooltip: true,
                  onPointTap: (ChartPointDetails details) {
                    final int pointIndex = details.pointIndex!;
                    final data = viewModel.expenseData[pointIndex];
                    viewModel.setSelectedTransactions(Type.expense, data.date);
                  },
                ),
                ColumnSeries<ChartData, String>(
                  dataSource: viewModel.profitData,
                  xValueMapper: (ChartData data, _) => data.date,
                  yValueMapper: (ChartData data, _) => data.amount,
                  name: tr('profit'),
                  color: Colors.blue,
                  enableTooltip: true,
                  onPointTap: (ChartPointDetails details) {
                    viewModel.clearTransactions('profit');
                  },
                ),
                ColumnSeries<ChartData, String>(
                  dataSource: viewModel.lossData,
                  xValueMapper: (ChartData data, _) => data.date,
                  yValueMapper: (ChartData data, _) => data.amount,
                  name: tr('loss'),
                  color: Colors.orange,
                  enableTooltip: true,
                  onPointTap: (ChartPointDetails details) {
                    viewModel.clearTransactions('loss');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionList extends StatefulWidget {
  final String title;
  final List<Transactions> transactions;
  final Map<String, Category> categoryMap;
  final Map<String, Wallet> walletMap;
  final double totalAmount;
  final Type type;

  const TransactionList({super.key,
    required this.title,
    required this.transactions,
    required this.categoryMap,
    required this.walletMap,
    required this.totalAmount,
    required this.type,
  });

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.type == Type.income
                ? tr('total_income', namedArgs: {
                    'amount': formatAmount(widget.totalAmount)
                  })
                : tr('total_expense', namedArgs: {
                    'amount': formatAmount(widget.totalAmount)
                  }),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.type == Type.income ? Colors.green : Colors.red,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.transactions.length,
              itemBuilder: (context, index) {
                final transaction = widget.transactions[index];
                final category = widget.categoryMap[transaction.categoryId];
                final wallet = widget.walletMap[transaction.walletId];
                final double transactionAmount = transaction.amount;
                final double transactionPercentage =
                    (transactionAmount / widget.totalAmount) * 100;

                if (category == null) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.category, color: Colors.white),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('no_category'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        // SizedBox(height: 3),
                        // Text(
                        //   wallet!.name,
                        //   maxLines: 1,
                        //   overflow: TextOverflow.ellipsis,
                        //   style: TextStyle(color: Colors.grey, fontSize: 16),
                        // ),
                      ],
                    ),
                    subtitle: LinearProgressIndicator(
                      value: transactionPercentage,
                      backgroundColor: Colors.grey[300],
                      color: transaction.type == Type.income
                          ? Colors.green
                          : Colors.red,
                    ),
                    trailing: Column(
                      children: [
                        Text(
                          '${formatAmount(transaction.amount)} đ',
                          style: TextStyle(
                              fontSize: 16,
                              color: transaction.type == Type.income
                                  ? Colors.green
                                  : Colors.red),
                        ),
                        Text(
                          '${transactionPercentage.toStringAsFixed(2)}%',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: parseColor(category.color),
                    child: Icon(parseIcon(category.icon), color: Colors.white),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // SizedBox(height: 3),
                      // Text(
                      //   wallet!.name,
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: TextStyle(color: Colors.grey, fontSize: 16),
                      // ),
                    ],
                  ),
                  subtitle: LinearProgressIndicator(
                    value: transactionPercentage / 10,
                    backgroundColor: Colors.grey[300],
                    color: transaction.type == Type.income
                        ? Colors.green
                        : Colors.red,
                  ),

                  trailing: Column(
                    children: [
                      Text(
                        '${formatAmount_2(transaction.amount)} đ',
                        style: TextStyle(
                            fontSize: 16,
                            color: transaction.type == Type.income
                                ? Colors.green
                                : Colors.red),
                      ),
                      Text(
                        '${transactionPercentage.toStringAsFixed(2)}%',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
