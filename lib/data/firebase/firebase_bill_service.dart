import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firebase_collections.dart';
import 'firestore_service.dart';
import '../models/bill_model.dart';

class FirebaseBillService {
  final FirestoreService _firestoreService = FirestoreService();

  CollectionReference<Map<String, dynamic>> get _billsRef {
    return _firestoreService.userCollection(FirebaseCollections.bills);
  }

  Future<void> addBill(BillModel bill) async {
    await _billsRef.doc(bill.id).set(bill.toMap());
  }

  Future<void> updateBill(BillModel bill) async {
    await _billsRef
        .doc(bill.id)
        .set(
          bill.copyWith(updatedAt: DateTime.now()).toMap(),
          SetOptions(merge: true),
        );
  }

  Future<BillModel?> getBillById(String billId) async {
    final snapshot = await _billsRef.doc(billId).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return BillModel.fromMap(snapshot.data()!);
  }

  Stream<List<BillModel>> watchBills() {
    return _billsRef.orderBy('dueDate').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BillModel.fromMap(doc.data());
      }).toList();
    });
  }

  Stream<List<BillModel>> watchUpcomingBills() {
    return _billsRef
        .where('isPaid', isEqualTo: false)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return BillModel.fromMap(doc.data());
          }).toList();
        });
  }

  Future<void> markBillPaid(String billId, bool isPaid) async {
    await _billsRef.doc(billId).update({
      'isPaid': isPaid,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteBill(String billId) async {
    await _billsRef.doc(billId).delete();
  }
}
