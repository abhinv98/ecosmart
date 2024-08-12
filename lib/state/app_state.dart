import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_model.dart';
import '../services/firebase_service.dart';

final firebaseServiceProvider =
    Provider<FirebaseService>((ref) => FirebaseService());

final activitiesProvider = StreamProvider<List<Activity>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getUserActivities();
});

final totalFootprintProvider = Provider<double>((ref) {
  final activities = ref.watch(activitiesProvider).value ?? [];
  return activities.fold(
      0.0, (total, activity) => total + calculateFootprint(activity));
});

double calculateFootprint(Activity activity) {
  // Implement your footprint calculation logic here
  // This is a placeholder implementation
  return activity.quantity * 0.5;
}
