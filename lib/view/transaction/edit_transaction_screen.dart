import 'package:easy_localization/easy_localization.dart';
import 'package:expense_management/model/category_model.dart';
import 'package:expense_management/model/transaction_model.dart';
import 'package:expense_management/view_model/transaction/edit_transaction_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';
import '../../widget/custom_ElevatedButton_2.dart';
import '../../widget/custom_header_4.dart';
import '../../widget/custom_snackbar_2.dart';
import 'component/expense_category_screen.dart';
import 'component/image_detail_screen.dart';
import 'component/income_category_screen.dart';
import 'component/wallet_list_screen.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transactions transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late EditTransactionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EditTransactionViewModel();
    _viewModel.initialize(widget.transaction);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _viewModel,
      child: Consumer<EditTransactionViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Column(
              children: [
                CustomHeader_4(
                  rightAction: IconButton(
                    icon: const Icon(Icons.save, color: Colors.white),
                    onPressed: viewModel.enableButton
                        ? () async {
                            final updatedTransaction =
                                await viewModel.updateTransaction(
                                    widget.transaction.transactionId, context);
                            if (updatedTransaction != null) {
                              await CustomSnackBar_2.show(
                                  context, tr('save_success'));
                              Navigator.pop(context, updatedTransaction);
                            }
                          }
                        : null,
                  ),
                  title: viewModel.transactionTypeTitle,
                  onTitleChanged: (String? newTitle) {
                    viewModel.updateTransactionTypeTitle(newTitle!);
                  },
                  leftAction: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
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
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 0),
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
                                      viewModel.transactionTypeTitle ==
                                              'Thu nhập'
                                          ? const IncomeCategoryScreen()
                                          : const ExpenseCategoryScreen(),
                                ),
                              );
                              if (selectedCategory != null) {
                                viewModel.setSelectedCategory(selectedCategory);
                              }
                            },
                          ),
                          const Divider(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 1,
                                        ),
                                        itemCount:
                                            viewModel.frequentCategories.length,
                                        itemBuilder: (context, index) {
                                          Category category = viewModel
                                              .frequentCategories[index];
                                          bool isSelected = category ==
                                              viewModel.selectedCategory;
                                          return GestureDetector(
                                            onTap: () {
                                              viewModel.setSelectedCategory(
                                                  category);
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? parseColor(
                                                            category.color)
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : const Center(
                                        child: CircularProgressIndicator()),
                            ],
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 0),
                            // Để loại bỏ padding mặc định
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
                                  builder: (context) =>
                                      const WalletListScreen(),
                                ),
                              );
                              if (selectedWallet != null) {
                                viewModel.setSelectedWallet(selectedWallet);
                              }
                            },
                          ),
                          const Divider(),
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await viewModel.captureImage(context);
                                  },
                                  child: const Center(
                                      child: Icon(Icons.camera_alt)),
                                ),
                              ),
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await viewModel
                                        .pickImageFromGallery(context);
                                  },
                                  child: const Center(
                                      child: Icon(Icons.photo_library)),
                                ),
                              ),
                            ],
                          ),
                          if (viewModel.existingImageUrls.isNotEmpty ||
                              viewModel.newImages.isNotEmpty)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                              ),
                              itemCount: viewModel.existingImageUrls.length +
                                  viewModel.newImages.length,
                              itemBuilder: (context, index) {
                                if (index <
                                    viewModel.existingImageUrls.length) {
                                  // Hiển thị ảnh từ URL
                                  final imageUrl =
                                      viewModel.existingImageUrls[index];
                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ImageDetailScreen(
                                                imageUrls:
                                                    viewModel.existingImageUrls,
                                                imageFiles: viewModel.newImages,
                                                initialIndex: index,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Image.network(
                                          imageUrl,
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
                                            viewModel.removeImage(imageUrl);
                                            setState(
                                                () {}); // Cập nhật giao diện sau khi xóa ảnh
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
                                } else {
                                  // Hiển thị ảnh từ tệp cục bộ
                                  final fileIndex = index -
                                      viewModel.existingImageUrls.length;
                                  final file = viewModel.newImages[fileIndex];
                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ImageDetailScreen(
                                                imageUrls:
                                                    viewModel.existingImageUrls,
                                                imageFiles: viewModel.newImages,
                                                initialIndex: index,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Image.file(
                                          file,
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: () {
                                            viewModel.removeNewImage(file);
                                            setState(
                                                () {}); // Cập nhật giao diện sau khi xóa ảnh
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
                                }
                              },
                            ),
                          const SizedBox(height: 16),
                          CustomElevatedButton_2(
                            onPressed: viewModel.enableButton
                                ? () async {
                                    final updatedTransaction =
                                        await viewModel.updateTransaction(
                                            widget.transaction.transactionId,
                                            context);
                                    if (updatedTransaction != null) {
                                      await CustomSnackBar_2.show(
                                          context, tr('save_success'));
                                      Navigator.pop(
                                          context, updatedTransaction);
                                    }
                                  }
                                : null,
                            text: tr('save_button'),
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
