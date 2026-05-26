import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/core/interfaces/database_interface.dart';


class MockDatabaseService implements DatabaseInterface {
  // In-memory cache for performance
  final Map<String, List<SymptomLog>> _symptomCache = {};
  
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
}