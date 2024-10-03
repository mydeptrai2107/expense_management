import 'package:expense_management/widget/custom_snackbar_1.dart';
import 'package:expense_management/widget/custom_snackbar_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../view_model/category/create_category_view_model.dart';
import '../../widget/custom_ElevatedButton_2.dart';
import '../../widget/custom_header_1.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateCategoriesScreen extends StatefulWidget {
  final int initialSelectedValue;

  const CreateCategoriesScreen({super.key, this.initialSelectedValue = 0});

  @override
  State<CreateCategoriesScreen> createState() => _CreateCategoriesScreenState();
}

class _CreateCategoriesScreenState extends State<CreateCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<CreateCategoryViewModel>(context, listen: false);
    viewModel.setSelectedValue(widget.initialSelectedValue);
    viewModel.resetFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CreateCategoryViewModel>(
          builder: (context, viewModel, child) {
        return Column(
          children: [
            CustomHeader_1(
              title: tr('create_category_title'),
              action: IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                onPressed: viewModel.enableButton
                    ? () async {
                        final newCategory = await viewModel.createCategory();
                        if (newCategory != null) {
                          await CustomSnackBar_2.show(
                              context, tr('creation_success'));
                          Navigator.pop(context, newCategory);
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 70),
                            child: TextFormField(
                              controller: viewModel.nameCategory,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(30),
                              ],
                              decoration: InputDecoration(
                                labelText: tr('category_name_label'),
                              ),
                            ),
                          ),
                          if (viewModel.selectedIcon != null)
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
                                  viewModel.selectedIcon,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          if (viewModel.selectedIcon == null)
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
                                child: const Icon(
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
                          Radio(
                            value: 0,
                            groupValue: viewModel.selectedValue,
                            onChanged: (value) {
                              viewModel.setSelectedValue(value as int);
                            },
                          ),
                          Text(
                            tr('income'),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 50),
                          Radio(
                            value: 1,
                            groupValue: viewModel.selectedValue,
                            onChanged: (value) {
                              viewModel.setSelectedValue(value as int);
                            },
                          ),
                          Text(
                            tr('expense'),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.7),
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
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                              itemCount: viewModel.currentIconsList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    viewModel.setSelectedIcon(
                                        viewModel.currentIconsList[index]);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: viewModel.selectedIcon ==
                                              viewModel.currentIconsList[index]
                                          ? Border.all(
                                              color: Colors.black, width: 1.0)
                                          : null,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: viewModel.selectedIcon ==
                                                  viewModel
                                                      .currentIconsList[index]
                                              ? (viewModel.selectedColor ??
                                                  Colors.blueGrey.shade200)
                                              : Colors.blueGrey.shade200,
                                        ),
                                        child: Icon(
                                          viewModel.currentIconsList[index],
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
                                return GestureDetector(
                                  onTap: () {
                                    viewModel.setSelectedColor(
                                        viewModel.colors[index]);
                                  },
                                  child:   Container(
                                        decoration: BoxDecoration(
                                          color: viewModel.colors[index],
                                          shape: BoxShape.circle,
                                        ),
                                        child: viewModel.selectedColor ==
                                                viewModel.colors[index]
                                            ? const Icon(Icons.check,
                                                color: Colors.white, size: 24)
                                            : null,
                                      ),


                                );
                              },
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 20),
                      CustomElevatedButton_2(
                        text: tr('create_label'),
                        onPressed: viewModel.enableButton
                            ? () async {
                                final newCategory =
                                    await viewModel.createCategory();
                                if (newCategory != null) {
                                  await CustomSnackBar_2.show(
                                      context, tr('creation_success'));
                                  Navigator.pop(context, newCategory);
                                } else {
                                  CustomSnackBar_1.show(context,
                                      tr('create_error_message'));
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
      }),
    );
  }
}
