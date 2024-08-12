import 'package:flutter/material.dart';
import '../models/challenge_model.dart';
import '../services/firebase_service.dart';

class ChallengeProgressDialog extends StatefulWidget {
  final Challenge challenge;

  const ChallengeProgressDialog({super.key, required this.challenge});

  @override
  _ChallengeProgressDialogState createState() =>
      _ChallengeProgressDialogState();
}

class _ChallengeProgressDialogState extends State<ChallengeProgressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _progressController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Progress'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _progressController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Progress (${widget.challenge.unit})',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitProgress,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  void _submitProgress() async {
    if (_formKey.currentState!.validate()) {
      final progress = int.parse(_progressController.text);
      try {
        await _firebaseService.updateChallengeProgress(
            widget.challenge.id, progress);
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update progress. Please try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }
}
