import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/utils.dart';
import '../../../view_model/category/category_list_view_model.dart';
import '../../../widget/custom_header_3.dart';
import 'package:easy_localization/easy_localization.dart';

class ExpenseCategoryScreen extends StatefulWidget {
  const ExpenseCategoryScreen({super.key});

  @override
  State<ExpenseCategoryScreen> createState() => _ExpenseCategoryScreenState();
}

class _ExpenseCategoryScreenState extends State<ExpenseCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryListViewModel(),
      child: Consumer<CategoryListViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Column(
              children: [
                CustomHeader_3(
                  title: tr('expense_category_title'),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: viewModel.expenseCategories.isEmpty &&
                            viewModel.isSearching
                        ?  Center(
                            child: Text(
                              tr('no_search_results'),
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          )
                        : viewModel.expenseCategories.isEmpty
                            ?  Center(
                                child: Text(
                                  tr('no_expense_categories'),
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              )
                            : GridView.builder(
                                itemCount: viewModel.expenseCategories.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                ),
                                itemBuilder: (context, index) {
                                  final category =
                                      viewModel.expenseCategories[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context, category);
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
