import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkle_lite/Data/models/ai_insight_model.dart';
import 'package:sparkle_lite/Data/models/health_record_model.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/core/interfaces/database_interface.dart';

/// A mock database service for testing and development purposes.
/// This simulates database operations using SharedPreferences for persistence and in-memory caching for performance.
/// It provides methods for managing symptom logs and health records, including CRUD operations and querying by date range and type.
/// TODO: Implement more robust error handling and validation logic.
/// TODO: Add support for batch operations and more complex queries in the future.
class MockDatabaseService implements DatabaseInterface {
  // In-memory cache for performance
  final Map<String, List<SymptomLog>> _symptomCache = {};
  final Map<String, List<HealthRecord>> _recordCache = {};
  final Map<String, List<AIInsight>> _insightCache = {};
  
  /// Symptom Methods
  @override
  Future<List<SymptomLog>> getSymptoms(String userId) async {
    // Check cache first
    if (_symptomCache.containsKey(userId)) {
      return _symptomCache[userId]!;
    }
    
    // Load from storage
    final prefs = await SharedPreferences.getInstance();
    final String? symptomsJson = prefs.getString('${AppConstants.keySymptoms}_$userId');
    
    if (symptomsJson == null) {
      return [];
    }
    
    final List<dynamic> decoded = json.decode(symptomsJson);
    final symptoms = decoded.map((item) => SymptomLog.fromJson(item)).toList();
    
    // Sort by date (newest first)
    symptoms.sort((a, b) => b.date.compareTo(a.date));
    
    // Update cache
    _symptomCache[userId] = symptoms;
    
    return symptoms;
  }
  
