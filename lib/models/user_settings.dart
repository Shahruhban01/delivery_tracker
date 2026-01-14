import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettings {
  final String userId;
  bool darkMode;
  double defaultPetrolCost;
  double earningPerParcel;
  bool enableConfirmations;
  DateTime updatedAt;

  UserSettings({
    required this.userId,
    this.darkMode = false,
    this.defaultPetrolCost = 0.0,
    this.earningPerParcel = 15.0,
    this.enableConfirmations = true,
    required this.updatedAt,
  });

  factory UserSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserSettings(
      userId: doc.id,
      darkMode: data['darkMode'] ?? false,
      defaultPetrolCost: (data['defaultPetrolCost'] ?? 0.0).toDouble(),
      earningPerParcel: (data['earningPerParcel'] ?? 15.0).toDouble(),
      enableConfirmations: data['enableConfirmations'] ?? true,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'darkMode': darkMode,
      'defaultPetrolCost': defaultPetrolCost,
      'earningPerParcel': earningPerParcel,
      'enableConfirmations': enableConfirmations,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserSettings.defaultSettings(String userId) {
    return UserSettings(
      userId: userId,
      earningPerParcel: 15.0,
      updatedAt: DateTime.now(),
    );
  }
}
