import 'package:flutter/material.dart';
import '../models/goal_model.dart';

class GoalSettingDialog extends StatefulWidget {
  final Goal? currentGoal;

  const GoalSettingDialog({super.key, this.currentGoal});

  @override
  _GoalSettingDialogState createState() => _GoalSettingDialogState();
}

class _GoalSettingDialogState extends State<GoalSettingDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _targetValueController;
  late String _selectedUnit;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.currentGoal?.description ?? '');
    _targetValueController = TextEditingController(
        text: widget.currentGoal?.targetValue.toString() ?? '');
    _selectedUnit = widget.currentGoal?.unit ?? 'kg CO2e';
    _startDate = widget.currentGoal?.startDate ?? DateTime.now();
    _endDate = widget.currentGoal?.endDate ??
        DateTime.now().add(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.currentGoal == null ? 'Set a New Goal' : 'Update Goal'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Goal Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _targetValueController,
                decoration: const InputDecoration(labelText: 'Target Value'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                items: ['kg CO2e', '%', 'activities'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedUnit = newValue;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text('${_startDate.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null && picked != _startDate) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('End Date'),
                subtitle: Text('${_endDate.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: _startDate,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null && picked != _endDate) {
                    setState(() {
                      _endDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final goal = Goal(
                id: widget.currentGoal?.id ?? '',
                userId: '', // This will be set in the FirebaseService
                description: _descriptionController.text,
                targetValue: double.parse(_targetValueController.text),
                unit: _selectedUnit,
                startDate: _startDate,
                endDate: _endDate,
              );
              Navigator.of(context).pop(goal);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }
}
