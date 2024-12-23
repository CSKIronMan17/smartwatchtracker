// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/bluetooth_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsService _settingsService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    _settingsService = await SettingsService.create();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildDeviceSection(),
          const Divider(),
          _buildNotificationsSection(),
          const Divider(),
          _buildDataSection(),
          const Divider(),
          _buildAppearanceSection(),
          const Divider(),
          _buildAccountSection(),
        ],
      ),
    );
  }

  Widget _buildDeviceSection() {
    final bluetoothService = context.watch<BluetoothService>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Device',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: const Text('Smartwatch Connection'),
          subtitle: Text(
            bluetoothService.isConnected ? 'Connected' : 'Disconnected',
          ),
          leading: const Icon(Icons.watch),
          trailing: Switch(
            value: bluetoothService.isConnected,
            onChanged: (value) async {
              if (value) {
                await bluetoothService.connect();
              } else {
                await bluetoothService.disconnect();
              }
            },
          ),
        ),
        if (bluetoothService.isConnected)
          ListTile(
            title: const Text('Forget Device'),
            leading: const Icon(Icons.link_off),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Forget Device'),
                  content: const Text(
                    'Are you sure you want to forget this device? '
                    'You\'ll need to pair it again to use it.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Forget'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await bluetoothService.disconnect();
                // Add logic to forget the device
              }
            },
          ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Get alerts for important health events'),
          value: _settingsService.notificationsEnabled,
          onChanged: (value) async {
            await _settingsService.setNotificationsEnabled(value);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Data & Sync',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Auto-sync Data'),
          subtitle: const Text('Automatically sync health data to the cloud'),
          value: _settingsService.dataSyncEnabled,
          onChanged: (value) async {
            await _settingsService.setDataSyncEnabled(value);
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('Sync Interval'),
          subtitle: Text('${_settingsService.syncInterval} minutes'),
          leading: const Icon(Icons.sync),
          onTap: _showSyncIntervalDialog,
        ),
        ListTile(
          title: const Text('Daily Step Goal'),
          subtitle: Text('${_settingsService.dailyStepGoal} steps'),
          leading: const Icon(Icons.directions_walk),
          onTap: _showStepGoalDialog,
        ),
        ListTile(
          title: const Text('Export Health Data'),
          subtitle: const Text('Download your health data as CSV'),
          leading: const Icon(Icons.download),
          onTap: () {
            // Implement export functionality
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Appearance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Toggle dark theme'),
          value: _settingsService.darkModeEnabled,
          onChanged: (value) async {
            await _settingsService.setDarkModeEnabled(value);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: Text(user?.email ?? 'Not signed in'),
          subtitle: const Text('Google Account'),
          leading: const Icon(Icons.account_circle),
        ),
        ListTile(
          title: const Text('Sign Out'),
          leading: const Icon(Icons.exit_to_app),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await authService.signOut();
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            }
          },
        ),
      ],
    );
  }

  Future<void> _showSyncIntervalDialog() async {
    final controller = TextEditingController(
      text: _settingsService.syncInterval.toString(),
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Interval'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minutes',
            hintText: 'Enter sync interval in minutes',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                await _settingsService.setSyncInterval(value);
                setState(() {});
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showStepGoalDialog() async {
    final controller = TextEditingController(
      text: _settingsService.dailyStepGoal.toString(),
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Step Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Steps',
            hintText: 'Enter daily step goal',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                await _settingsService.setDailyStepGoal(value);
                setState(() {});
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}