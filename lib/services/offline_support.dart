import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ecosmart/models/activity_model.dart';
import 'package:ecosmart/services/firebase_service.dart';

class OfflineSupport {
  static const String _activitiesBoxName = 'activities';
  static Box<Activity>? _activitiesBox;
  final FirebaseService _firebaseService = FirebaseService();

  static Future<void> init() async {
    _activitiesBox = await Hive.openBox<Activity>(_activitiesBoxName);
  }

  Future<void> saveActivity(Activity activity) async {
    await _activitiesBox?.put(activity.id, activity);
    if (await _isOnline()) {
      await _firebaseService.addActivity(activity);
    }
  }

  List<Activity> getActivities() {
    return _activitiesBox?.values.toList() ?? [];
  }

  Future<void> deleteActivity(String id) async {
    await _activitiesBox?.delete(id);
    if (await _isOnline()) {
      await _firebaseService.deleteActivity(id);
    }
  }

  Future<bool> _isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> syncData() async {
    if (await _isOnline()) {
      List<Activity> localActivities = getActivities();
      for (var activity in localActivities) {
        await _firebaseService.addActivity(activity);
      }
      await _activitiesBox?.clear();
    }
  }
}
