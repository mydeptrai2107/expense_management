import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/icon_list.dart';
import '../../model/category_model.dart';
import '../../model/enum.dart';
import '../../services/category_service.dart';
import '../../data/color_list.dart';
import '../../utils/utils.dart';

class EditCategoryViewModel extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final TextEditingController nameCategory = TextEditingController();

  IconData? selectedIcon;
  Color? selectedColor;
  bool showPlusButtonIcon = true;
  bool showPlusButtonColor = true;
  bool enableButton = false;

  bool get isEmptyName => nameCategory.text.isEmpty;
  bool get isEmptyIcon => selectedIcon == null;
  bool get isEmptyColor => selectedColor == null;

  List<IconData> currentIconsList = incomeIcons;
  List<Color> get colors => colors_list;

  EditCategoryViewModel() {
    nameCategory.addListener(updateButtonState);
  }

  void initializeFields(Category category) {
    nameCategory.text = category.name;
    selectedIcon =  parseIcon(category.icon);
    selectedColor = parseColor(category.color);
    // In giá trị để kiểm tra
    print('Initialized selectedIcon: $selectedIcon');
    print('Initialized selectedColor: $selectedColor');
    currentIconsList = category.type == Type.income ? incomeIcons : expenseIcons;
    showPlusButtonIcon = true;
    showPlusButtonColor = true;
    updateButtonState();
  }

  void updateButtonState() {
    enableButton = !isEmptyName && !isEmptyIcon && !isEmptyColor;
    notifyListeners();
  }

  void setSelectedIcon(IconData icon) {
    print("Selected icon: $icon");
    selectedIcon = icon;
    updateButtonState();
    notifyListeners();
  }

  void setSelectedColor(Color color) {
    print("Selected color. $color");
    selectedColor = color;
    updateButtonState();
    notifyListeners();
  }

  void toggleShowPlusButtonIcon() {
    showPlusButtonIcon = !showPlusButtonIcon;
    notifyListeners();
  }

  void toggleShowPlusButtonColor() {
    showPlusButtonColor = !showPlusButtonColor;
    notifyListeners();
  }

  Future<Category?> updateCategory(String categoryId, DateTime createdAt) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final updatedCategory = Category(
          categoryId: categoryId,
          userId: user.uid,
          name: nameCategory.text,
          type: currentIconsList == incomeIcons ? Type.income : Type.expense,
          icon: selectedIcon.toString(),
          color: selectedColor.toString(),
          createdAt: createdAt,
      );

      try {
        await _categoryService.updateCategory(updatedCategory);
        return updatedCategory;
      } catch (e) {
        print('Error updating category: $e');
        return null;
      }
    }
    return null;
  }

  @override
  void dispose() {
    nameCategory.dispose();
    super.dispose();
  }
}
