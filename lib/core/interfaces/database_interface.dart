import 'package:sparkle_lite/Data/models/ai_insight_model.dart';
import 'package:sparkle_lite/Data/models/health_record_model.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';

/// Abstract interface for database operations
/// This allows for different implementations (e.g., local storage, remote database) without changing the app logic
/// TODO: Define specific exceptions for different error cases (e.g., record not found, validation error)
/// TODO: Add methods for batch operations if needed (e.g., bulk delete, bulk update)
abstract class DatabaseInterface {
  // Symptom methods
  Future<List<SymptomLog>> getSymptoms(String userId);

  Future<SymptomLog?> getSymptomById(String id, String userId);

  Future<void> saveSymptom(SymptomLog symptom, String userId);

  Future<void> updateSymptom(SymptomLog symptom, String userId);

  Future<void> deleteSymptom(String id, String userId);

  Future<List<SymptomLog>> getRecentSymptoms(String userId, {int limit});

  Future<List<SymptomLog>> getSymptomsByDateRange(
    String userId, 
    DateTime start, 
    DateTime end,
  );

/// Health Record methods
  Future<List<HealthRecord>> getHealthRecords(String userId);

  Future<HealthRecord?> getHealthRecordById(String id, String userId);

  Future<void> saveHealthRecord(HealthRecord record, String userId);

  Future<void> updateHealthRecord(HealthRecord record, String userId);

  Future<void> deleteHealthRecord(String id, String userId);

  Future<List<HealthRecord>> getRecentHealthRecords(String userId, {int limit});

  Future<List<HealthRecord>> getHealthRecordsByType(String userId, RecordType type);

  Future<List<AIInsight>> getAIInsights(String userId);

  Future<void> saveAIInsight(AIInsight insight, String userId);
  
  Future<void> deleteAIInsight(String id, String userId);
  
}