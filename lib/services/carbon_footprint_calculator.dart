import '../models/activity_model.dart';

class CarbonFootprintCalculator {
  // CO2e emissions factors (in kg CO2e per unit)
  static const Map<String, Map<String, double>> _emissionFactors = {
    'Transportation': {
      'Car': 0.2, // per km
      'Bus': 0.1, // per km
      'Train': 0.05, // per km
      'Plane': 0.25, // per km
    },
    'Energy': {
      'Electricity': 0.5, // per kWh
      'Natural Gas': 0.2, // per kWh
    },
    'Waste': {
      'Landfill': 0.5, // per kg
      'Recycling': 0.1, // per kg
    },
    'Food': {
      'Beef': 27.0, // per kg
      'Chicken': 6.9, // per kg
      'Vegetables': 2.0, // per kg
    },
  };

  static double calculateFootprint(Activity activity) {
    final categoryFactors = _emissionFactors[activity.category];
    if (categoryFactors == null) {
      print('Unknown category: ${activity.category}');
      return 0.0;
    }

    final factor =
        categoryFactors[activity.description] ?? categoryFactors.values.first;
    return factor * activity.quantity;
  }

  static double calculateTotalFootprint(List<Activity> activities) {
    return activities.fold(
        0.0, (total, activity) => total + calculateFootprint(activity));
  }

  static Map<String, double> calculateFootprintByCategory(
      List<Activity> activities) {
    final footprints = <String, double>{};
    for (final activity in activities) {
      final footprint = calculateFootprint(activity);
      footprints[activity.category] =
          (footprints[activity.category] ?? 0.0) + footprint;
    }
    return footprints;
  }

  static String getFootprintDescription(double footprint) {
    if (footprint < 100) {
      return 'Low impact';
    } else if (footprint < 500) {
      return 'Moderate impact';
    } else if (footprint < 1000) {
      return 'High impact';
    } else {
      return 'Very high impact';
    }
  }

  static List<String> getSustainabilityTips(
      Map<String, double> footprintByCategory) {
    final tips = <String>[];
    final sortedCategories = footprintByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedCategories.take(2)) {
      switch (entry.key) {
        case 'Transportation':
          tips.add(
              'Consider using public transport or carpooling to reduce your transportation footprint.');
          break;
        case 'Energy':
          tips.add(
              'Try to use energy-efficient appliances and turn off lights when not in use.');
          break;
        case 'Waste':
          tips.add(
              'Increase your recycling efforts and try to reduce single-use plastics.');
          break;
        case 'Food':
          tips.add(
              'Consider incorporating more plant-based meals into your diet to reduce your food footprint.');
          break;
      }
    }

    return tips;
  }
}
