import 'dart:io';
import 'package:expense_management/widget/custom_header_4.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:expense_management/widget/custom_ElevatedButton_2.dart';
import '../../model/category_model.dart';
import '../../utils/utils.dart';
import '../../view_model/transaction/create_transaction_view_model.dart';
import '../../widget/custom_snackbar_2.dart';
import 'component/expense_category_screen.dart';
import 'component/image_detail_screen.dart';
import 'component/income_category_screen.dart';
import 'component/wallet_list_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreateTransactionViewModel(),
      child: Consumer<CreateTransactionViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Column(
              children: [
                CustomHeader_4(
                  leftAction: IconButton(
                    icon: const Icon(Icons.check, color: Colors.white),
                    onPressed: viewModel.enableButton
                        ? () async {
                            final newTransaction =
                                await viewModel.createTransaction(context);
                            if (newTransaction != null) {
                              await CustomSnackBar_2.show(
                                  context, tr('creation_success'));
                              viewModel.resetFields();
                            }
                          }
                        : null,
                  ),
                  title: viewModel.transactionTypeTitle,
                  onTitleChanged: (String? newTitle) {
                    viewModel.updateTransactionTypeTitle(newTitle!);
                  },
                  rightAction: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      viewModel.resetFields();
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: viewModel.amountController,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(15),
                                  ],
                                  onChanged: (value) {
                                    viewModel.setAmount(
                                        double.tryParse(value) ?? 0.0);
                                  },
                                  decoration: InputDecoration(
                                    labelText: tr('amount_label'),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w500,
                                    color: viewModel.isExpenseTabSelected
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child:
                                    Text("₫", style: TextStyle(fontSize: 28)),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                            // Để loại bỏ padding mặc định
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: viewModel.selectedCategory != null
                                    ? parseColor(
                                        viewModel.selectedCategory!.color)
                                    : Colors.grey,
                              ),
                              child: viewModel.selectedCategory != null
                                  ? Icon(
                                      parseIcon(
                                          viewModel.selectedCategory!.icon),
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  : const Icon(
                                      Icons.category,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                            ),
                            title: viewModel.selectedCategory != null
                                ? Text(
                                    viewModel.selectedCategory!.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 18),
                                  )
                                : Text(
                                    tr('category_placeholder'),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                            trailing: Text(
                              tr('all_text'),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () async {
                              final selectedCategory = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      viewModel.isExpenseTabSelected
                                          ? const ExpenseCategoryScreen()
                                          : const IncomeCategoryScreen(),
                                ),
                              );
                              if (selectedCategory != null) {
                                viewModel.setSelectedCategory(selectedCategory);
                              }
                            },
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(tr('frequent_categories'),
                                  style: const TextStyle(fontSize: 18)),
                              GestureDetector(
                                onTap: () {
                                  viewModel.toggleShowPlusButtonCategory();
                                },
                                child: Icon(
                                  viewModel.showPlusButtonCategory
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_drop_up,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          if (viewModel.showPlusButtonCategory)
                            viewModel.isFrequentCategoriesLoaded
                                ? GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3, 
                                      childAspectRatio: 1, // Tỷ lệ chiều rộng / chiều cao của mỗi item
                                    ),
                                    itemCount:
                                        viewModel.frequentCategories.length,
                                    itemBuilder: (context, index) {
                                      Category category =
                                          viewModel.frequentCategories[index];
                                      bool isSelected = category ==
                                          viewModel.selectedCategory;
                                      return GestureDetector(
                                        onTap: () {
                                          viewModel
                                              .setSelectedCategory(category);
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? parseColor(category.color)
                                                    : Colors.transparent,
                                                shape: BoxShape.rectangle,
                                              ),
                                              child: Container(
                                                width: 45,
                                                height: 45,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: parseColor(
                                                      category.color),
                                                ),
                                                child: Icon(
                                                  parseIcon(category.icon),
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              category.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : const Center(child: CircularProgressIndicator()),
                          const Divider(),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: viewModel.selectedWallet != null
                                    ? parseColor(
                                        viewModel.selectedWallet!.color)
                                    : Colors.grey,
                              ),
                              child: viewModel.selectedWallet != null
                                  ? Icon(
                                      parseIcon(viewModel.selectedWallet!.icon),
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  : const Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                            ),
                            title: viewModel.selectedWallet != null
                                ? Text(
                                    viewModel.selectedWallet!.name,
                                    style: const TextStyle(fontSize: 20),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    tr('wallet_placeholder'),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                            trailing: Text(
                              tr('all_text'),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () async {
                              final selectedWallet = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WalletListScreen(),
                                ),
                              );
                              if (selectedWallet != null) {
                                viewModel.setSelectedWallet(selectedWallet);
                              }
                            },
                          ),
                          const Divider(),
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: TextFormField(
                                  controller: viewModel.dateController,
                                  readOnly: true,
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      locale: context.locale,
                                      context: context,
                                      initialDate: viewModel.selectedDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null &&
                                        picked != viewModel.selectedDate) {
                                      viewModel.setSelectedDate(picked);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: tr('select_date'),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: viewModel.hourController,
                                  readOnly: true,
                                  onTap: () async {
                                    final TimeOfDay? picked =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: viewModel.selectedHour,
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Localizations.override(
                                          context: context,
                                          locale: context.locale,
                                          child: child,
                                        );
                                      },
                                    );
                                    if (picked != null &&
                                        picked != viewModel.selectedHour) {
                                      viewModel.setSelectedHour(picked);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: tr('select_time'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: viewModel.noteController,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(400),
                            ],
                            onChanged: (value) {
                              viewModel.setNote(value);
                            },
                            decoration: InputDecoration(
                              labelText: tr('note_label'),
                            ),
                            keyboardType: TextInputType.text,
                            maxLines: null,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await viewModel.captureImage(context);
                                  },
                                  child: const Center(child: Icon(Icons.camera_alt)),
                                ),
                              ),
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await viewModel
                                        .pickImageFromGallery(context);
                                  },
                                  child:
                                      const Center(child: Icon(Icons.photo_library)),
                                ),
                              ),
                            ],
                          ),
                          if (viewModel.images.isNotEmpty)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                              ),
                              itemCount: viewModel.images.length,
                              itemBuilder: (context, index) {
                                final imagePath = viewModel.images[index].path;
                                return Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ImageDetailScreen(
                                              imageFiles: viewModel.images
                                                  .map((image) =>
                                                      File(image.path))
                                                  .toList(),
                                              initialIndex: index,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Image.file(
                                        File(imagePath),
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          viewModel.removeImage(imagePath);
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          const SizedBox(height: 16),
                          CustomElevatedButton_2(
                            onPressed: viewModel.enableButton
                                ? () async {
                                    final newTransaction = await viewModel
                                        .createTransaction(context);
                                    if (newTransaction != null) {
                                      await CustomSnackBar_2.show(
                                          context, tr('creation_success'));
                                      viewModel.resetFields();
                                    }
                                  }
                                : null,
                            text: tr('create_label'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
