import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/customer.dart';
import '../models/daily_sheet.dart';
import '../models/call_log.dart';
import '../models/status_change.dart';
import '../models/user_settings.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  FirestoreService(this.userId);

  CollectionReference get _runsheets =>
      _db.collection('users').doc(userId).collection('runsheets');

  CollectionReference get _pickupSheets =>
      _db.collection('users').doc(userId).collection('pickupSheets');

  CollectionReference get _customers =>
      _db.collection('users').doc(userId).collection('customers');

  CollectionReference get _callLogs =>
      _db.collection('users').doc(userId).collection('callLogs');

  CollectionReference get _statusChanges =>
      _db.collection('users').doc(userId).collection('statusChanges');

  DocumentReference get _settingsDoc =>
      _db.collection('users').doc(userId).collection('settings').doc(userId);

  CollectionReference _getSheetsCollection(SheetType type) {
    return type == SheetType.runsheet ? _runsheets : _pickupSheets;
  }

  // Status classification helpers
  bool _isDelivered(String s) => s == 'Delivered';
  bool _isPending(String s) => s == 'Pending';
  bool _isConfirmed(String s) => s == 'Confirmed (will accept)';
  bool _isFailed(String s) =>
      !_isPending(s) && !_isDelivered(s) && !_isConfirmed(s);

  // OPTIMIZED: Stream all sheets (runsheets + pickups) with realtime counts
  Stream<List<DailySheet>> getAllSheets() {
    final runsheetsStream = _runsheets
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => DailySheet.fromFirestore(d)).toList());

    final pickupStream = _pickupSheets
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => DailySheet.fromFirestore(d)).toList());

    return Rx.combineLatest2<List<DailySheet>, List<DailySheet>,
        List<DailySheet>>(
      runsheetsStream,
      pickupStream,
      (runs, pickups) {
        final all = <DailySheet>[];
        all.addAll(runs);
        all.addAll(pickups);
        all.sort((a, b) => b.date.compareTo(a.date));
        return all;
      },
    );
  }

  Stream<List<DailySheet>> getSheetsByType(SheetType type) {
    return _getSheetsCollection(type)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DailySheet.fromFirestore(doc)).toList());
  }

  Future<String> createSheet(DailySheet sheet) async {
    final doc = await _getSheetsCollection(sheet.type).add(sheet.toFirestore());
    return doc.id;
  }

  Future<void> updateSheet(
      String id, SheetType type, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _getSheetsCollection(type).doc(id).update(data);
  }

  // OPTIMIZED: Close sheet with batch write
  Future<void> closeSheet(String sheetId, SheetType type) async {
    final batch = _db.batch();

    batch.update(_getSheetsCollection(type).doc(sheetId), {
      'status': SheetStatus.closed.name,
      'closedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });

    await batch.commit();
  }

  // OPTIMIZED: Get customers with single query
  Stream<List<Customer>> getCustomersByDay(String dayId) {
    return _customers
        .where('dayId', isEqualTo: dayId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList());
  }

  Future<String> createCustomer(Customer customer) async {
    final doc = await _customers.add(customer.toFirestore());
    return doc.id;
  }

  Future<void> updateCustomer(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _customers.doc(id).update(data);
  }

  // OPTIMIZED: Edit customer with lastEditedAt tracking
  Future<void> editCustomerDetails(
    String id, {
    String? name,
    String? phone,
    String? address,
    String? area,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': Timestamp.now(),
      'lastEditedAt': Timestamp.now(),
    };

    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (address != null) updates['address'] = address;
    if (area != null) updates['area'] = area;

    await _customers.doc(id).update(updates);
  }

  Future<void> updateCustomerOrder(String id, int order) async {
    await _customers.doc(id).update({
      'order': order,
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<List<CallLog>> getCallLogsByCustomer(String customerId) {
    return _callLogs
        .where('customerId', isEqualTo: customerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CallLog.fromFirestore(doc)).toList());
  }

  Future<void> createCallLog(CallLog log) async {
    await _callLogs.add(log.toFirestore());
  }

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

  // OPTIMIZED: Batch create customers
  Future<void> batchCreateCustomers(List<Customer> customers) async {
    final batch = _db.batch();
    for (final customer in customers) {
      final docRef = _customers.doc();
      batch.set(docRef, customer.toFirestore());
    }
    await batch.commit();
  }

  // ========== EXACT INCREMENTAL STATUS TRACKING ==========

  /// Called when customer status changes - updates sheet counts incrementally
  Future<void> updateSheetCountsAndEarnings({
    required DailySheet sheet,
    required String oldStatus,
    required String newStatus,
  }) async {
    int delivered = sheet.delivered;
    int failed = sheet.failed;

    // Remove old status contribution
    if (_isDelivered(oldStatus)) {
      delivered = (delivered - 1).clamp(0, 999999);
    } else if (_isFailed(oldStatus)) {
      failed = (failed - 1).clamp(0, 999999);
    }
    // Pending and Confirmed don't affect delivered/failed

    // Add new status contribution
    if (_isDelivered(newStatus)) {
      delivered += 1;
    } else if (_isFailed(newStatus)) {
      failed += 1;
    }
    // Pending and Confirmed don't affect delivered/failed

    // Calculate earnings based on delivered count
    final settings = await getSettings().first;
    final earnings = delivered * settings.earningPerParcel;

    await updateSheet(
      sheet.id,
      sheet.type,
      {
        'delivered': delivered,
        'failed': failed,
        'earnings': earnings,
      },
    );
  }

  // Settings
  Stream<UserSettings> getSettings() {
    return _settingsDoc.snapshots().map((doc) {
      if (!doc.exists) {
        return UserSettings.defaultSettings(userId);
      }
      return UserSettings.fromFirestore(doc);
    });
  }

  Future<void> updateSettings(UserSettings settings) async {
    await _settingsDoc.set(settings.toFirestore(), SetOptions(merge: true));
  }

  // ========== ANALYTICS ==========

  Future<List<DailySheet>> getSheetsByDateRange(
      DateTime start, DateTime end) async {
    final runsheetsSnap = await _runsheets
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date')
        .get();

    final pickupsSnap = await _pickupSheets
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date')
        .get();

    final sheets = <DailySheet>[];
    for (final doc in [...runsheetsSnap.docs, ...pickupsSnap.docs]) {
      sheets.add(DailySheet.fromFirestore(doc));
    }

    sheets.sort((a, b) => a.date.compareTo(b.date));
    return sheets;
  }

  Future<Map<String, dynamic>> getDeliveryAnalytics(
    DateTime startDate,
    DateTime endDate,
    SheetType? type,
  ) async {
    Query query = type == null
        ? _db.collectionGroup('runsheets')
        : _getSheetsCollection(type) as Query;

    final sheets = await query
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    int totalDelivered = 0, totalFailed = 0, totalPicked = 0;

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
      'successRate':
          totalPicked > 0 ? (totalDelivered / totalPicked * 100) : 0.0,
    };
  }

  Future<Map<String, dynamic>> getReturnsAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final sheets = await _pickupSheets
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    int totalAssigned = 0, totalCompleted = 0, totalFailed = 0;

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
      'completionRate':
          totalAssigned > 0 ? (totalCompleted / totalAssigned * 100) : 0.0,
    };
  }

  Future<Map<String, dynamic>> getFuelAnalytics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final runsheetsSnap = await _runsheets
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    final pickupsSnap = await _pickupSheets
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    double totalPetrol = 0.0;
    int days = 0;

    for (final doc in [...runsheetsSnap.docs, ...pickupsSnap.docs]) {
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
