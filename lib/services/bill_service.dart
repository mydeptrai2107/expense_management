import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';
import '../model/bill_model.dart';

class BillService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<Bill?> getBillById(String billId) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('bills').doc(billId).get();
      if (docSnapshot.exists) {
        return Bill.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error getting bill by id: $e");
      rethrow;
    }
    return null;
  }

  Future<List<Bill>> getBills(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('bills')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Bill.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting bills: $e");
      rethrow;
    }
  }

  Future<void> createBill(Bill bill) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('bills').add(bill.toMap());
      await docRef.update({'billId': docRef.id});

      // Schedule notification based on repeat
      await _notificationService.scheduleNotification(
        docRef.id.hashCode, // Use a unique id for each notification
        bill.name,
        bill.note.isNotEmpty ? bill.note : bill.name,
        bill.date,
        TimeOfDay(hour: bill.hour.hour, minute: bill.hour.minute),
        bill.repeat,
      );
      print('Bill created and notification scheduled');
    } catch (e) {
      print("Error creating bill: $e");
      rethrow;
    }
  }

  Future<void> updateBill(Bill bill) async {
    try {
      await _firestore
          .collection('bills')
          .doc(bill.billId)
          .update(bill.toMap());

      // Schedule notification based on repeat
      await _notificationService.scheduleNotification(
        bill.billId.hashCode,
        bill.name,
        bill.note.isNotEmpty ? bill.note : bill.name,
        bill.date,
        TimeOfDay(hour: bill.hour.hour, minute: bill.hour.minute),
        bill.repeat,
      );
    } catch (e) {
      print("Error updating bill: $e");
      rethrow;
    }
  }

  Future<void> deleteBill(String billId) async {
    try {
      await _firestore.collection('bills').doc(billId).delete();

      // Cancel the notification
      await _notificationService.flutterLocalNotificationsPlugin
          .cancel(billId.hashCode);
    } catch (e) {
      print("Error deleting bill: $e");
      rethrow;
    }
  }
}
