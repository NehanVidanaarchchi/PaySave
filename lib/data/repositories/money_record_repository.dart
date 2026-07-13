import '../firebase/firebase_money_record_service.dart';
import '../models/money_record_model.dart';

class MoneyRecordRepository {
  final FirebaseMoneyRecordService _service = FirebaseMoneyRecordService();

  Future<void> addRecord(MoneyRecordModel record) {
    return _service.addRecord(record);
  }

  Future<void> addRecords(List<MoneyRecordModel> records) {
    return _service.addRecords(records);
  }

  Future<void> updateRecord(MoneyRecordModel record) {
    return _service.updateRecord(record);
  }

  Future<void> deleteRecord(String recordId) {
    return _service.deleteRecord(recordId);
  }

  Stream<List<MoneyRecordModel>> watchRecords() {
    return _service.watchRecords();
  }

  Stream<List<MoneyRecordModel>> watchRecordsByMonth(DateTime month) {
    return _service.watchRecordsByMonth(month);
  }
}