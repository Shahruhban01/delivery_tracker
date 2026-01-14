import 'package:cloud_firestore/cloud_firestore.dart';

class DailySheet {
  final String id;
  final String userId;
  final DateTime date;
  final String area;
  final int totalCustomers;
  int picked;
  int delivered;
  int failed;
  int assignedReturns;
  int completedReturns;
  int failedReturns;
  double earnings;
  double petrol;
  final DateTime createdAt;
  DateTime updatedAt;

  DailySheet({
    required this.id,
    required this.userId,
    required this.date,
    required this.area,
    this.totalCustomers = 0,
    this.picked = 0,
    this.delivered = 0,
    this.failed = 0,
    this.assignedReturns = 0,
    this.completedReturns = 0,
    this.failedReturns = 0,
    this.earnings = 0.0,
    this.petrol = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailySheet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailySheet(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      area: data['area'] ?? '',
      totalCustomers: data['totalCustomers'] ?? 0,
      picked: data['picked'] ?? 0,
      delivered: data['delivered'] ?? 0,
      failed: data['failed'] ?? 0,
      assignedReturns: data['assignedReturns'] ?? 0,
      completedReturns: data['completedReturns'] ?? 0,
      failedReturns: data['failedReturns'] ?? 0,
      earnings: (data['earnings'] ?? 0).toDouble(),
      petrol: (data['petrol'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'area': area,
      'totalCustomers': totalCustomers,
      'picked': picked,
      'delivered': delivered,
      'failed': failed,
      'assignedReturns': assignedReturns,
      'completedReturns': completedReturns,
      'failedReturns': failedReturns,
      'earnings': earnings,
      'petrol': petrol,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
