import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class LeaderboardScreen extends StatelessWidget {
  final String challengeId;
  final String challengeTitle;

  const LeaderboardScreen({super.key, required this.challengeId, required this.challengeTitle});

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard: $challengeTitle'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: firebaseService.getChallengeLeaderboard(challengeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No leaderboard data available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final entry = snapshot.data![index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(entry['name']),
                  trailing: Text('${entry['progress']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
