import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firebase_service.dart';
import '../services/carbon_footprint_calculator.dart';
import '../models/activity_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Activity> _recentActivities = [];
  double _totalFootprint = 0.0;
  List<String> _sustainabilityTips = [];
  Map<String, double> _footprintByCategory = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final activities = await _firebaseService.getRecentActivities(10);
    final totalFootprint =
        CarbonFootprintCalculator.calculateTotalFootprint(activities);
    final footprintByCategory =
        CarbonFootprintCalculator.calculateFootprintByCategory(activities);
    final tips =
        CarbonFootprintCalculator.getSustainabilityTips(footprintByCategory);

    setState(() {
      _recentActivities = activities;
      _totalFootprint = totalFootprint;
      _sustainabilityTips = tips;
      _footprintByCategory = footprintByCategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildCarbonFootprintCard(),
            const SizedBox(height: 20),
            _buildCarbonFootprintChart(),
            const SizedBox(height: 20),
            _buildQuickActionsGrid(),
            const SizedBox(height: 20),
            _buildSustainabilityTips(),
            const SizedBox(height: 20),
            _buildRecentActivitiesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Eco Warrior!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              'Let\'s make a positive impact today!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarbonFootprintCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Carbon Footprint',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              '${_totalFootprint.toStringAsFixed(2)} kg CO2e',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              CarbonFootprintCalculator.getFootprintDescription(
                  _totalFootprint),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarbonFootprintChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Carbon Footprint by Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _footprintByCategory.entries.map((entry) {
                    return PieChartSectionData(
                      color: _getCategoryColor(entry.key),
                      value: entry.value,
                      title: '${entry.key}\n${entry.value.toStringAsFixed(1)}',
                      radius: 100,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _buildActionCard('Log Activity', Icons.add_circle_outline),
        _buildActionCard('View Progress', Icons.bar_chart),
        _buildActionCard('Eco Tips', Icons.lightbulb_outline),
        _buildActionCard('Settings', Icons.settings),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Implement navigation to respective screens
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSustainabilityTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sustainability Tips',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Column(
              children: _sustainabilityTips
                  .map((tip) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.eco,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(child: Text(tip)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentActivities.length,
              itemBuilder: (context, index) {
                final activity = _recentActivities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(_getCategoryIcon(activity.category),
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(activity.description),
                  subtitle: Text('${activity.category} - ${activity.quantity}'),
                  trailing: Text(
                    '${CarbonFootprintCalculator.calculateFootprint(activity).toStringAsFixed(2)} kg CO2e',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Transportation':
        return Colors.blue;
      case 'Energy':
        return Colors.orange;
      case 'Food':
        return Colors.green;
      case 'Waste':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Transportation':
        return Icons.directions_car;
      case 'Energy':
        return Icons.bolt;
      case 'Food':
        return Icons.restaurant;
      case 'Waste':
        return Icons.delete;
      default:
        return Icons.category;
    }
  }
}
