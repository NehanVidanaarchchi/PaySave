import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/firebase_collections.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get currentUserId {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> userDoc([String? userId]) {
    return firestore
        .collection(FirebaseCollections.users)
        .doc(userId ?? currentUserId);
  }

  DocumentReference<Map<String, dynamic>> profileDoc([String? userId]) {
    return userDoc(userId).collection(FirebaseCollections.profile).doc('main');
  }

  CollectionReference<Map<String, dynamic>> userCollection(
    String collectionName, [
    String? userId,
  ]) {
    return userDoc(userId).collection(collectionName);
  }

  Future<void> setData({
    required DocumentReference<Map<String, dynamic>> reference,
    required Map<String, dynamic> data,
  }) async {
    await reference.set(data, SetOptions(merge: true));
  }

  Future<void> updateData({
    required DocumentReference<Map<String, dynamic>> reference,
    required Map<String, dynamic> data,
  }) async {
    await reference.update(data);
  }

  Future<void> deleteData({
    required DocumentReference<Map<String, dynamic>> reference,
  }) async {
    await reference.delete();
  }
}
