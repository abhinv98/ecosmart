import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../theme/theme_provider.dart';
import '../services/firebase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _auth = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  bool _notificationsEnabled = true;
  String _selectedUnits = 'Metric';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _selectedUnits = prefs.getString('units') ?? 'Metric';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString('units', _selectedUnits);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSettingSection(
            title: 'Account',
            children: [
              ListTile(
                title: const Text('Edit Profile'),
                leading: const Icon(Icons.person),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to profile editing screen
                },
              ),
              ListTile(
                title: const Text('Change Password'),
                leading: const Icon(Icons.lock),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement change password functionality
                },
              ),
            ],
          ),
          _buildSettingSection(
            title: 'Preferences',
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveSettings();
                },
              ),
              ListTile(
                title: const Text('App Theme'),
                subtitle: Text(_getThemeModeName(themeProvider.themeMode)),
                leading: const Icon(Icons.palette),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showThemeDialog(themeProvider);
                },
              ),
              ListTile(
                title: const Text('Units'),
                subtitle: Text(_selectedUnits),
                leading: const Icon(Icons.straighten),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showUnitsDialog();
                },
              ),
            ],
          ),
          _buildSettingSection(
            title: 'Data Management',
            children: [
              ListTile(
                title: const Text('Export Data'),
                leading: const Icon(Icons.cloud_download),
                onTap: () {
                  _exportData();
                },
              ),
              ListTile(
                title: const Text('Delete Account'),
                leading: const Icon(Icons.delete_forever),
                onTap: () {
                  // TODO: Implement account deletion functionality
                },
              ),
            ],
          ),
          _buildSettingSection(
            title: 'About',
            children: [
              ListTile(
                title: const Text('Privacy Policy'),
                leading: const Icon(Icons.privacy_tip),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to privacy policy screen or open web link
                },
              ),
              ListTile(
                title: const Text('Terms of Service'),
                leading: const Icon(Icons.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to terms of service screen or open web link
                },
              ),
              const ListTile(
                title: Text('App Version'),
                leading: Icon(Icons.info),
                trailing: Text(
                    '1.0.0'), // TODO: Implement dynamic version retrieval
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text('Log Out'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _showThemeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption('System', ThemeMode.system, themeProvider),
              _buildThemeOption('Light', ThemeMode.light, themeProvider),
              _buildThemeOption('Dark', ThemeMode.dark, themeProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
      String title, ThemeMode themeMode, ThemeProvider themeProvider) {
    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: themeMode,
      groupValue: themeProvider.themeMode,
      onChanged: (ThemeMode? value) {
        if (value != null) {
          themeProvider.setThemeMode(value);
          Navigator.of(context).pop();
        }
      },
    );
  }

  void _showUnitsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Units'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUnitsOption('Metric'),
              _buildUnitsOption('Imperial'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnitsOption(String units) {
    return RadioListTile<String>(
      title: Text(units),
      value: units,
      groupValue: _selectedUnits,
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            _selectedUnits = value;
          });
          _saveSettings();
          Navigator.of(context).pop();
        }
      },
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  Future<void> _exportData() async {
    try {
      final activities = await _firebaseService.getUserActivities().first;
      final List<List<dynamic>> rows = [
        ['Category', 'Description', 'Quantity', 'Timestamp']
      ];
      for (var activity in activities) {
        rows.add([
          activity.category,
          activity.description,
          activity.quantity,
          activity.timestamp.toIso8601String(),
        ]);
      }
      String csv = const ListToCsvConverter().convert(rows);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/ecosmart_data.csv');
      await file.writeAsString(csv);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data exported to ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error exporting data')),
      );
    }
  }
}
