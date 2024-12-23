// lib/services/sync_service.dart
import 'dart:async';
import '../repositories/health_repository.dart';
import 'firebase_service.dart';

class SyncService {
  final HealthRepository _healthRepository;
  final FirebaseService _firebaseService;
  Timer? _syncTimer;

  SyncService(this._healthRepository, this._firebaseService);

  void startPeriodicSync({Duration interval = const Duration(minutes: 30)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) => syncData());
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<void> syncData() async {
    try {
      // Get unsynced records
      final records = await _healthRepository.getHealthRecords(
        syncedOnly: false,
        limit: 100,
      );

      if (records.isEmpty) return;

      // Sync with backend
      await _firebaseService.syncHealthRecords(records);

      // Mark records as synced
      await _healthRepository.markRecordsAsSynced(
        records.map((r) => r.id).toList(),
      );
    } catch (e) {
      print('Error during sync: $e');
      // Handle sync errors (maybe retry later)
    }
  }
}