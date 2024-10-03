import 'package:expense_management/widget/custom_snackbar_2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../model/enum.dart';
import '../../view_model/category/edit_category_view_model.dart';
import '../../widget/custom_ElevatedButton_2.dart';
import '../../widget/custom_header_1.dart';
import '../../model/category_model.dart';
import '../../widget/custom_snackbar_1.dart';
import 'package:easy_localization/easy_localization.dart';

class EditCategoriesScreen extends StatelessWidget {
  final Category category;
  const EditCategoriesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditCategoryViewModel()
        ..initializeFields(category),
      child: Scaffold(
        body: Consumer<EditCategoryViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                CustomHeader_1(
                  title: tr('edit_category'),
                  action: IconButton(
                    icon: const Icon(Icons.save, color: Colors.white),
                    onPressed: viewModel.enableButton
                        ? () async {
                      final updatedCategory = await viewModel.updateCategory(
                          category.categoryId,
                          category.createdAt);
                      if (updatedCategory != null) {
                        await CustomSnackBar_2.show(
                            context, tr('update_successful'));
                        Navigator.pop(context, updatedCategory);
                      } else {
                        CustomSnackBar_1.show(
                            context, tr('create_error_message'));
                      }
                    }
                        : null,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 70),
                                child: TextField(
                                  controller: viewModel.nameCategory,
                                  decoration: InputDecoration(
                                    labelText: tr('category_name_label'),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 2.0,
                                top: 5.0,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: viewModel.selectedColor ??
                                        Colors.blueGrey.shade200,
                                  ),
                                  child: Icon(
                                    viewModel.selectedIcon ??
                                        FontAwesomeIcons.question,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                tr('category_type'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                category.type == Type.income
                                    ? tr('income')
                                    : tr('expense'),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: category.type == Type.income
                                          ? Colors.green
                                          : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                tr('icon_label'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  viewModel.toggleShowPlusButtonIcon();
                                },
                                child: Icon(
                                  viewModel.showPlusButtonIcon
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_drop_up,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          viewModel.showPlusButtonIcon
                              ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                            itemCount: viewModel.currentIconsList.length,
                            itemBuilder: (BuildContext context, int index) {
                              final icon = viewModel.currentIconsList[index];
                              final isSelected = viewModel.selectedIcon?.codePoint == icon.codePoint;

                              return GestureDetector(
                                onTap: () {
                                  viewModel.setSelectedIcon(icon);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: isSelected ? Border.all(color: Colors.black, width: 1.0) : null,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? (viewModel.selectedColor ?? Colors.blueGrey.shade200)
                                            : Colors.blueGrey.shade200,
                                      ),
                                      child: Icon(
                                        icon,
                                        size: 38,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )

                              : const SizedBox.shrink(),
                          const SizedBox(height: 40),
                          Row(
                            children: [
                              Text(
                                tr('color_label'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  viewModel.toggleShowPlusButtonColor();
                                },
                                child: Icon(
                                  viewModel.showPlusButtonColor
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_drop_up,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          viewModel.showPlusButtonColor
                              ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15,
                              childAspectRatio: 1,
                            ),
                            itemCount: viewModel.colors.length,
                            itemBuilder: (BuildContext context, int index) {
                              final color = viewModel.colors[index];
                              final isSelected = viewModel.selectedColor?.value == color.value;

                              return GestureDetector(
                                onTap: () {
                                  viewModel.setSelectedColor(color);
                                },
                                child:  Container(
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check, color: Colors.white, size: 24)
                                          : null,
                                    ),
                              );
                            },
                          )
                              : const SizedBox.shrink(),
                          const SizedBox(height: 20),
                          CustomElevatedButton_2(
                            text: tr('save_button'),
                            onPressed: viewModel.enableButton
                                ? () async {
                              final updatedCategory =
                              await viewModel.updateCategory(
                                  category.categoryId,
                                  category.createdAt);
                              if (updatedCategory != null) {
                                await CustomSnackBar_2.show(
                                    context, tr('update_successful'));
                                Navigator.pop(context, updatedCategory);
                              } else {
                                CustomSnackBar_1.show(context,
                                    tr('update_error_message'));
                              }
                            }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
