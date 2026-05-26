import 'package:sparkle_lite/Data/models/symptom_log_model.dart';

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
  
}