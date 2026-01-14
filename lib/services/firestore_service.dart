import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';
import '../models/daily_sheet.dart';
import '../models/call_log.dart';
import '../models/status_change.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  FirestoreService(this.userId);

  CollectionReference get _dailySheets => 
      _db.collection('users').doc(userId).collection('dailySheets');
  
  CollectionReference get _customers => 
      _db.collection('users').doc(userId).collection('customers');
  
  CollectionReference get _callLogs => 
      _db.collection('users').doc(userId).collection('callLogs');
  
  CollectionReference get _statusChanges => 
      _db.collection('users').doc(userId).collection('statusChanges');

  // Daily Sheets
  Stream<List<DailySheet>> getDailySheets() {
    return _dailySheets
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DailySheet.fromFirestore(doc))
            .toList());
  }

  Future<String> createDailySheet(DailySheet sheet) async {
    final doc = await _dailySheets.add(sheet.toFirestore());
    return doc.id;
  }

  Future<void> updateDailySheet(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _dailySheets.doc(id).update(data);
  }

  // Customers
  Stream<List<Customer>> getCustomersByDay(String dayId) {
    return _customers
        .where('dayId', isEqualTo: dayId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Customer.fromFirestore(doc))
            .toList());
  }

  Future<String> createCustomer(Customer customer) async {
    final doc = await _customers.add(customer.toFirestore());
    return doc.id;
  }

  Future<void> updateCustomer(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _customers.doc(id).update(data);
  }

  Future<void> updateCustomerOrder(String id, int order) async {
    await _customers.doc(id).update({
      'order': order,
      'updatedAt': Timestamp.now(),
    });
  }

  // Call Logs
  Stream<List<CallLog>> getCallLogsByCustomer(String customerId) {
    return _callLogs
        .where('customerId', isEqualTo: customerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CallLog.fromFirestore(doc))
            .toList());
  }

  Future<void> createCallLog(CallLog log) async {
    await _callLogs.add(log.toFirestore());
  }

  // Status Changes
  Stream<List<StatusChange>> getStatusChangesByCustomer(String customerId) {
    return _statusChanges
        .where('customerId', isEqualTo: customerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StatusChange.fromFirestore(doc))
            .toList());
  }

  Future<void> createStatusChange(StatusChange change) async {
    await _statusChanges.add(change.toFirestore());
  }

  // Bulk operations
  Future<void> batchCreateCustomers(List<Customer> customers) async {
    final batch = _db.batch();
    for (final customer in customers) {
      final docRef = _customers.doc();
      batch.set(docRef, customer.toFirestore());
    }
    await batch.commit();
  }

  // Analytics queries
  Future<Map<String, dynamic>> getDeliveryAnalytics(DateTime startDate, DateTime endDate) async {
    final sheets = await _dailySheets
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    int totalDelivered = 0;
    int totalFailed = 0;
    int totalPicked = 0;

    for (final doc in sheets.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalDelivered += (data['delivered'] ?? 0) as int;
      totalFailed += (data['failed'] ?? 0) as int;
      totalPicked += (data['picked'] ?? 0) as int;
    }

    return {
      'totalDelivered': totalDelivered,
      'totalFailed': totalFailed,
      'totalPicked': totalPicked,
      'successRate': totalPicked > 0 ? (totalDelivered / totalPicked * 100) : 0.0,
    };
  }

  Future<Map<String, dynamic>> getReturnsAnalytics(DateTime startDate, DateTime endDate) async {
    final sheets = await _dailySheets
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    int totalAssigned = 0;
    int totalCompleted = 0;
    int totalFailed = 0;

    for (final doc in sheets.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalAssigned += (data['assignedReturns'] ?? 0) as int;
      totalCompleted += (data['completedReturns'] ?? 0) as int;
      totalFailed += (data['failedReturns'] ?? 0) as int;
    }

    return {
      'totalAssigned': totalAssigned,
      'totalCompleted': totalCompleted,
      'totalFailed': totalFailed,
      'completionRate': totalAssigned > 0 ? (totalCompleted / totalAssigned * 100) : 0.0,
    };
  }

  Future<Map<String, dynamic>> getFuelAnalytics(DateTime startDate, DateTime endDate) async {
    final sheets = await _dailySheets
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    double totalPetrol = 0.0;
    int days = 0;

    for (final doc in sheets.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalPetrol += (data['petrol'] ?? 0.0) as double;
      days++;
    }

    return {
      'totalPetrol': totalPetrol,
      'averagePerDay': days > 0 ? (totalPetrol / days) : 0.0,
      'days': days,
    };
  }
}
