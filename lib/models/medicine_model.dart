class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String frequency; // e.g., "Daily"
  final DateTime startTime;
  final List<int> notificationIds; // Stores IDs for local notifications

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startTime,
    required this.notificationIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'startTime': startTime.toIso8601String(),
      'notificationIds': notificationIds,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map, String docId) {
    return Medicine(
      id: docId,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      notificationIds: List<int>.from(map['notificationIds'] ?? []),
    );
  }
}