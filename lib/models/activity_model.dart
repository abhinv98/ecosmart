import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 0)
class Activity {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final double quantity;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final String? recommendation;

  Activity({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.quantity,
    required this.timestamp,
    this.recommendation,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      recommendation: data['recommendation'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'description': description,
      'quantity': quantity,
      'timestamp': Timestamp.fromDate(timestamp),
      'recommendation': recommendation,
    };
  }
}
