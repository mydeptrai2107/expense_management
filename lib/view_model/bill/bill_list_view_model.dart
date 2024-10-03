import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../model/bill_model.dart';
import '../../services/bill_service.dart';
import '../../services/notification_service.dart';

class BillListViewModel extends ChangeNotifier {
  final BillService _billService = BillService();
  NotificationService _notificationService = NotificationService();
  TextEditingController searchController = TextEditingController();

  List<Bill> _bills = [];
  List<Bill> _filteredBills = [];
  bool isSearching = false;
  String searchQuery = '';
  bool isLoading = false;

  List<Bill> get bills => _filteredBills;

  BillListViewModel(){
    loadBills();
  }

  Future<void> loadBills() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      try {
        isLoading = true;
        notifyListeners();
        _bills = await _billService.getBills(user.uid);
        _filteredBills = _bills;
        notifyListeners();
      } catch (e) {
        print("Error loading bills: $e");
      }finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void filterBills(String query) {
    if (query.isEmpty) {
      _filteredBills = _bills;
    } else {
      _filteredBills = _bills.where((bill) {
        return bill.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> updateActiveBill(Bill bill) async {
    try {
      await _billService.updateBill(bill);
      if (!bill.isActive) {
        await _notificationService.cancelNotification(bill.billId);
      }
      loadBills();
    } catch (e) {
      print("Error updating bill: $e");
    }
  }

  Future<void> deleteBill(String billId) async {
    try {
      await _billService.deleteBill(billId);
      await loadBills();
    } catch (e) {
      print("Error deleting bill: $e");
    }
  }

  void clearSearch(){
    searchQuery = '';
    searchController.clear();
    filterBills('');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
