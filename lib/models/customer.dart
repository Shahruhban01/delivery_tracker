import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String dayId;
  final String name;
  final String address;
  final String phone;
  final String area;
  String status;
  int callCount;
  DateTime? lastCallTime;
  String? notes;
  int order;
  final DateTime createdAt;
  DateTime updatedAt;

  Customer({
    required this.id,
    required this.dayId,
    required this.name,
    required this.address,
    required this.phone,
    required this.area,
    this.status = 'Pending',
    this.callCount = 0,
    this.lastCallTime,
    this.notes,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json, String dayId, int index) {
    return Customer(
      id: '',
      dayId: dayId,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      area: json['area'] ?? '',
      order: index,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Customer(
      id: doc.id,
      dayId: data['dayId'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      area: data['area'] ?? '',
      status: data['status'] ?? 'Pending',
      callCount: data['callCount'] ?? 0,
      lastCallTime: data['lastCallTime'] != null 
          ? (data['lastCallTime'] as Timestamp).toDate() 
          : null,
      notes: data['notes'],
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dayId': dayId,
      'name': name,
      'address': address,
      'phone': phone,
      'area': area,
      'status': status,
      'callCount': callCount,
      'lastCallTime': lastCallTime != null ? Timestamp.fromDate(lastCallTime!) : null,
      'notes': notes,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Customer copyWith({
    String? status,
    int? callCount,
    DateTime? lastCallTime,
    String? notes,
    int? order,
  }) {
    return Customer(
      id: id,
      dayId: dayId,
      name: name,
      address: address,
      phone: phone,
      area: area,
      status: status ?? this.status,
      callCount: callCount ?? this.callCount,
      lastCallTime: lastCallTime ?? this.lastCallTime,
      notes: notes ?? this.notes,
      order: order ?? this.order,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
