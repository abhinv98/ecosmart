import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../screens/achievement_sharing_screen.dart';
import '../services/firebase_service.dart';

class AchievementList extends StatefulWidget {
  final bool showAll;

  const AchievementList({super.key, this.showAll = false});

  @override
  _AchievementListState createState() => _AchievementListState();
}

class _AchievementListState extends State<AchievementList> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Achievement>> _achievementsFuture;

  @override
  void initState() {
    super.initState();
    _achievementsFuture = _firebaseService.getUserAchievements();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Achievement>>(
      future: _achievementsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        } else if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCard();
        } else {
          return _buildAchievementsList(snapshot.data!);
        }
      },
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Error loading achievements: $error'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'No achievements yet. Keep up the good work!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsList(List<Achievement> achievements) {
    final displayedAchievements =
        widget.showAll ? achievements : achievements.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (!widget.showAll && achievements.length > 3)
                  TextButton(
                    onPressed: () {
                      // Navigate to a full achievements screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementList(showAll: true),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedAchievements.length,
              itemBuilder: (context, index) {
                final achievement = displayedAchievements[index];
                return ListTile(
                  leading: Icon(Icons.emoji_events,
                      color: Theme.of(context).primaryColor),
                  title: Text(achievement.title),
                  subtitle: Text(achievement.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AchievementSharingScreen(
                              achievement: achievement),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
