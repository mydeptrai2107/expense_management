import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../model/category_model.dart';
import '../../model/enum.dart';
import '../../utils/utils.dart';
import '../../view_model/category/category_list_view_model.dart';
import '../../widget/custom_header_6.dart';
import '../../widget/custom_snackbar_2.dart';
import 'create_categories_screen.dart';
import 'edit_categories_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoryListScreen extends StatefulWidget {
  final int selectedTabIndex;

  const CategoryListScreen({super.key, this.selectedTabIndex = 0});

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late int _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.selectedTabIndex;
  }

  void _onTitleChanged(String? title) {
    setState(() {
      _selectedTabIndex = (title == tr('income')) ? 0 : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryListViewModel(),
      child: Consumer<CategoryListViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Column(
              children: [
                CustomHeader_6(
                  title: _selectedTabIndex == 0 ? tr('income') : tr('expense'),
                  onTitleChanged: _onTitleChanged,
                  leftAction: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  rightAction: IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        viewModel.isSearching = true;
                      });
                    },
                  ),
                  isSearching: viewModel.isSearching,
                  onSearchChanged: (query) {
                    setState(() {
                      viewModel.searchQuery = query;
                      viewModel.filterCategories(query);
                    });
                  },
                  onSearchClose: () {
                    setState(() {
                      viewModel.isSearching = false;
                      viewModel.clearSearch();
                    });
                  },
                ),
                Expanded(
                  child: _selectedTabIndex == 0
                      ? _buildCategoryList(
                          viewModel.incomeCategories, viewModel)
                      : _buildCategoryList(
                          viewModel.expenseCategories, viewModel),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.green,
              shape: const CircleBorder(),
              onPressed: () async {
                int initialSelectedValue = _selectedTabIndex;
                final newCategory = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateCategoriesScreen(
                        initialSelectedValue: initialSelectedValue),
                  ),
                );

                // Kiểm tra nếu danh mục mới được tạo và điều hướng lại về CategoryListScreen với tab tương ứng
                if (newCategory != null && newCategory is Category) {
                  await viewModel.loadCategories();
                  setState(() {
                    _selectedTabIndex = newCategory.type == Type.income ? 0 : 1;
                  });
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(
      List<Category> categories, CategoryListViewModel viewModel) {
    if (viewModel.isSearching && categories.isEmpty) {
      return  Center(
        child: Text(
          tr('no_search_results'),
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    if (categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            if (category.isDefault) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title:  Text(tr('notification')),
                    content:  Text(
                      tr('delete_category_warning'),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            } else {
              _showOptionsDialog(context, category, viewModel);
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: parseColor(category.color),
                ),
                child: Icon(
                  parseIcon(category.icon),
                  color: Colors.white,
                  size: 40,
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
    );
  }

  void _showOptionsDialog(BuildContext context, Category category,
      CategoryListViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr('options_for') + '${category.name}'),
          actions: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green,
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final updatedCategory = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditCategoriesScreen(category: category),
                          ),
                        );
                        if (updatedCategory != null &&
                            updatedCategory is Category) {
                          await viewModel.loadCategories();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(FontAwesomeIcons.penToSquare,
                              color: Colors.white),
                          Text(
                            tr('edit'),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.red,
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        final shouldDelete = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(tr('attention')),
                              content: RichText(
                                text:  TextSpan(
                                  text: tr('delete_category_alert_content_prefix'),
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                         tr('delete_category_alert_content_highlight'),
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 17,
                                          fontWeight: FontWeight
                                              .w500),
                                    ),
                                    TextSpan(
                                      text: tr('delete_category_alert_content_suffix'),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              16),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child:  Text(
                                    tr('no'),
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 18),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(false); 
                                  },
                                ),
                                TextButton(
                                  child:  Text(
                                    tr('yes'),
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 18),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldDelete == true) {
                          viewModel.deleteCategory(category.categoryId);
                          Navigator.pop(context);
                          await CustomSnackBar_2.show(
                              context, tr('utility_category') + '${category.name}' + tr('deleted'));
                        }
                      },
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(FontAwesomeIcons.trash, color: Colors.white),
                          Text(
                            tr('delete'),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
