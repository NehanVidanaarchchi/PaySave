import '../../core/services/notification_service.dart';
import '../firebase/firebase_installment_service.dart';
import '../models/installment_model.dart';

class InstallmentRepository {
  final FirebaseInstallmentService _installmentService =
      FirebaseInstallmentService();

  Future<void> addInstallment(InstallmentModel installment) async {
    await _installmentService.addInstallment(installment);

    for (final payment in installment.payments) {
      await NotificationService.instance.scheduleReminder(
        id: payment.notificationId,
        title: 'Installment reminder',
        body:
            '${installment.purchaseName} payment ${payment.installmentNumber} is due soon. Amount: Rs. ${payment.amount}',
        scheduledDate: payment.reminderDateTime,
      );
    }
  }

  Future<void> updateInstallment(InstallmentModel installment) async {
    await _installmentService.updateInstallment(installment);

    for (final payment in installment.payments) {
      await NotificationService.instance.cancelNotification(
        payment.notificationId,
      );

      if (!payment.isPaid) {
        await NotificationService.instance.scheduleReminder(
          id: payment.notificationId,
          title: 'Installment reminder',
          body:
              '${installment.purchaseName} payment ${payment.installmentNumber} is due soon. Amount: Rs. ${payment.amount}',
          scheduledDate: payment.reminderDateTime,
        );
      }
    }
  }

  Future<InstallmentModel?> getInstallmentById(String installmentId) async {
    return _installmentService.getInstallmentById(installmentId);
  }

  Stream<List<InstallmentModel>> watchInstallments() {
    return _installmentService.watchInstallments();
  }

  Stream<List<InstallmentModel>> watchActiveInstallments() {
    return _installmentService.watchActiveInstallments();
  }

  Future<void> markPaymentPaid({
    required String installmentId,
    required String paymentId,
    required bool isPaid,
  }) async {
    await _installmentService.markPaymentPaid(
      installmentId: installmentId,
      paymentId: paymentId,
      isPaid: isPaid,
    );
  }

  Future<void> deleteInstallment(InstallmentModel installment) async {
    for (final payment in installment.payments) {
      await NotificationService.instance.cancelNotification(
        payment.notificationId,
      );
    }

    await _installmentService.deleteInstallment(installment.id);
  }
}
