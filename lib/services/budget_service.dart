import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/budget_model.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Budget?> getBudgetById(String budgetId) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('budgets').doc(budgetId).get();
      if (docSnapshot.exists) {
        return Budget.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error getting budget by id: $e");
      rethrow;
    }
    return null;
  }

  Future<List<Budget>> getBudgets(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Budget.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting budgets: $e");
      rethrow;
    }
  }

  Future<void> createBudget(Budget budget) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('budgets').add(budget.toMap());
      await docRef.update({'budgetId': docRef.id});
    } catch (e) {
      print("Error creating budget: $e");
      rethrow;
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await _firestore
          .collection('budgets')
          .doc(budget.budgetId)
          .update(budget.toMap());
    } catch (e) {
      print("Error updating budget: $e");
      rethrow;
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      await _firestore.collection('budgets').doc(budgetId).delete();
    } catch (e) {
      print("Error deleting budget: $e");
      rethrow;
    }
  }
}
