import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import '../models/activity_model.dart';
import '../models/user_profile_model.dart';
import '../models/goal_model.dart';
import '../models/achievement_model.dart';
import '../models/challenge_model.dart';
import 'security_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SecurityService _securityService = SecurityService();

  // Activity-related methods
  Future<void> addActivity(Activity activity) async {
    try {
      await _firestore.collection('activities').add(activity.toFirestore());
    } catch (e) {
      print('Error adding activity: $e');
      rethrow;
    }
  }

  Stream<List<Activity>> getUserActivities() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('activities')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
      });
    }
    return Stream.value([]);
  }

  Future<List<Activity>> getRecentActivities(int limit) async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('activities')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
    }
    return [];
  }

  Future<List<Activity>> getAllUserActivities() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('activities')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
    }
    return [];
  }

  Future<void> updateActivity(Activity activity) async {
    try {
      await _firestore
          .collection('activities')
          .doc(activity.id)
          .update(activity.toFirestore());
    } catch (e) {
      print('Error updating activity: $e');
      rethrow;
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      await _firestore.collection('activities').doc(activityId).delete();
    } catch (e) {
      print('Error deleting activity: $e');
      rethrow;
    }
  }

  // User profile-related methods
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.id)
          .set(profile.toFirestore());
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        return await getUserProfile(user.uid);
      }
      return null;
    } catch (e) {
      print('Error getting current user profile: $e');
      rethrow;
    }
  }

  Future<void> createUserProfile(User user, String name) async {
    try {
      final newProfile = UserProfile(
        id: user.uid,
        name: name,
        email: user.email ?? '',
        photoUrl: user.photoURL,
        location: '',
        interests: [],
      );
      await updateUserProfile(newProfile);
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // Goal-related methods
  Future<void> setGoal(Goal goal) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final goalData = goal.toFirestore()..['userId'] = user.uid;
        if (goal.id.isEmpty) {
          await _firestore.collection('goals').add(goalData);
        } else {
          await _firestore.collection('goals').doc(goal.id).set(goalData);
        }
      } catch (e) {
        print('Error setting goal: $e');
        rethrow;
      }
    }
  }

  Future<Goal?> getCurrentGoal() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final snapshot = await _firestore
            .collection('goals')
            .where('userId', isEqualTo: user.uid)
            .where('endDate', isGreaterThan: Timestamp.now())
            .orderBy('endDate')
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          return Goal.fromFirestore(snapshot.docs.first);
        }
      } catch (e) {
        print('Error getting current goal: $e');
      }
    }
    return null;
  }

  // Achievement-related methods
  Future<List<Achievement>> getUserAchievements() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final snapshot = await _firestore
            .collection('achievements')
            .where('userId', isEqualTo: user.uid)
            .orderBy('earnedDate', descending: true)
            .get();

        return snapshot.docs
            .map((doc) => Achievement.fromFirestore(doc))
            .toList();
      } catch (e) {
        print('Error getting user achievements: $e');
        return [];
      }
    }
    return [];
  }

  Future<void> addAchievement(Achievement achievement) async {
    try {
      await _firestore
          .collection('achievements')
          .add(achievement.toFirestore());
    } catch (e) {
      print('Error adding achievement: $e');
      rethrow;
    }
  }

  Future<String> getAchievementLink(String achievementId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://ecosmart.page.link',
      link: Uri.parse('https://ecosmart.com/achievement?id=$achievementId'),
      androidParameters: const AndroidParameters(
        packageName: 'com.example.ecosmart',
        minimumVersion: 0,
      ),
      // Add iOS parameters if needed
    );

    final ShortDynamicLink shortDynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    return shortDynamicLink.shortUrl.toString();
  }

  // Challenge-related methods
  Future<List<Challenge>> getActiveChallenges() async {
    try {
      final snapshot = await _firestore
          .collection('challenges')
          .where('endDate', isGreaterThan: Timestamp.now())
          .orderBy('endDate')
          .get();

      return snapshot.docs.map((doc) => Challenge.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting active challenges: $e');
      return [];
    }
  }

  Future<void> joinChallenge(String challengeId, String userId) async {
    try {
      await _firestore.collection('challengeParticipants').add({
        'challengeId': challengeId,
        'userId': userId,
        'joinDate': Timestamp.now(),
        'score': 0,
      });
    } catch (e) {
      print('Error joining challenge: $e');
      rethrow;
    }
  }

  Future<void> updateChallengeProgress(String challengeId, int progress) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('challenges').doc(challengeId).update({
          'userProgress.${user.uid}': FieldValue.increment(progress),
        });
      } catch (e) {
        print('Error updating challenge progress: $e');
        rethrow;
      }
    }
  }

  Future<List<Map<String, dynamic>>> getChallengeLeaderboard(
      String challengeId) async {
    try {
      final challengeDoc =
          await _firestore.collection('challenges').doc(challengeId).get();
      if (!challengeDoc.exists) {
        throw Exception('Challenge not found');
      }

      final Challenge challenge = Challenge.fromFirestore(challengeDoc);
      final userProgress = challenge.userProgress;

      List<Map<String, dynamic>> leaderboard = [];
      for (var entry in userProgress.entries) {
        final userId = entry.key;
        final progress = entry.value;

        final userDoc = await _firestore.collection('users').doc(userId).get();
        String userName = 'Unknown User';
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null && userData.containsKey('name')) {
            userName = userData['name'] as String;
          }
        }

        leaderboard.add({
          'userId': userId,
          'name': userName,
          'progress': progress,
        });
      }

      leaderboard.sort((a, b) => b['progress'].compareTo(a['progress']));
      return leaderboard;
    } catch (e) {
      print('Error getting challenge leaderboard: $e');
      rethrow;
    }
  }

  // Authentication methods using SecurityService
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result =
          await _securityService.secureSignIn(email, password);
      return result.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  Future<User?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _securityService.secureStore('uid', result.user!.uid);
      return result.user;
    } catch (e) {
      print('Error registering: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _securityService.secureSignOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> get userStream => _auth.authStateChanges();

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }
}
