import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firebase_collections.dart';
import 'firestore_service.dart';
import '../models/installment_model.dart';

class FirebaseInstallmentService {
  final FirestoreService _firestoreService = FirestoreService();

  CollectionReference<Map<String, dynamic>> get _installmentsRef {
    return _firestoreService.userCollection(FirebaseCollections.installments);
  }

  Future<void> addInstallment(InstallmentModel installment) async {
    await _installmentsRef.doc(installment.id).set(installment.toMap());
  }

  Future<void> updateInstallment(InstallmentModel installment) async {
    await _installmentsRef
        .doc(installment.id)
        .set(
          installment.copyWith(updatedAt: DateTime.now()).toMap(),
          SetOptions(merge: true),
        );
  }

  Future<InstallmentModel?> getInstallmentById(String installmentId) async {
    final snapshot = await _installmentsRef.doc(installmentId).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return InstallmentModel.fromMap(snapshot.data()!);
  }

  Stream<List<InstallmentModel>> watchInstallments() {
    return _installmentsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return InstallmentModel.fromMap(doc.data());
          }).toList();
        });
  }

  Stream<List<InstallmentModel>> watchActiveInstallments() {
    return _installmentsRef
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return InstallmentModel.fromMap(doc.data());
          }).toList();
        });
  }

  Future<void> markPaymentPaid({
    required String installmentId,
    required String paymentId,
    required bool isPaid,
  }) async {
    final installment = await getInstallmentById(installmentId);

    if (installment == null) {
      throw Exception('Installment not found');
    }

    final updatedPayments = installment.payments.map((payment) {
      if (payment.id == paymentId) {
        return payment.copyWith(isPaid: isPaid);
      }

      return payment;
    }).toList();

    final updatedInstallment = installment.copyWith(
      payments: updatedPayments,
      updatedAt: DateTime.now(),
    );

    await updateInstallment(updatedInstallment);
  }

  Future<void> deleteInstallment(String installmentId) async {
    await _installmentsRef.doc(installmentId).delete();
  }
}
