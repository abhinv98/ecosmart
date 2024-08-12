import 'package:flutter/material.dart';
import '../models/challenge_model.dart';
import '../services/firebase_service.dart';
import 'challenge_progress_dialog.dart';
import 'leaderboard_screen.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Challenge>> _challengesFuture;

  @override
  void initState() {
    super.initState();
    _challengesFuture = _firebaseService.getActiveChallenges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Challenges'),
      ),
      body: FutureBuilder<List<Challenge>>(
        future: _challengesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No active challenges'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final challenge = snapshot.data![index];
                return ChallengeCard(
                  challenge: challenge,
                  onProgressUpdate: () => setState(() {
                    _challengesFuture = _firebaseService.getActiveChallenges();
                  }),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onProgressUpdate;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onProgressUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService().getCurrentUser();
    final userProgress =
        user != null ? (challenge.userProgress[user.uid] ?? 0) : 0;
    final progressPercentage =
        (userProgress / challenge.targetValue * 100).clamp(0, 100).toDouble();

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(challenge.title,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(challenge.description),
            const SizedBox(height: 8),
            Text('Target: ${challenge.targetValue} ${challenge.unit}'),
            const SizedBox(height: 8),
            Text('Your Progress: $userProgress ${challenge.unit}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progressPercentage / 100),
            const SizedBox(height: 8),
            Text('Ends on: ${challenge.endDate.toString().split(' ')[0]}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _logProgress(context),
                  child: const Text('Log Progress'),
                ),
                ElevatedButton(
                  onPressed: () => _viewLeaderboard(context),
                  child: const Text('View Leaderboard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _logProgress(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) =>
          ChallengeProgressDialog(challenge: challenge),
    );

    if (result == true) {
      onProgressUpdate();
    }
  }

  void _viewLeaderboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaderboardScreen(
          challengeId: challenge.id,
          challengeTitle: challenge.title,
        ),
      ),
    );
  }
}
