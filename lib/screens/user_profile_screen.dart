import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/user_profile_model.dart';
import '../models/challenge_model.dart';
import '../models/achievement_model.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<UserProfile?> _userProfileFuture;
  late Future<List<Challenge>> _userChallengesFuture;
  late Future<List<Achievement>> _userAchievementsFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _firebaseService.getCurrentUserProfile();
    _userChallengesFuture = _firebaseService.getActiveChallenges();
    _userAchievementsFuture = _firebaseService.getUserAchievements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserProfile(),
              const SizedBox(height: 24),
              _buildUserChallenges(),
              const SizedBox(height: 24),
              _buildUserAchievements(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return FutureBuilder<UserProfile?>(
      future: _userProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null) {
          return const Text('No user profile found');
        } else {
          final profile = snapshot.data!;
          return Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: profile.photoUrl != null
                    ? NetworkImage(profile.photoUrl!)
                    : null,
                child: profile.photoUrl == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(profile.name,
                  style: Theme.of(context).textTheme.headlineSmall),
              Text(profile.email,
                  style: Theme.of(context).textTheme.titleMedium),
              if (profile.location != null && profile.location!.isNotEmpty)
                Text(profile.location!,
                    style: Theme.of(context).textTheme.titleSmall),
            ],
          );
        }
      },
    );
  }

  Widget _buildUserChallenges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Challenges', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        FutureBuilder<List<Challenge>>(
          future: _userChallengesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Text('No challenges joined yet');
            } else {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final challenge = snapshot.data![index];
                  return ListTile(
                    title: Text(challenge.title),
                    subtitle: Text(challenge.description),
                    trailing: Text(
                        '${challenge.endDate.difference(DateTime.now()).inDays} days left'),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildUserAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Achievements', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        FutureBuilder<List<Achievement>>(
          future: _userAchievementsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Text('No achievements earned yet');
            } else {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final achievement = snapshot.data![index];
                  return ListTile(
                    leading: const Icon(Icons.emoji_events),
                    title: Text(achievement.title),
                    subtitle: Text(achievement.description),
                    trailing:
                        Text(achievement.earnedDate.toString().split(' ')[0]),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }
}
