import 'package:expense_management/widget/custom_header_1.dart';
import 'package:flutter/material.dart';
import '../../../utils/previous_period.dart';
import '../../../utils/utils.dart';
import '../../../view_model/budget/detail_budget_view_model.dart';
import 'package:easy_localization/easy_localization.dart';

class PreviousPeriodDetailsScreen extends StatefulWidget {
  final PreviousPeriod period;
  final DetailBudgetViewModel viewModel;

  const PreviousPeriodDetailsScreen({super.key, required this.period, required this.viewModel});

  @override
  _PreviousPeriodDetailsScreenState createState() =>
      _PreviousPeriodDetailsScreenState();
}

class _PreviousPeriodDetailsScreenState
    extends State<PreviousPeriodDetailsScreen> {
  bool _showTransactions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomHeader_1(title: tr('previous_period_details')),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    tr('expired'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    tr('time_period'),
                  ),
                  trailing: Text(
                      isSameDate(widget.period.startDate, widget.period.endDate)
                          ? formatDate_2(widget.period.startDate)
                          : '${formatDate_2(widget.period.startDate)} - ${formatDate_2(widget.period.endDate)}',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                ListTile(
                  title: Text(tr('budget_limit')),
                  trailing: Text(
                    '${formatAmount(widget.viewModel.budget.amount)} ₫',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ListTile(
                  title: Text(tr('total_expenditure')),
                  trailing: Text(
                    '${formatAmount(widget.period.totalExpenditure)} ₫',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: widget.period.totalExpenditure >
                              widget.viewModel.budget.amount
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(widget.period.isOverBudget
                      ? tr('overspent')
                      : tr('remaining_budget')),
                  trailing: Text(
                    '${formatAmount(widget.period.remainingBudget.abs())} ₫',
                    style: TextStyle(
                      color: widget.period.isOverBudget
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 20.0),
                  child: LinearProgressIndicator(
                    value: widget.period.totalExpenditure /
                        widget.viewModel.budget.amount,
                    color:
                        widget.period.isOverBudget ? Colors.red : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          if (widget.period.transactions.isNotEmpty)
            ListTile(
              title: Text(tr('transaction_details'),
                  style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: _showTransactions
                  ? const Icon(Icons.arrow_drop_down)
                  : const Icon(Icons.arrow_drop_up),
              onTap: () {
                setState(() {
                  _showTransactions = !_showTransactions;
                });
              },
            ),
          if (_showTransactions && widget.period.transactions.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView.builder(
                  itemCount: widget.period.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = widget.period.transactions[index];
                    final category =
                        widget.viewModel.categoryMap[transaction.categoryId];
                    final wallet =
                        widget.viewModel.walletMap[transaction.walletId];
                    final formattedDate = formatDate_2(transaction.date);

                    // Kiểm tra xem phần tử trước đó có cùng ngày với phần tử hiện tại không
                    final bool isFirstItemOfDay = index == 0 ||
                        formattedDate !=
                            formatDate_2(
                                widget.period.transactions[index - 1].date);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isFirstItemOfDay) // Hiển thị ngày nếu là giao dịch đầu tiên của ngày
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        Card(
                          color: Colors.grey[300],
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: category != null
                                  ? parseColor(category.color)
                                  : Colors.grey,
                              child: category != null
                                  ? Icon(parseIcon(category.icon),
                                      color: Colors.white)
                                  : const Icon(Icons.category, color: Colors.white),
                            ),
                            title: Text(category != null
                                ? category.name
                                : tr('no_category')),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (wallet != null) Text('(${wallet.name})'),
                                Text(formatHour(transaction.hour)),
                              ],
                            ),
                            trailing: Text(
                              '${formatAmount_2(transaction.amount)} ₫',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
