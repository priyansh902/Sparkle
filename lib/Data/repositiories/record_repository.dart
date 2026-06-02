import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/core/interfaces/database_interface.dart';
import 'package:sparkle_lite/core/services/firebase_database_service.dart';
// import 'package:sparkle_lite/core/services/mock_database_service.dart';
import 'package:sparkle_lite/Data/models/health_record_model.dart';

/// Repository for managing health records
/// This repository abstracts the database operations related to health records, providing a clean API for the rest of the app to interact with.
/// It interacts with the DatabaseInterface, allowing for different implementations (e.g., local storage, remote database) without changing the app logic.
final recordRepositoryProvider = Provider<RecordRepository>((ref) {

  // final databaseService = MockDatabaseService();

  final databaseService = FirebaseDatabaseService();

  return RecordRepository(databaseService: databaseService);
});

/// Repository class that abstracts database operations for health records
class RecordRepository {
  final DatabaseInterface databaseService;
  
  RecordRepository({required this.databaseService});
  
  Future<List<HealthRecord>> getHealthRecords(String userId) async {
    return await databaseService.getHealthRecords(userId);
  }
  
  Future<HealthRecord?> getHealthRecordById(String id, String userId) async {
    return await databaseService.getHealthRecordById(id, userId);
  }
  
  /// Validates and saves a health record to the database
  Future<void> saveHealthRecord(HealthRecord record, String userId) async {
    // Validation
    if (record.title.trim().isEmpty) {
      throw Exception('Title is required');
    }
    if (record.recordType == RecordType.other && record.title == 'Other') {
      throw Exception('Please specify a title for "Other" record type');
    }
    
    await databaseService.saveHealthRecord(record, userId);
  }
  
  Future<void> updateHealthRecord(HealthRecord record, String userId) async {
    await databaseService.updateHealthRecord(record, userId);
  }
  
  Future<void> deleteHealthRecord(String id, String userId) async {
    await databaseService.deleteHealthRecord(id, userId);
  }
  
  Future<List<HealthRecord>> getRecentHealthRecords(String userId, {int limit = 3}) async {
    return await databaseService.getRecentHealthRecords(userId, limit: limit);
  }
  
  Future<List<HealthRecord>> getHealthRecordsByType(String userId, RecordType type) async {
    return await databaseService.getHealthRecordsByType(userId, type);
  }
}