  @override
  Future<SymptomLog?> getSymptomById(String id, String userId) async {
    final symptoms = await getSymptoms(userId);
    try {
      return symptoms.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> saveSymptom(SymptomLog symptom, String userId) async {
    final symptoms = await getSymptoms(userId);
    final updatedSymptoms = [symptom, ...symptoms];
    
    await _saveSymptomsToStorage(userId, updatedSymptoms);
    
    // Update cache
    _symptomCache[userId] = updatedSymptoms;
  }
  
  @override
  Future<void> updateSymptom(SymptomLog symptom, String userId) async {
    final symptoms = await getSymptoms(userId);
    final index = symptoms.indexWhere((s) => s.id == symptom.id);
    
    if (index != -1) {
      symptoms[index] = symptom;
      await _saveSymptomsToStorage(userId, symptoms);
      _symptomCache[userId] = symptoms;
    }
  }
  
  @override
  Future<void> deleteSymptom(String id, String userId) async {
    final symptoms = await getSymptoms(userId);
    final updatedSymptoms = symptoms.where((s) => s.id != id).toList();
    
    await _saveSymptomsToStorage(userId, updatedSymptoms);
    _symptomCache[userId] = updatedSymptoms;
  }
  
  @override
  Future<List<SymptomLog>> getRecentSymptoms(String userId, {int limit = 3}) async {
    final symptoms = await getSymptoms(userId);
    if (symptoms.length <= limit) {
      return symptoms;
    }
    return symptoms.sublist(0, limit);
  }
  
  @override
  Future<List<SymptomLog>> getSymptomsByDateRange(
    String userId, 
    DateTime start, 
    DateTime end,
  ) async {
    final symptoms = await getSymptoms(userId);
    return symptoms.where((s) {
      return s.date.isAfter(start.subtract(const Duration(days: 1))) && 
             s.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
  
  Future<void> _saveSymptomsToStorage(String userId, List<SymptomLog> symptoms) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = symptoms.map((s) => s.toJson()).toList();
    await prefs.setString('${AppConstants.keySymptoms}_$userId', json.encode(jsonList));
  }

  /// Health Record Methods
  @override
  Future<List<HealthRecord>> getHealthRecords(String userId) async {
    // Check cache first
    if (_recordCache.containsKey(userId)) {
      return _recordCache[userId]!;
    }
    
    // Load from storage
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString('${AppConstants.keyHealthRecords}_$userId');
    
    if (recordsJson == null) {
      return [];
    }
    
    final List<dynamic> decoded = json.decode(recordsJson);
    final records = decoded.map((item) => HealthRecord.fromJson(item)).toList();
    
    // Sort by date (newest first)
    records.sort((a, b) => b.recordDate.compareTo(a.recordDate));
    
    // Update cache
    _recordCache[userId] = records;
    
    return records;
  }
  
  @override
  Future<HealthRecord?> getHealthRecordById(String id, String userId) async {
    final records = await getHealthRecords(userId);
    try {
      return records.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> saveHealthRecord(HealthRecord record, String userId) async {
    final records = await getHealthRecords(userId);
    final updatedRecords = [record, ...records];
    await _saveRecordsToStorage(userId, updatedRecords);
    _recordCache[userId] = updatedRecords;
  }
  
  @override
  Future<void> updateHealthRecord(HealthRecord record, String userId) async {
    final records = await getHealthRecords(userId);
    final index = records.indexWhere((r) => r.id == record.id);
    
    if (index != -1) {
      records[index] = record;
      await _saveRecordsToStorage(userId, records);
      _recordCache[userId] = records;
    }
  }
  
  @override
  Future<void> deleteHealthRecord(String id, String userId) async {
    final records = await getHealthRecords(userId);
    final updatedRecords = records.where((r) => r.id != id).toList();
    await _saveRecordsToStorage(userId, updatedRecords);
    _recordCache[userId] = updatedRecords;
  }
  
  @override
  Future<List<HealthRecord>> getRecentHealthRecords(String userId, {int limit = 3}) async {
    final records = await getHealthRecords(userId);
    if (records.length <= limit) return records;
    return records.sublist(0, limit);
  }
  
  @override
  Future<List<HealthRecord>> getHealthRecordsByType(String userId, RecordType type) async {
    final records = await getHealthRecords(userId);
    return records.where((r) => r.recordType == type).toList();
  }
  
  Future<void> _saveRecordsToStorage(String userId, List<HealthRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((r) => r.toJson()).toList();
    await prefs.setString('${AppConstants.keyHealthRecords}_$userId', json.encode(jsonList));
  }

  /// AI Insight Methods


  @override
  Future<List<AIInsight>> getAIInsights(String userId) async {
    // Check cache first
    if (_insightCache.containsKey(userId)) {
      return _insightCache[userId]!;
    }
    
    // Load from storage
    final prefs = await SharedPreferences.getInstance();
    final String? insightsJson = prefs.getString('${AppConstants.keyAIInsights}_$userId');
    
    if (insightsJson == null) {
      return [];
    }
    
    final List<dynamic> decoded = json.decode(insightsJson);
    final insights = decoded.map((item) => AIInsight.fromJson(item)).toList();
    
    // Sort by date (newest first)
    insights.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Update cache
    _insightCache[userId] = insights;
    
    return insights;
  }

  @override
  Future<void> saveAIInsight(AIInsight insight, String userId) async {
    final insights = await getAIInsights(userId);
    final updatedInsights = [insight, ...insights];
    await _saveInsightsToStorage(userId, updatedInsights);
    _insightCache[userId] = updatedInsights;
  }

  @override
  Future<void> deleteAIInsight(String id, String userId) async {
    final insights = await getAIInsights(userId);
    final updatedInsights = insights.where((i) => i.id != id).toList();
    await _saveInsightsToStorage(userId, updatedInsights);
    _insightCache[userId] = updatedInsights;
  }

  Future<void> _saveInsightsToStorage(String userId, List<AIInsight> insights) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = insights.map((i) => i.toJson()).toList();
    await prefs.setString('${AppConstants.keyAIInsights}_$userId', json.encode(jsonList));
  }

}