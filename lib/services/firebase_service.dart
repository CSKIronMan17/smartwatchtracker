// lib/services/firebase_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/health_record.dart';

class FirebaseService {
  static const String _baseUrl = 'YOUR_FIREBASE_FUNCTIONS_BASE_URL';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> syncHealthRecords(List<HealthRecord> records) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/syncHealthRecords'),
        headers: headers,
        body: jsonEncode({
          'records': records.map((r) => r.toMap()).toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to sync records: ${response.body}');
      }
    } catch (e) {
      print('Error syncing health records: $e');
      rethrow;
    }
  }

  Future<List<HealthRecord>> getHealthRecords({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final queryParams = {
        if (startDate != null)
          'startDate': startDate.toIso8601String(),
        if (endDate != null)
          'endDate': endDate.toIso8601String(),
        'limit': limit.toString(),
      };

      final response = await http.get(
        Uri.parse('$_baseUrl/getHealthRecords').replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get records: ${response.body}');
      }

      final data = jsonDecode(response.body);
      return (data['records'] as List)
        .map((record) => HealthRecord.fromMap(record))
        .toList();
    } catch (e) {
      print('Error getting health records: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getHealthStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final queryParams = {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      final response = await http.get(
        Uri.parse('$_baseUrl/getHealthStats').replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get stats: ${response.body}');
      }

      final data = jsonDecode(response.body);
      return data['stats'];
    } catch (e) {
      print('Error getting health stats: $e');
      rethrow;
    }
  }
}