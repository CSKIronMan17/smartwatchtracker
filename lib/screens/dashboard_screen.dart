// lib/screens/dashboard_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/bluetooth_service.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final bluetoothService = context.watch<BluetoothService>();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Implement refresh logic here
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildUserCard(user),
            const SizedBox(height: 16),
            _buildConnectionStatus(bluetoothService),
            const SizedBox(height: 16),
            _buildHealthMetrics(bluetoothService),
            const SizedBox(height: 16),
            _buildDailyGoals(bluetoothService),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(User? user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? 'No email',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(BluetoothService bluetoothService) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.bluetooth,
          color: bluetoothService.isConnected ? Colors.blue : Colors.grey,
        ),
        title: Text(
          bluetoothService.isConnected
              ? 'Connected to Smartwatch'
              : 'Disconnected',
        ),
        trailing: bluetoothService.isConnected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.error_outline, color: Colors.red),
      ),
    );
  }

  Widget _buildHealthMetrics(BluetoothService bluetoothService) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.favorite,
            value: '${bluetoothService.heartRate}',
            unit: 'BPM',
            label: 'Heart Rate',
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.directions_walk,
            value: '${bluetoothService.steps}',
            unit: 'steps',
            label: 'Daily Steps',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyGoals(BluetoothService bluetoothService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressBar(
              label: 'Steps',
              current: bluetoothService.steps,
              goal: 10000,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildProgressBar(
              label: 'Active Minutes',
              current: 45,
              goal: 60,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int current,
    required int goal,
    required Color color,
  }) {
    final progress = (current / goal).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$current / $goal'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }
}