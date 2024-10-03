import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../model/bill_model.dart';
import '../../model/enum.dart';
import '../../services/bill_service.dart';
import '../../utils/utils.dart';

class CreateBillViewModel extends ChangeNotifier {
  final BillService _billService = BillService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController hourController = TextEditingController();

  String name = '';
  Repeat selectedRepeat = Repeat.Daily;
  late DateTime selectedDate;
  late TimeOfDay selectedHour;
  String note = '';
  bool enableButton = false;

  List<Repeat> get repeatOptions => Repeat.values;

  CreateBillViewModel() {
    DateTime now = DateTime.now();
    DateTime oneHourLater = now.add(Duration(hours: 1));

    selectedDate = oneHourLater;
    selectedHour = TimeOfDay(hour: oneHourLater.hour, minute: oneHourLater.minute);

    updateDateController();
    updateHourController();
  }

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

  Future<Bill?> createBill() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Bill newBill = Bill(
        billId: '',
        userId: user.uid,
        name: name,
        repeat: selectedRepeat,
        date: selectedDate,
        hour: selectedHour,
        note: note,
        isActive: true,
        createdAt: DateTime.now(),
      );

      try {
        await _billService.createBill(newBill);
        return newBill;
      } catch (e) {
        print('Error creating budget: $e');
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