import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/core/interfaces/database_interface.dart';
import 'package:sparkle_lite/core/services/mock_database_service.dart';
import 'package:sparkle_lite/Data/models/doctor_summary_model.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';
import 'package:sparkle_lite/Data/models/health_record_model.dart';
import 'package:sparkle_lite/Data/models/user_model.dart';

/// Repository for managing doctor summaries, including fetching, saving, and generating summaries based on user data.
/// This repository abstracts the data layer and interacts with the database service to perform CRUD operations on doctor summaries.
/// It also contains logic to generate a comprehensive summary text and relevant questions for the doctor based on the user's recent symptoms and health records.
/// The `SummaryRepository` is designed to be used with Riverpod for state management, allowing for easy dependency injection and testing.

final summaryRepositoryProvider = Provider<SummaryRepository>((ref) {
  final databaseService = MockDatabaseService();
  return SummaryRepository(databaseService: databaseService);
});

class SummaryRepository {
  final DatabaseInterface databaseService;
  
  SummaryRepository({required this.databaseService});
  
  Future<List<DoctorSummary>> getDoctorSummaries(String userId) async {
    return await databaseService.getDoctorSummaries(userId);
  }
  
  Future<void> saveDoctorSummary(DoctorSummary summary, String userId) async {
    await databaseService.saveDoctorSummary(summary, userId);
  }
  
  Future<void> deleteDoctorSummary(String id, String userId) async {
    await databaseService.deleteDoctorSummary(id, userId);
  }
  
  Future<Map<String, dynamic>> generateSummary({
    required UserModel user,
    required List<SymptomLog> recentSymptoms,
    required List<HealthRecord> recentRecords,
    required String notes,
  }) async {
    final summaryText = _generateSummaryText(user, recentSymptoms, recentRecords);
    final questions = _generateQuestions(recentSymptoms, recentRecords);
    final symptomList = recentSymptoms.take(5).map((s) => 
      '${_formatDate(s.date)}: ${s.symptoms.join(', ')} (Pain: ${s.painLevel}/10)'
    ).toList();
    final recordList = recentRecords.take(5).map((r) => 
      '${r.title} (${r.recordType.displayName}) - ${_formatDate(r.recordDate)}'
    ).toList();
    
    return {
      'summaryText': summaryText,
      'questionsForDoctor': questions,
      'recentSymptoms': symptomList,
      'recentRecords': recordList,
      'currentMedications': user.medications,
      'notes': notes,
      'generatedDate': DateTime.now(),
    };
  }
  
  String _generateSummaryText(UserModel user, List<SymptomLog> symptoms, List<HealthRecord> records) {
    final buffer = StringBuffer();
    buffer.writeln('Patient: ${user.name}');
    buffer.writeln('Age Range: ${user.ageRange ?? "Not specified"}');
    buffer.writeln('Life Stage: ${user.lifeStage?.toString().split('.').last ?? "Not specified"}');
    buffer.writeln();
    buffer.writeln('Recent Symptoms (Last 30 days):');
    if (symptoms.isEmpty) {
      buffer.writeln('- No symptoms logged');
    } else {
      for (final symptom in symptoms.take(10)) {
        buffer.writeln('- ${_formatDate(symptom.date)}: ${symptom.symptoms.join(', ')} (Pain: ${symptom.painLevel}/10, Mood: ${symptom.mood.toString().split('.').last})');
      }
    }
    buffer.writeln();
    buffer.writeln('Recent Health Records:');
    if (records.isEmpty) {
      buffer.writeln('- No records uploaded');
    } else {
      for (final record in records.take(5)) {
        buffer.writeln('- ${record.title} (${record.recordType.displayName}) - ${_formatDate(record.recordDate)}');
      }
    }
    buffer.writeln();
    if (user.medications.isNotEmpty) {
      buffer.writeln('Current Medications: ${user.medications.join(', ')}');
    }
    if (user.conditions.isNotEmpty) {
      buffer.writeln('Known Conditions: ${user.conditions.join(', ')}');
    }
    
    return buffer.toString();
  }
  
  List<String> _generateQuestions(List<SymptomLog> symptoms, List<HealthRecord> records) {
    final questions = <String>[
      'What do you recommend based on my symptoms?',
      'Are there any tests you would suggest?',
      'What should I watch for in the coming weeks?',
    ];
    
    if (symptoms.any((s) => s.painLevel >= 7)) {
      questions.insert(0, 'My pain level has been high (7+/10). What pain management options are appropriate?');
    }
    if (symptoms.any((s) => s.symptoms.contains('Irregular bleeding'))) {
      questions.insert(0, 'I\'ve noticed irregular bleeding. Should I be concerned?');
    }
    if (records.isNotEmpty) {
      questions.add('Would you like to review my uploaded health records?');
    }
    
    return questions.take(6).toList();
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}