import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/core/interfaces/database_interface.dart';
import 'package:sparkle_lite/core/services/mock_database_service.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';

/// SymptomRepository provides an abstraction layer over the database service for managing symptom logs. It handles business logic, validation, and data transformations.
final symptomRepositoryProvider = Provider<SymptomRepository>((ref) {
  final databaseService = MockDatabaseService();
  return SymptomRepository(databaseService: databaseService);
});

class SymptomRepository {
  final DatabaseInterface databaseService;
  
  SymptomRepository({required this.databaseService});
  
  Future<List<SymptomLog>> getSymptoms(String userId) async {
    return await databaseService.getSymptoms(userId);
  }
  
  Future<SymptomLog?> getSymptomById(String id, String userId) async {
    return await databaseService.getSymptomById(id, userId);
  }
  
  Future<void> saveSymptom(SymptomLog symptom, String userId) async {
    // Validation before saving
    if (!SymptomLog.isValidPainLevel(symptom.painLevel)) {
      throw Exception('Invalid pain level. Must be between 0 and 10.');
    }
    if (!SymptomLog.isValidSymptoms(symptom.symptoms)) {
      throw Exception('At least one symptom must be selected.');
    }
    
    await databaseService.saveSymptom(symptom, userId);
  }
  
  Future<void> updateSymptom(SymptomLog symptom, String userId) async {
    await databaseService.updateSymptom(symptom, userId);
  }
  
  Future<void> deleteSymptom(String id, String userId) async {
    await databaseService.deleteSymptom(id, userId);
  }
  
  Future<List<SymptomLog>> getRecentSymptoms(String userId, {int limit = 3}) async {
    return await databaseService.getRecentSymptoms(userId, limit: limit);
  }
  
  Future<List<SymptomLog>> getSymptomsByDateRange(
    String userId, 
    DateTime start, 
    DateTime end,
  ) async {
    return await databaseService.getSymptomsByDateRange(userId, start, end);
  }
}