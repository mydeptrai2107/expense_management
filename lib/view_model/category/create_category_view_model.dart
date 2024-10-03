import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/icon_list.dart';
import '../../model/category_model.dart';
import '../../model/enum.dart';
import '../../services/category_service.dart';
import '../../data/color_list.dart';

class CreateCategoryViewModel extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final TextEditingController nameCategory = TextEditingController();

  int selectedValue = 0;
  IconData? selectedIcon;
  Color? selectedColor;
  bool showPlusButtonIcon = true;
  bool showPlusButtonColor = true;
  bool enableButton = false;

  bool get isEmptyName => nameCategory.text.isEmpty;
  bool get isEmptyIcon => selectedIcon == null;
  bool get isEmptyColor => selectedColor == null;

  List<IconData> get currentIconsList => selectedValue == 0 ? incomeIcons : expenseIcons;
  List<Color> get colors => colors_list;

  CreateCategoryViewModel() {
    nameCategory.addListener(updateButtonState);
  }

  void updateButtonState() {
    enableButton = !isEmptyName && !isEmptyIcon && !isEmptyColor;
    notifyListeners();
  }

  void setSelectedValue(int value) {
    selectedValue = value;
    resetSelectedIcon();
    notifyListeners();
  }

  void setSelectedIcon(IconData icon) {
    selectedIcon = icon;
    updateButtonState();
  }

  void setSelectedColor(Color color) {
    selectedColor = color;
    updateButtonState();
  }

  void toggleShowPlusButtonIcon() {
    showPlusButtonIcon = !showPlusButtonIcon;
    notifyListeners();
  }

  void toggleShowPlusButtonColor() {
    showPlusButtonColor = !showPlusButtonColor;
    notifyListeners();
  }

  void resetSelectedIcon() {
    selectedIcon = null;
    notifyListeners();
  }

  Future<Category?> createCategory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newCategory = Category(
        categoryId: '',
        userId: user.uid,
        name: nameCategory.text,
        type: selectedValue == 0 ? Type.income : Type.expense,
        icon: selectedIcon.toString(),
        color: selectedColor.toString(),
        createdAt: DateTime.now()
      );

      try {
        await _categoryService.createCategory(newCategory);
        return newCategory;
      } catch (e) {

        print('Error creating category: $e');
        return null;
      }
    }
    return null;
  }

  void resetFields() {
    nameCategory.clear();
    selectedIcon = null;
    selectedColor = null;
    enableButton = false;
    showPlusButtonIcon = true;
    showPlusButtonColor = true;
    notifyListeners();
  }

  @override
  void dispose() {
    nameCategory.dispose();
    super.dispose();
  }
}
