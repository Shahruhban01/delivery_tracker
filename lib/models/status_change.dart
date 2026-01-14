import 'package:cloud_firestore/cloud_firestore.dart';

class StatusChange {
  final String id;
  final String customerId;
  final String dayId;
  final String oldStatus;
  final String newStatus;
  final String? notes;
  final DateTime timestamp;

  StatusChange({
    required this.id,
    required this.customerId,
    required this.dayId,
    required this.oldStatus,
    required this.newStatus,
    this.notes,
    required this.timestamp,
  });

  factory StatusChange.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StatusChange(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      dayId: data['dayId'] ?? '',
      oldStatus: data['oldStatus'] ?? '',
      newStatus: data['newStatus'] ?? '',
      notes: data['notes'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'dayId': dayId,
      'oldStatus': oldStatus,
      'newStatus': newStatus,
      'notes': notes,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
