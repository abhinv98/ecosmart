import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime earnedDate;
  final String? iconName;

  Achievement({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.earnedDate,
    this.iconName,
  });

  factory Achievement.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Achievement(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      earnedDate: (data['earnedDate'] as Timestamp).toDate(),
      iconName: data['iconName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'earnedDate': Timestamp.fromDate(earnedDate),
      'iconName': iconName,
    };
  }

  Achievement copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? earnedDate,
    String? iconName,
  }) {
    return Achievement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      earnedDate: earnedDate ?? this.earnedDate,
      iconName: iconName ?? this.iconName,
    );
  }

  @override
  String toString() {
    return 'Achievement(id: $id, userId: $userId, title: $title, description: $description, earnedDate: $earnedDate, iconName: $iconName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Achievement &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.earnedDate == earnedDate &&
        other.iconName == iconName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        earnedDate.hashCode ^
        iconName.hashCode;
  }
}
