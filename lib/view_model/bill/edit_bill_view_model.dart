import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../model/bill_model.dart';
import '../../model/enum.dart';
import '../../services/bill_service.dart';
import '../../utils/utils.dart';

class EditBillViewModel extends ChangeNotifier {
  final BillService _billService = BillService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController hourController = TextEditingController();

  String name = '';
  Repeat selectedRepeat = Repeat.Daily;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedHour = TimeOfDay.now();
  String note = '';
  bool enableButton = false;

  EditBillViewModel(Bill bill) {
    name = bill.name;
    selectedRepeat = bill.repeat;
    selectedDate = bill.date;
    selectedHour = bill.hour;
    note = bill.note;

    nameController.text = name;
    noteController.text = note;
    updateDateController();
    updateHourController();
    updateButtonState();
  }

  List<Repeat> get repeatOptions => Repeat.values;

  void updateButtonState() {
    enableButton = nameController.text.isNotEmpty;
    notifyListeners();
  }

  void setName(String value) {
    name = value;
    updateButtonState();
    notifyListeners();
  }

  void setSelectedRepeat(Repeat value) {
    selectedRepeat = value;
    notifyListeners();
  }

  void setSelectedDate(DateTime value) {
    selectedDate = value;
    updateDateController();
    notifyListeners();
  }

  void setSelectedHour(TimeOfDay value) {
    selectedHour = value;
    updateHourController();
    notifyListeners();
  }

  void updateDateController() {
    dateController.text = formatDate(selectedDate);
  }

  void updateHourController() {
    hourController.text = formatHour(selectedHour);
  }

  void setNote(String value) {
    note = value;
    notifyListeners();
  }

  Future<Bill?> updateBill(String billId, DateTime createdAt) async {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      Bill updatedBill = Bill(
        billId: billId,
        userId: user.uid,
        name: name,
        repeat: selectedRepeat,
        date: selectedDate,
        hour: selectedHour,
        note: note,
        isActive: true,
        createdAt: createdAt,
      );

      try {
        await _billService.updateBill(updatedBill);
        return updatedBill;
      } catch (e) {
        print('Error updating bill: $e');
        return null;
      }
    }
    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    dateController.dispose();
    hourController.dispose();
    super.dispose();
  }
}
