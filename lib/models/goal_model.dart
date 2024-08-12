import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String id;
  final String userId;
  final String description;
  final double targetValue;
  final String unit;
  final DateTime startDate;
  final DateTime endDate;

  Goal({
    required this.id,
    required this.userId,
    required this.description,
    required this.targetValue,
    required this.unit,
    required this.startDate,
    required this.endDate,
  });

  factory Goal.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Goal(
      id: doc.id,
      userId: data['userId'],
      description: data['description'],
      targetValue: data['targetValue'],
      unit: data['unit'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'description': description,
      'targetValue': targetValue,
      'unit': unit,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }
}
