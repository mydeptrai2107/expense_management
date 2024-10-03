import 'package:easy_localization/easy_localization.dart';
import 'package:expense_management/utils/utils.dart';
import 'package:expense_management/view/budget/create_budget_screen.dart';
import 'package:expense_management/widget/custom_snackbar_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/budget_model.dart';
import '../../model/category_model.dart';
import '../../model/wallet_model.dart';
import '../../view_model/budget/budget_list_view_model.dart';
import '../../widget/custom_header_3.dart';
import 'detail_budget_screen.dart';

class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({super.key});

  @override
  State<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BudgetListViewModel(),
      child: Consumer<BudgetListViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.grey[350],
            body: Column(
              children: [
                CustomHeader_3(
                  title: tr('budget_list'),
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
                      viewModel.filterBudgets(query);
                    });
                  },
                  onSearchClose: () {
                    setState(() {
                      viewModel.isSearching = false;
                      viewModel.searchQuery = '';
                      viewModel.searchController.clear();
                      viewModel.filterBudgets('');
                    });
                  },
                ),

                Expanded(
                  child: viewModel.isLoading
                      ? Center(
                    child: CircularProgressIndicator(),
                  )
                      : viewModel.budgets.isEmpty
                      ? Center(
                    child: Text(
                      viewModel.isSearching
                          ? tr('no_search_results')
                          : tr('no_budgets'),
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                      : ListView.builder(
                    itemCount: viewModel.budgets.length,
                    itemBuilder: (context, index) {
                      final budget = viewModel.budgets[index];
                      final budgetCategories = budget.categoryId
                          .map((id) => viewModel.getCategoryById(id))
                          .whereType<Category>()
                          .toList();
                      final budgetWallets = budget.walletId
                          .map((id) => viewModel.getWalletById(id))
                          .whereType<Wallet>()
                          .toList();
                      final displayTime = viewModel.getDisplayTime(budget);
                      final daysLeft = viewModel.getDaysLeft(budget);

                      return FutureBuilder<double>(
                        future: viewModel.calculateSpentAmount(
                            budget, budget.categoryId, budget.walletId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: Text(''));
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final spentAmount = snapshot.data ?? 0.0;
                          final progress = spentAmount / budget.amount;
                          final amountLeft = budget.amount - spentAmount;
                          final isExpired = displayTime == tr('expired');

                          return Dismissible(
                            key: Key(budget.budgetId),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(tr('confirm')),
                                    content: Text(tr('delete_budget')),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text(tr('no'),
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text(tr('yes'),
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) {
                              viewModel.deleteBudget(budget.budgetId);
                              CustomSnackBar_2.show(
                                  context, tr('delete_budget_success'));
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: Card(
                              margin: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailBudgetScreen(
                                          budget: budget),
                                    ),
                                  );
                                  if (result != null) {
                                    viewModel.loadData();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                                Row(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        for (int i = budgetCategories.take(3).length - 1; i >= 0; i--)
                                                          Transform.translate(
                                                            offset: Offset(i * 10.0, 0),
                                                            child: CircleAvatar(
                                                                radius: 16,
                                                                backgroundColor: parseColor(budgetCategories[i].color),
                                                                child: Icon(
                                                                  parseIcon(budgetCategories[i].icon),
                                                                  color: Colors.white,
                                                                  size: 16,
                                                                ),
                                                              ),

                                                          ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 25.0),
                                                    Expanded(
                                                      child: Text(
                                                        // tr('budget_name_2') +
                                                        //     '${budget.name}',
                                                        tr('${budget.name}'),
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16),
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                      const SizedBox(height: 8),
                                      Text(
                                        tr('budget_amount') +
                                            '${formatAmount(budget.amount)} ₫',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          isExpired
                                              ? Container(
                                            decoration: BoxDecoration(
                                              border:
                                              Border.all(color: Colors.red),
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(4.0),
                                              child: Text(
                                                displayTime,
                                                style: const TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          )
                                              : Text(
                                            displayTime,
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                          if (!isExpired && daysLeft > 0)
                                            Text(
                                              tr('days_left',
                                                  namedArgs: {
                                                    'days': daysLeft.toString()
                                                  }),
                                            )
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: progress,
                                        color: amountLeft < 0
                                            ? Colors.red
                                            : Colors.blue,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            amountLeft < 0
                                                ? tr('overspent') +
                                                '${formatAmount(amountLeft.abs())} ₫'
                                                : tr('remaining_budget_2') +
                                                '${formatAmount(amountLeft)} ₫',
                                            style: TextStyle(
                                              color: amountLeft < 0
                                                  ? Colors.red
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final newBudget = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateBudgetScreen(),
                  ),
                );
                if (newBudget != null && newBudget is Budget) {
                  await viewModel.loadData();
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
