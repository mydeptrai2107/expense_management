import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/profile_model.dart';

class ProfileService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfile(
      String userId) async {
    return _firestore.collection('profiles').doc(userId).get();
  }

  Future<String?> uploadImage(String userId, String path) async {
    File file = File(path);
    try {
      Reference ref =
          _firebaseStorage.ref().child('user_avatars').child(userId);
      TaskSnapshot uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print("Lỗi khi tải ảnh lên: $e");
      return null;
    }
  }

  Future<void> saveProfile(Profile profile) async {
    await _firestore
        .collection('profiles')
        .doc(profile.userId)
        .set(profile.toMap());
  }
}
