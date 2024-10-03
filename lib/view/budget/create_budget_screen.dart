import 'package:expense_management/model/enum.dart';
import 'package:expense_management/widget/custom_ElevatedButton_2.dart';
import 'package:expense_management/widget/custom_header_1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../model/category_model.dart';
import '../../model/wallet_model.dart';
import '../../utils/utils.dart';
import '../../view_model/budget/create_budget_view_model.dart';
import '../../widget/custom_snackbar_2.dart';
import '../../widget/multi_category_selection_dialog.dart';
import '../../widget/multi_wallet_selection_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateBudgetScreen extends StatelessWidget {
  const CreateBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateBudgetViewModel(),
      child: Consumer<CreateBudgetViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
              body: Column(
            children: [
               CustomHeader_1(title: tr('utility_budget')),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Consumer<CreateBudgetViewModel>(
                      builder: (context, model, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(15),
                                  ],
                                  controller: viewModel.amountController,
                                  decoration:
                                       InputDecoration(labelText: tr('amount_label')),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) =>
                                      viewModel.updateButtonState(),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: Text(
                                  '₫',
                                  style: TextStyle(
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: model.nameController,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(40),
                            ],
                            decoration:  InputDecoration(
                              labelText: tr('budget_name'),
                            ),
                            onChanged: (_) => viewModel.updateButtonState(),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                            leading: SizedBox(
                              width: 60,
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Stack(
                                  children: [
                                    if (viewModel.selectedCategories.length > 2)
                                      Positioned(
                                        left: 20,
                                        child: CircleAvatar(
                                          backgroundColor: parseColor(viewModel
                                              .selectedCategories[2].color),
                                          child: Icon(
                                            parseIcon(viewModel
                                                .selectedCategories[2].icon),
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                    if (viewModel.selectedCategories.length > 1)
                                      Positioned(
                                        left: 10,
                                        child: CircleAvatar(
                                          backgroundColor: parseColor(viewModel
                                              .selectedCategories[1].color),
                                          child: Icon(
                                            parseIcon(viewModel
                                                .selectedCategories[1].icon),
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                    if (viewModel.selectedCategories.isNotEmpty)
                                      Positioned(
                                        left: 0,
                                        child: CircleAvatar(
                                          backgroundColor: parseColor(viewModel
                                              .selectedCategories[0].color),
                                          child: Icon(
                                            parseIcon(viewModel
                                                .selectedCategories[0].icon),
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            title: Text(
                              viewModel.getCategoriesText(
                                  viewModel.selectedCategories,
                                  viewModel.categories),
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: const Text(
                              '>',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return MultiCategorySelectionDialog(
                                    categories: viewModel.categories,
                                    selectedCategories:
                                        viewModel.selectedCategories,
                                    onSelect: (List<Category> categories) {
                                      viewModel.setCategories(categories);
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                            leading: SizedBox(
                              width: 60,
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Stack(
                                  children: [
                                    if (viewModel.selectedWallets.length > 2)
                                      Positioned(
                                        left: 20,
                                        child: CircleAvatar(
                                          backgroundColor: parseColor(viewModel
                                              .selectedWallets[2].color),
                                          child: Icon(
                                            parseIcon(viewModel
                                                .selectedWallets[2].icon),
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                    if (viewModel.selectedWallets.length > 1)
                                      Positioned(
                                        left: 10,
                                        child: CircleAvatar(
                                          backgroundColor: parseColor(viewModel
                                              .selectedWallets[1].color),
                                          child: Icon(
                                            parseIcon(viewModel
                                                .selectedWallets[1].icon),
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                    if (viewModel.selectedWallets.isNotEmpty)
                                      Positioned(
                                        left: 0,
                                        child: CircleAvatar(
                                          backgroundColor: parseColor(viewModel
                                              .selectedWallets[0].color),
                                          child: Icon(
                                            parseIcon(viewModel
                                                .selectedWallets[0].icon),
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            title: Text(
                              viewModel.getWalletsText(
                                  viewModel.selectedWallets, viewModel.wallets),
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: const Text(
                              '>',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return MultiWalletSelectionDialog(
                                    wallets: viewModel.wallets,
                                    selectedWallets: viewModel.selectedWallets,
                                    onSelect: (List<Wallet> wallets) {
                                      viewModel.setWallets(wallets);
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<Repeat>(
                            value: model.selectedRepeat,
                            items: model.repeatOptions
                                .map((option) => DropdownMenuItem<Repeat>(
                                      value: option,
                                      child: Text(getRepeatString(
                                          option)),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                model.setSelectedRepeat(value);
                              }
                            },
                            decoration:  InputDecoration(
                              labelText: tr('repeat_label'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: model.startDateController,
                            readOnly: true,
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                locale: context.locale,
                                context: context,
                                initialDate: viewModel.startDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null &&
                                  picked != viewModel.startDate) {
                                viewModel.setStartDate(picked);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: tr('start_day'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: model.endDateController
                              ..text = model.endDateController.text.isEmpty
                                  ? tr('unknown')
                                  : model.endDateController.text,
                            readOnly: true,
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                locale: context.locale,
                                context: context,
                                initialDate: viewModel.endDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null &&
                                  picked != viewModel.endDate) {
                                viewModel.setEndDate(picked);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: tr('end_day'),
                              hintText: model.endDateController.text.isEmpty
                                  ? tr('unknown')
                                  : '',
                            ),
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: CustomElevatedButton_2(
                              onPressed: viewModel.enableButton
                                  ? () async {
                                      final newBudget =
                                          await viewModel.createBudget(context);
                                      if (newBudget != null) {
                                        await CustomSnackBar_2.show(
                                            context, tr('creation_success'));
                                        Navigator.pop(context, newBudget);
                                      }
                                    }
                                  : null,
                              text: tr('create_label'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ));
        },
      ),
    );
  }
}
