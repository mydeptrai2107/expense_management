import 'package:flutter/material.dart';
import '../../model/category_model.dart';
import '../../utils/utils.dart';
import 'package:easy_localization/easy_localization.dart';

class MultiCategorySelectionDialog extends StatefulWidget {
  final List<Category> categories;
  final List<Category> selectedCategories;
  final Function(List<Category>) onSelect;

  const MultiCategorySelectionDialog({super.key, 
    required this.categories,
    required this.selectedCategories,
    required this.onSelect,
  });

  @override
  _MultiCategorySelectionDialogState createState() =>
      _MultiCategorySelectionDialogState();
}

class _MultiCategorySelectionDialogState
    extends State<MultiCategorySelectionDialog> {
  late List<Category> selectedCategories;
  late List<Category> filteredCategories;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCategories = List.from(widget.selectedCategories);
    filteredCategories = List.from(widget.categories);
    searchController.addListener(() {
      filterCategories();
    });
  }

  void filterCategories() {
    setState(() {
      filteredCategories = widget.categories
          .where((category) => category.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                tr('select_category'),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: tr('search_category'),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCategories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    bool allSelected =
                        selectedCategories.length == widget.categories.length;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: CheckboxListTile(
                        value: allSelected,
                        title: Text(tr('all_categories')),
                        secondary: const Icon(
                          Icons.list,
                          color: Colors.grey,
                          size: 35,
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedCategories = List.from(widget.categories);
                            } else {
                              selectedCategories.clear();
                            }
                          });
                        },
                      ),
                    );
                  } else {
                    final category = filteredCategories[index - 1];
                    bool isSelected = selectedCategories.contains(category);
                    return Card(
                      margin:
                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                      child: CheckboxListTile(
                        value: isSelected,
                        title: Text(category.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        secondary: CircleAvatar(
                          backgroundColor: parseColor(category.color),
                          child: Icon(
                            parseIcon(category.icon),
                            color: Colors.white,
                          ),
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedCategories.add(category);
                            } else {
                              selectedCategories.remove(category);
                            }
                          });
                        },
                      ),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      tr('cancel'),
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: selectedCategories.isNotEmpty
                        ? () {
                      widget.onSelect(selectedCategories);
                      Navigator.pop(context);
                    }
                        : null,
                    child: Text(
                      tr('confirm'),
                      style: TextStyle(
                        fontSize: 18,
                        color: selectedCategories.isNotEmpty
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
