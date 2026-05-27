import '../../core/services/notification_service.dart';
import '../firebase/firebase_bill_service.dart';
import '../models/bill_model.dart';

class BillRepository {
  final FirebaseBillService _billService = FirebaseBillService();

  Future<void> addBill(BillModel bill) async {
    await _billService.addBill(bill);

    await NotificationService.instance.scheduleReminder(
      id: bill.notificationId,
      title: 'Bill reminder',
      body: '${bill.billName} is due soon. Amount: Rs. ${bill.amount}',
      scheduledDate: bill.reminderDateTime,
    );
  }

  Future<void> updateBill(BillModel bill) async {
    await _billService.updateBill(bill);

    await NotificationService.instance.cancelNotification(bill.notificationId);

    if (!bill.isPaid) {
      await NotificationService.instance.scheduleReminder(
        id: bill.notificationId,
        title: 'Bill reminder',
        body: '${bill.billName} is due soon. Amount: Rs. ${bill.amount}',
        scheduledDate: bill.reminderDateTime,
      );
    }
  }

  Future<BillModel?> getBillById(String billId) async {
    return _billService.getBillById(billId);
  }

  Stream<List<BillModel>> watchBills() {
    return _billService.watchBills();
  }

  Stream<List<BillModel>> watchUpcomingBills() {
    return _billService.watchUpcomingBills();
  }

  Future<void> markBillPaid(String billId, bool isPaid) async {
    await _billService.markBillPaid(billId, isPaid);
  }

  Future<void> deleteBill(BillModel bill) async {
    await NotificationService.instance.cancelNotification(bill.notificationId);
    await _billService.deleteBill(bill.id);
  }
}
