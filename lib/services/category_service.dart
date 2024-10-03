import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/default_category.dart';
import '../model/category_model.dart';
import '../model/enum.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addDefaultCategories(String userId) async {
    final userCategories = await _firestore
        .collection('categories')
        .where('userId', isEqualTo: userId)
        .get();

    if (userCategories.docs.isEmpty) {
      for (var category in defaultCategories) {
        var newCategory = Category(
          categoryId: _firestore.collection('categories').doc().id,
          userId: userId,
          name: category.name,
          type: category.type,
          icon: category.icon,
          color: category.color,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('categories')
            .doc(newCategory.categoryId)
            .set(newCategory.toMap());
      }
    }
  }

  Future<void> addFixedCategories(String userId) async {
    try {
      // Check if there are any fixed categories already existing for the user
      final querySnapshot = await _firestore
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .limit(1) // Limit the query to check for at least one result
          .get();

      // If no fixed categories exist, add them
      if (querySnapshot.docs.isEmpty) {
        for (var category in fixedCategories) {
          var newCategory = Category(
            categoryId: _firestore.collection('categories').doc().id,
            userId: userId,
            name: category.name,
            type: category.type,
            icon: category.icon,
            color: category.color,
            createdAt: DateTime.now(),
            isDefault: true,
          );

          await _firestore
              .collection('categories')
              .doc(newCategory.categoryId)
              .set(newCategory.toMap());
        }
      }
    } catch (e) {
      print("Error adding fixed categories: $e");
      throw e;
    }
  }

  Future<Category?> getCategoryById(String categoryId) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('categories').doc(categoryId).get();
      if (docSnapshot.exists) {
        return Category.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error getting category by id: $e");
      throw e;
    }
    return null;
  }

  Future<List<Category>> getAllCategories(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting all categories: $e");
      throw e;
    }
  }

  Future<List<Category>> getIncomeCategories(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: Type.income.index)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting income categories: $e");
      throw e;
    }
  }

  Future<List<Category>> getIncomeCategoryFrequent(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: Type.income.index)
          .orderBy('createdAt', descending: false)
          .limit(6)
          .get();

      return querySnapshot.docs
          .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting income categories: $e");
      throw e;
    }
  }

  Future<List<Category>> getExpenseCategories(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: Type.expense.index)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting expense categories: $e");
      throw e;
    }
  }

  Future<List<Category>> getExpenseCategoryFrequent(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: Type.expense.index)
          .orderBy('createdAt', descending: false)
          .limit(6)
          .get();

      return querySnapshot.docs
          .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting income categories: $e");
      throw e;
    }
  }

  Future<void> createCategory(Category category) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('categories').add(category.toMap());
      await docRef.update({'categoryId': docRef.id});
    } catch (e) {
      print("Error creating category: $e");
      throw e;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _firestore
          .collection('categories')
          .doc(category.categoryId)
          .update(category.toMap());
    } catch (e) {
      print("Error updating category: $e");
      throw e;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
    } catch (e) {
      print("Error deleting category: $e");
      throw e;
    }
  }
}
