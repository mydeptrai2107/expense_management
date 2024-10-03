import 'package:easy_localization/easy_localization.dart';
import 'package:expense_management/view/budget/edit_budget_screen.dart';
import 'package:expense_management/widget/custom_header_1.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../model/budget_model.dart';
import '../../model/enum.dart';
import '../../model/transaction_model.dart';
import '../../utils/previous_period.dart';
import '../../utils/utils.dart';
import '../../view_model/budget/detail_budget_view_model.dart';
import 'component/previous_period_details_screen.dart';

class DetailBudgetScreen extends StatefulWidget {
  final Budget budget;

  const DetailBudgetScreen({super.key, required this.budget});

  @override
  State<DetailBudgetScreen> createState() => _DetailBudgetScreenState();
}

class _DetailBudgetScreenState extends State<DetailBudgetScreen> {
  final GlobalKey _toolTipKey1 = GlobalKey();
  final GlobalKey _toolTipKey2 = GlobalKey();
  final GlobalKey _toolTipKey3 = GlobalKey();

  void _showToolTip(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    tooltip.ensureTooltipVisible();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetailBudgetViewModel(widget.budget),
      child: Consumer<DetailBudgetViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Column(
              children: [
                CustomHeader_1(
                  title: tr('detail_budget_title'),
                  action: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditBudgetScreen(budget: widget.budget),
                        ),
                      );
                      if (result != null) {
                        Navigator.pop(context, result);
                      }
                    },
                  ),
                ),
                if (viewModel.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(12.0),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(tr('budget_name'),
                                    style: TextStyle(fontSize: 16))),
                            Flexible(
                              child: Text(
                                widget.budget.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(tr('budget_limit'),
                                    style: TextStyle(fontSize: 16))),
                            Text(
                              '${formatAmount(widget.budget.amount)} ₫',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(tr('total_expenditure'),
                                    style: TextStyle(fontSize: 16))),
                            Text(
                              '${formatAmount(viewModel.totalExpenditure)} ₫',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                viewModel.totalExpenditure >
                                        widget.budget.amount
                                    ? tr('over_budget')
                                    : tr('remaining_budget'),
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Text(
                              '${formatAmount((widget.budget.amount - viewModel.totalExpenditure).abs())} ₫',
                              style: TextStyle(
                                color: viewModel.totalExpenditure >
                                        widget.budget.amount
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 5.0),
                          child: LinearProgressIndicator(
                            value: viewModel.totalExpenditure /
                                widget.budget.amount,
                            color: viewModel.totalExpenditure >
                                    widget.budget.amount
                                ? Colors.red
                                : Colors.blue,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(tr('time_period'),
                                    style: TextStyle(fontSize: 16))),
                            viewModel.isExpired
                                ? Text(
                                    tr('expired'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  )
                                : viewModel.budget.repeat == Repeat.Daily
                                    ? Text(
                                        formatDate_2(
                                            viewModel.currentPeriodStart),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      )
                                    : Text(
                                        '${formatDate_2(viewModel.currentPeriodStart)} - ${formatDate_2(viewModel.currentPeriodEnd)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                          ],
                        ),
                        SizedBox(height: 10),
                        if (viewModel.budget.repeat != Repeat.Daily &&
                            viewModel.isExpired != true &&
                            !isSameDate(
                                viewModel.currentPeriodEnd, DateTime.now()))
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Text(tr('remaining_days'),
                                        style: TextStyle(fontSize: 16))),
                                Text(
                                  '${viewModel.remainingDays}' + tr('day_2'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                        SizedBox(height: 10),
                        const Divider(),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _showToolTip(_toolTipKey1),
                          child: Tooltip(
                            key: _toolTipKey1,
                            message: tr('actual_spending_tooltip'),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            preferBelow: false,
                            // Đặt tooltip ở phía trên nếu có thể
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(tr('actual_spending'),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                      SizedBox(width: 5),
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                          FontAwesomeIcons.question,
                                          color: Colors.white,
                                          size: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${formatAmount(viewModel.actualSpending)}' +
                                      tr('₫_day'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _showToolTip(_toolTipKey2),
                          child: Tooltip(
                            key: _toolTipKey2,
                            message: tr('recommended_spending_tooltip'),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            preferBelow: false,
                            // Đặt tooltip ở phía trên nếu có thể
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(tr('recommended_spending'),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                      SizedBox(width: 5),
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                          FontAwesomeIcons.question,
                                          color: Colors.white,
                                          size: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${formatAmount(viewModel.recommendedSpending)}' +
                                      tr('₫_day'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _showToolTip(_toolTipKey3),
                          child: Tooltip(
                            key: _toolTipKey3,
                            message: tr('projected_spending_tooltip'),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            preferBelow: false,
                            // Đặt tooltip ở phía trên nếu có thể
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(tr('projected_spending'),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                      SizedBox(width: 5),
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                          FontAwesomeIcons.question,
                                          color: Colors.white,
                                          size: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${formatAmount(viewModel.projectedSpending)} ₫',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: viewModel.projectedSpending >
                                            viewModel.budget.amount
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        const Divider(),
                        SizedBox(height: 10),
                        if (viewModel.previousPeriods.isNotEmpty)
                          GestureDetector(
                            onTap: () => viewModel.toggleShowPreviousPeriods(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(tr('previous_periods'), style: TextStyle(fontSize: 16),)),
                                Icon(viewModel.showPreviousPeriods
                                    ? Icons.arrow_drop_down
                                    : Icons.arrow_drop_up),
                              ],
                            ),
                          ),
                        if (viewModel.showPreviousPeriods)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, bottom: 8.0),
                            child: Column(
                              children: viewModel.previousPeriods.map((period) {
                                return GestureDetector(
                                  onTap: () => _showPreviousPeriodDetails(
                                      context, period, viewModel),
                                  child: Card(
                                    color: Colors.grey[300],
                                    child: ListTile(
                                      title: Center(
                                        child: Text(
                                          isSameDate(period.startDate,
                                                  period.endDate)
                                              ? formatDate_2(period.startDate)
                                              : '${formatDate_2(period.startDate)} - ${formatDate_2(period.endDate)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        SizedBox(height: 10),
                        if (viewModel.filteredTransactions.isNotEmpty)
                          GestureDetector(
                            onTap: () => viewModel.toggleShowTransactions(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(tr('transaction_details'), style: TextStyle(fontSize: 16),)),
                                Icon(viewModel.showTransactions
                                    ? Icons.arrow_drop_down
                                    : Icons.arrow_drop_up),
                              ],
                            ),
                          ),

                        // Chi tiết giao dịch chi tiêu
                        if (viewModel.showTransactions)
                          ...viewModel.groupedTransactions.entries.map((entry) {
                            String date = entry.key;
                            List<Transactions> transactions = entry.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(date,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                                ...transactions.map((transaction) {
                                  final category = viewModel
                                      .categoryMap[transaction.categoryId];
                                  final wallet =
                                      viewModel.walletMap[transaction.walletId];
                                  return Card(
                                    color: Colors.grey[300],
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: category != null
                                            ? parseColor(category.color)
                                            : Colors.grey,
                                        child: category != null
                                            ? Icon(parseIcon(category.icon),
                                                color: Colors.white)
                                            : const Icon(Icons.category,
                                                color: Colors.white),
                                      ),
                                      title: Text(category != null
                                          ? category.name
                                          : tr('no_category')),
                                      subtitle: Text(
                                          '(${wallet?.name})\n${formatHour(transaction.hour)}'),
                                      trailing: Text(
                                        '${formatAmount_2(transaction.amount)} ₫',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          }),
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

  void _showPreviousPeriodDetails(BuildContext context, PreviousPeriod period,
      DetailBudgetViewModel viewModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviousPeriodDetailsScreen(
          period: period,
          viewModel: viewModel,
        ),
      ),
    );
  }
}
