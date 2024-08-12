import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firebase_service.dart';
import '../services/carbon_footprint_calculator.dart';
import '../models/activity_model.dart';
import '../models/goal_model.dart';
import '../widgets/goal_setting_dialog.dart';
import '../widgets/achievement_list.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  _ProgressTrackingScreenState createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Activity> _activities = [];
  Map<String, double> _footprintByCategory = {};
  List<FlSpot> _weeklyFootprint = [];
  double _totalFootprint = 0;
  String _selectedTimeRange = 'Week';
  Goal? _currentGoal;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final activities = await _firebaseService.getUserActivities().first;
    final goal = await _firebaseService.getCurrentGoal();
    setState(() {
      _activities = activities;
      _footprintByCategory =
          CarbonFootprintCalculator.calculateFootprintByCategory(_activities);
      _totalFootprint =
          CarbonFootprintCalculator.calculateTotalFootprint(_activities);
      _currentGoal = goal;
    });
    _generateWeeklyFootprintData();
  }

  void _generateWeeklyFootprintData() {
    // Generate dummy data for the line chart
    _weeklyFootprint = List.generate(7, (index) {
      return FlSpot(index.toDouble(), (index * 2 + 10).toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProgressData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProgressData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeRangeSelector(),
                const SizedBox(height: 20),
                _buildTotalFootprintCard(),
                const SizedBox(height: 20),
                _buildCurrentGoalCard(),
                const SizedBox(height: 20),
                _buildWeeklyProgressChart(),
                const SizedBox(height: 20),
                _buildCategoryBreakdownChart(),
                const SizedBox(height: 20),
                const AchievementList(),
                const SizedBox(height: 20),
                _buildRecentActivitiesList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<String>(
          value: _selectedTimeRange,
          decoration: const InputDecoration(
            labelText: 'Time Range',
            border: InputBorder.none,
          ),
          items: ['Week', 'Month', 'Year'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTimeRange = newValue;
                // Here you would typically reload data for the new time range
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildTotalFootprintCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Carbon Footprint',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${_totalFootprint.toStringAsFixed(2)} kg CO2e',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentGoalCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Goal',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (_currentGoal != null)
              Text(
                '${_currentGoal!.description}: ${_currentGoal!.targetValue} ${_currentGoal!.unit}',
                style: Theme.of(context).textTheme.bodyLarge,
              )
            else
              Text(
                'No current goal set',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showGoalSettingDialog,
              child: Text(_currentGoal == null ? 'Set a Goal' : 'Update Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Mon');
                            case 3:
                              return const Text('Thu');
                            case 6:
                              return const Text('Sun');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 30,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _weeklyFootprint,
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
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
                      titleStyle: const TextStyle(
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
              itemCount: _activities.length.clamp(0, 5),
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return ListTile(
                  leading: Icon(_getCategoryIcon(activity.category),
                      color: Theme.of(context).primaryColor),
                  title: Text(activity.description),
                  subtitle: Text('${activity.category} - ${activity.quantity}'),
                  trailing: Text(
                    '${CarbonFootprintCalculator.calculateFootprint(activity).toStringAsFixed(2)} kg CO2e',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
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

  void _showGoalSettingDialog() async {
    final goal = await showDialog<Goal>(
      context: context,
      builder: (BuildContext context) =>
          GoalSettingDialog(currentGoal: _currentGoal),
    );

    if (goal != null) {
      await _firebaseService.setGoal(goal);
      setState(() {
        _currentGoal = goal;
      });
    }
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
