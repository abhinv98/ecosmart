import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/activity_model.dart';
import '../services/gemini_service.dart';
import '../config/config.dart';
import '../services/carbon_footprint_calculator.dart';

class ActivityInputScreen extends StatefulWidget {
  const ActivityInputScreen({Key? key}) : super(key: key);

  @override
  _ActivityInputScreenState createState() => _ActivityInputScreenState();
}

class _ActivityInputScreenState extends State<ActivityInputScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GeminiService _geminiService = GeminiService(Config.geminiApiKey);

  String _selectedCategory = 'Transportation';
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();

  final List<String> _categories = [
    'Transportation',
    'Energy',
    'Waste',
    'Food'
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Activity'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log Your Eco-Friendly Activity',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                _buildCategorySelector(),
                const SizedBox(height: 20),
                _buildDescriptionInput(),
                const SizedBox(height: 20),
                _buildQuantityInput(),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: _categories.map<DropdownMenuItem<String>>((String value) {
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
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildDescriptionInput() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }

  Widget _buildQuantityInput() {
    return TextFormField(
      controller: _quantityController,
      decoration: InputDecoration(
        labelText: 'Quantity',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a quantity';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text('Log Activity'),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = _auth.currentUser;
      if (user != null) {
        final activity = Activity(
          id: '', // Firestore will generate this
          userId: user.uid,
          category: _selectedCategory,
          description: _descriptionController.text,
          quantity: double.parse(_quantityController.text),
          timestamp: DateTime.now(),
        );

        try {
          // Calculate carbon footprint
          double carbonFootprint =
              CarbonFootprintCalculator.calculateFootprint(activity);

          // Generate recommendation using Gemini API
          String recommendation = await _geminiService.generateRecommendation(
              '${activity.category}: ${activity.description}',
              carbonFootprint.toString());

          // Update the activity with the recommendation
          final updatedActivity = Activity(
            id: activity.id,
            userId: activity.userId,
            category: activity.category,
            description: activity.description,
            quantity: activity.quantity,
            timestamp: activity.timestamp,
            recommendation: recommendation,
          );

          await _firebaseService.addActivity(updatedActivity);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Activity logged successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );

          // Show recommendation dialog
          _showRecommendationDialog(recommendation);

          // Clear form after submission
          _descriptionController.clear();
          _quantityController.clear();
          setState(() {
            _selectedCategory = 'Transportation'; // Reset to default category
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Error logging activity. Please try again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You must be logged in to log an activity.')),
        );
      }
    }
  }

  void _showRecommendationDialog(String recommendation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eco-Friendly Recommendation'),
          content: Text(recommendation),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
