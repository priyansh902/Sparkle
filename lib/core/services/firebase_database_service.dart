import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';
import 'package:sparkle_lite/Data/models/health_record_model.dart';
import 'package:sparkle_lite/Data/models/ai_insight_model.dart';
import 'package:sparkle_lite/Data/models/doctor_summary_model.dart';
import 'package:sparkle_lite/Data/models/privacy_settings_model.dart';
import 'package:sparkle_lite/Data/models/family_member_model.dart';
import '../interfaces/database_interface.dart';

class FirebaseDatabaseService implements DatabaseInterface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference _symptoms(String userId) =>
      _firestore.collection('users').doc(userId).collection('symptoms');
  
  CollectionReference _records(String userId) =>
      _firestore.collection('users').doc(userId).collection('healthRecords');
  
  CollectionReference _insights(String userId) =>
      _firestore.collection('users').doc(userId).collection('aiInsights');
  
  CollectionReference _summaries(String userId) =>
      _firestore.collection('users').doc(userId).collection('doctorSummaries');
  
  CollectionReference _family(String userId) =>
      _firestore.collection('users').doc(userId).collection('familyMembers');
  
  DocumentReference _settings(String userId) =>
      _firestore.collection('users').doc(userId).collection('settings').doc('privacy');

  // ========== SYMPTOM METHODS ==========
  
  @override
  Future<List<SymptomLog>> getSymptoms(String userId) async {
    final snapshot = await _symptoms(userId)
        .orderBy('date', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return SymptomLog.fromJson(data);
    }).toList();
  }

  @override
  Future<SymptomLog?> getSymptomById(String id, String userId) async {
    final doc = await _symptoms(userId).doc(id).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return SymptomLog.fromJson(data);
  }

  @override
  Future<void> saveSymptom(SymptomLog symptom, String userId) async {
    final data = symptom.toJson();
    data.remove('id');
    await _symptoms(userId).doc(symptom.id).set(data);
  }

  @override
  Future<void> updateSymptom(SymptomLog symptom, String userId) async {
    final data = symptom.toJson();
    data.remove('id');
    await _symptoms(userId).doc(symptom.id).update(data);
  }

  @override
  Future<void> deleteSymptom(String id, String userId) async {
    await _symptoms(userId).doc(id).delete();
  }

  @override
  Future<List<SymptomLog>> getRecentSymptoms(String userId, {int limit = 3}) async {
    final snapshot = await _symptoms(userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return SymptomLog.fromJson(data);
    }).toList();
  }

  @override
  Future<List<SymptomLog>> getSymptomsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _symptoms(userId)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('date', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return SymptomLog.fromJson(data);
    }).toList();
  }

  // ========== HEALTH RECORD METHODS ==========
  
  @override
  Future<List<HealthRecord>> getHealthRecords(String userId) async {
    final snapshot = await _records(userId)
        .orderBy('recordDate', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return HealthRecord.fromJson(data);
    }).toList();
  }

  @override
  Future<HealthRecord?> getHealthRecordById(String id, String userId) async {
    final doc = await _records(userId).doc(id).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return HealthRecord.fromJson(data);
  }

  @override
  Future<void> saveHealthRecord(HealthRecord record, String userId) async {
    final data = record.toJson();
    data.remove('id');
    await _records(userId).doc(record.id).set(data);
  }

  @override
  Future<void> updateHealthRecord(HealthRecord record, String userId) async {
    final data = record.toJson();
    data.remove('id');
    await _records(userId).doc(record.id).update(data);
  }

  @override
  Future<void> deleteHealthRecord(String id, String userId) async {
    await _records(userId).doc(id).delete();
  }

  @override
  Future<List<HealthRecord>> getRecentHealthRecords(String userId, {int limit = 3}) async {
    final snapshot = await _records(userId)
        .orderBy('recordDate', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return HealthRecord.fromJson(data);
    }).toList();
  }

  @override
  Future<List<HealthRecord>> getHealthRecordsByType(String userId, RecordType type) async {
    final snapshot = await _records(userId)
        .where('recordType', isEqualTo: type.toString().split('.').last)
        .orderBy('recordDate', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return HealthRecord.fromJson(data);
    }).toList();
  }

  // ========== AI INSIGHT METHODS ==========
  
  @override
  Future<List<AIInsight>> getAIInsights(String userId) async {
    final snapshot = await _insights(userId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return AIInsight.fromJson(data);
    }).toList();
  }

  @override
  Future<void> saveAIInsight(AIInsight insight, String userId) async {
    final data = insight.toJson();
    data.remove('id');
    await _insights(userId).doc(insight.id).set(data);
  }

  @override
  Future<void> deleteAIInsight(String id, String userId) async {
    await _insights(userId).doc(id).delete();
  }

  // ========== DOCTOR SUMMARY METHODS ==========
  
  @override
  Future<List<DoctorSummary>> getDoctorSummaries(String userId) async {
    final snapshot = await _summaries(userId)
        .orderBy('generatedDate', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return DoctorSummary.fromJson(data);
    }).toList();
  }

  @override
  Future<void> saveDoctorSummary(DoctorSummary summary, String userId) async {
    final data = summary.toJson();
    data.remove('id');
    await _summaries(userId).doc(summary.id).set(data);
  }

  @override
  Future<void> deleteDoctorSummary(String id, String userId) async {
    await _summaries(userId).doc(id).delete();
  }

  // ========== PRIVACY SETTINGS METHODS ==========
  
  @override
  Future<PrivacySettings> getPrivacySettings(String userId) async {
    final doc = await _settings(userId).get();
    if (!doc.exists) return const PrivacySettings();
    
    return PrivacySettings.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> savePrivacySettings(PrivacySettings settings, String userId) async {
    await _settings(userId).set(settings.toJson());
  }

  // ========== FAMILY MEMBER METHODS ==========
  
  @override
  Future<List<FamilyMember>> getFamilyMembers(String userId) async {
    final snapshot = await _family(userId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return FamilyMember.fromJson(data);
    }).toList();
  }

  @override
  Future<void> saveFamilyMember(FamilyMember member, String userId) async {
    final data = member.toJson();
    data.remove('id');
    await _family(userId).doc(member.id).set(data);
  }

  @override
  Future<void> updateFamilyMember(FamilyMember member, String userId) async {
    final data = member.toJson();
    data.remove('id');
    await _family(userId).doc(member.id).update(data);
  }

  @override
  Future<void> deleteFamilyMember(String id, String userId) async {
    await _family(userId).doc(id).delete();
  }
}