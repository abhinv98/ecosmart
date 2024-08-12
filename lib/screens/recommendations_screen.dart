import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/activity_model.dart';
import '../widgets/recommendation_card.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Activity> _activities = [];
  String _selectedCategory = 'All';
  String _selectedTimeRange = 'All Time';

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final activities = await _firebaseService.getAllUserActivities();
    setState(() {
      _activities = activities;
    });
  }

  List<Activity> _getFilteredActivities() {
    return _activities.where((activity) {
      bool categoryMatch =
          _selectedCategory == 'All' || activity.category == _selectedCategory;
      bool timeMatch = _selectedTimeRange == 'All Time' ||
          _isInTimeRange(activity.timestamp);
      return categoryMatch && timeMatch;
    }).toList();
  }

  bool _isInTimeRange(DateTime timestamp) {
    final now = DateTime.now();
    switch (_selectedTimeRange) {
      case 'Last Week':
        return timestamp.isAfter(now.subtract(const Duration(days: 7)));
      case 'Last Month':
        return timestamp.isAfter(now.subtract(const Duration(days: 30)));
      case 'Last Year':
        return timestamp.isAfter(now.subtract(const Duration(days: 365)));
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredActivities = _getFilteredActivities();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco-Friendly Recommendations'),
      ),
      body: Column(
        children: [
          _buildFilterOptions(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredActivities.length,
              itemBuilder: (context, index) {
                return RecommendationCard(activity: filteredActivities[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _selectedCategory,
              items: ['All', 'Transportation', 'Energy', 'Waste', 'Food']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedTimeRange,
              items: ['All Time', 'Last Week', 'Last Month', 'Last Year']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTimeRange = newValue;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
