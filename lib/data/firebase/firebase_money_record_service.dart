import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firebase_collections.dart';
import '../models/money_record_model.dart';
import 'firestore_service.dart';

class FirebaseMoneyRecordService {
  final FirestoreService _firestoreService = FirestoreService();

  CollectionReference<Map<String, dynamic>> get _recordsRef {
    return _firestoreService.userCollection(FirebaseCollections.moneyRecords);
  }

  Future<void> addRecord(MoneyRecordModel record) async {
    await _recordsRef.doc(record.id).set(record.toMap());
  }

  Future<void> addRecords(List<MoneyRecordModel> records) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final record in records) {
      batch.set(_recordsRef.doc(record.id), record.toMap());
    }

    await batch.commit();
  }

  Future<void> updateRecord(MoneyRecordModel record) async {
    await _recordsRef.doc(record.id).set(
          record.copyWith(updatedAt: DateTime.now()).toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> deleteRecord(String recordId) async {
    await _recordsRef.doc(recordId).delete();
  }

  Stream<List<MoneyRecordModel>> watchRecords() {
    return _recordsRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MoneyRecordModel.fromMap(doc.data());
      }).toList();
    });
  }

  Stream<List<MoneyRecordModel>> watchRecordsByMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    return _recordsRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MoneyRecordModel.fromMap(doc.data());
      }).toList();
    });
  }
}