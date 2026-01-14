import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String dayId;
  final String sheetType;
  final String name;
  final String address;
  final String phone;
  final String area;
  String status;
  int callCount;
  DateTime? lastCallTime;
  DateTime? lastEditedAt;
  String? notes;
  int order;
  final DateTime createdAt;
  DateTime updatedAt;

  Customer({
    required this.id,
    required this.dayId,
    this.sheetType = 'runsheet',
    required this.name,
    required this.address,
    required this.phone,
    required this.area,
    this.status = 'Pending',
    this.callCount = 0,
    this.lastCallTime,
    this.lastEditedAt,
    this.notes,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json, String dayId, int index, String sheetType) {
    return Customer(
      id: '',
      dayId: dayId,
      sheetType: sheetType,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone']?.toString().isEmpty ?? true ? '+91 1234567890' : json['phone'].toString(),
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
      sheetType: data['sheetType'] ?? 'runsheet',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '+91 1234567890',
      area: data['area'] ?? '',
      status: data['status'] ?? 'Pending',
      callCount: data['callCount'] ?? 0,
      lastCallTime: data['lastCallTime'] != null 
          ? (data['lastCallTime'] as Timestamp).toDate() 
          : null,
      lastEditedAt: data['lastEditedAt'] != null 
          ? (data['lastEditedAt'] as Timestamp).toDate() 
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
      'sheetType': sheetType,
      'name': name,
      'address': address,
      'phone': phone,
      'area': area,
      'status': status,
      'callCount': callCount,
      'lastCallTime': lastCallTime != null ? Timestamp.fromDate(lastCallTime!) : null,
      'lastEditedAt': lastEditedAt != null ? Timestamp.fromDate(lastEditedAt!) : null,
      'notes': notes,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Customer copyWith({
    String? name,
    String? address,
    String? phone,
    String? area,
    String? status,
    int? callCount,
    DateTime? lastCallTime,
    DateTime? lastEditedAt,
    String? notes,
    int? order,
  }) {
    return Customer(
      id: id,
      dayId: dayId,
      sheetType: sheetType,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      area: area ?? this.area,
      status: status ?? this.status,
      callCount: callCount ?? this.callCount,
      lastCallTime: lastCallTime ?? this.lastCallTime,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
      notes: notes ?? this.notes,
      order: order ?? this.order,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Color state logic
  CustomerColorState getColorState() {
    // Status overrides call count
    if (status == 'Delivered' || status == 'Completed') {
      return CustomerColorState.green;
    }
    if (status == 'Confirmed (will accept)') {
      return CustomerColorState.oliveGreen;
    }
    
    // Call count rules
    if (callCount >= 5) {
      return CustomerColorState.red;
    }
    if (callCount == 3 || (status != 'Delivered' && status != 'Pending')) {
      return CustomerColorState.yellow;
    }
    
    return CustomerColorState.normal;
  }
}

enum CustomerColorState {
  normal,
  yellow,
  red,
  green,
  oliveGreen,
}
