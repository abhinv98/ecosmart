import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? location;
  List<String> interests;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.location,
    List<String>? interests,
  }) : interests = interests ?? [];

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      location: data['location'],
      interests: List<String>.from(data['interests'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'location': location,
      'interests': interests,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? location,
    List<String>? interests,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      location: location ?? this.location,
      interests: interests ?? this.interests,
    );
  }
}
