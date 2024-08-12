import 'package:share_plus/share_plus.dart';
import '../models/achievement_model.dart';

class ShareService {
  Future<void> shareAchievement(Achievement achievement) async {
    final String shareText =
        'I just earned the "${achievement.title}" achievement in EcoSmart! ${achievement.description}';
    await Share.share(shareText, subject: 'Check out my EcoSmart achievement!');
  }

  Future<void> shareMilestone(String milestone) async {
    final String shareText =
        'I just reached a new milestone in EcoSmart! $milestone';
    await Share.share(shareText, subject: 'Check out my EcoSmart milestone!');
  }
}
