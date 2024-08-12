import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/achievement_model.dart';
import '../services/firebase_service.dart';
import '../services/share_service.dart';

class AchievementSharingScreen extends StatelessWidget {
  final Achievement achievement;
  final FirebaseService _firebaseService = FirebaseService();
  final ShareService _shareService = ShareService();

  AchievementSharingScreen({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Achievement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events,
                        size: 64, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 16),
                    Text(achievement.title,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(achievement.description,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Share on Social Media'),
              onPressed: () => _shareAchievement(context),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copy Achievement Link'),
              onPressed: () => _copyAchievementLink(context),
            ),
          ],
        ),
      ),
    );
  }

  void _shareAchievement(BuildContext context) async {
    try {
      await _shareService.shareAchievement(achievement);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Achievement shared successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to share achievement. Please try again.')),
      );
    }
  }

  void _copyAchievementLink(BuildContext context) async {
    try {
      String link = await _firebaseService.getAchievementLink(achievement.id);
      await Clipboard.setData(ClipboardData(text: link));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Achievement link copied to clipboard')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Failed to copy achievement link. Please try again.')),
      );
    }
  }
}
