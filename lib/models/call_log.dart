import 'package:cloud_firestore/cloud_firestore.dart';

class CallLog {
  final String id;
  final String customerId;
  final String dayId;
  final int attemptNumber;
  final DateTime timestamp;

  CallLog({
    required this.id,
    required this.customerId,
    required this.dayId,
    required this.attemptNumber,
    required this.timestamp,
  });

  factory CallLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CallLog(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      dayId: data['dayId'] ?? '',
      attemptNumber: data['attemptNumber'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'dayId': dayId,
      'attemptNumber': attemptNumber,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
