// lib/services/bluetooth_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

class BluetoothService extends ChangeNotifier {
  bool _isConnected = false;
  int _heartRate = 0;
  int _steps = 0;
  Timer? _dataTimer;

  bool get isConnected => _isConnected;
  int get heartRate => _heartRate;
  int get steps => _steps;

  Future<void> connect() async {
    // Simulate Bluetooth connection
    await Future.delayed(const Duration(seconds: 2));
    _isConnected = true;
    _startDataFetching();
    notifyListeners();
  }

  Future<void> disconnect() async {
    _dataTimer?.cancel();
    _isConnected = false;
    notifyListeners();
  }

  void _startDataFetching() {
    _dataTimer?.cancel();
    _dataTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // Simulate data updates
      _heartRate = 60 + (DateTime.now().second % 20);
      _steps += 10;
      notifyListeners();
    });
  }
}