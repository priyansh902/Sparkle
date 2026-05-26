import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/core/interfaces/database_interface.dart';
import 'package:sparkle_lite/core/services/mock_database_service.dart';
import 'package:sparkle_lite/core/services/mock_ai_service.dart';
import 'package:sparkle_lite/Data/models/ai_insight_model.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';

/// Repository for managing AI insights, including fetching, saving, deleting, and generating insights based on symptom logs.
/// This repository abstracts the data layer for AI insights, allowing for easy replacement of the underlying database service or AI generation logic in the future without affecting the rest of the application.
/// It interacts with the DatabaseInterface to perform CRUD operations on AI insights and uses the MockAIService to generate insights based on symptom data. The repository ensures that all operations are performed in a safe and non-diagnostic manner, adhering to the principle of providing informational insights without making any medical claims or diagnoses.

final insightRepositoryProvider = Provider<InsightRepository>((ref) {
  final databaseService = MockDatabaseService();
  return InsightRepository(databaseService: databaseService);
});

class InsightRepository {
  final DatabaseInterface databaseService;
  
  InsightRepository({required this.databaseService});
  
  Future<List<AIInsight>> getAIInsights(String userId) async {
    return await databaseService.getAIInsights(userId);
  }
  
  Future<void> saveAIInsight(AIInsight insight, String userId) async {
    await databaseService.saveAIInsight(insight, userId);
  }
  
  Future<void> deleteAIInsight(String id, String userId) async {
    await databaseService.deleteAIInsight(id, userId);
  }
  
  Future<Map<String, dynamic>> generateInsight(List<SymptomLog> symptoms) async {
    // Use mock AI service (safe, non-diagnostic)
    return MockAIService.generateInsight(symptoms);
  }
}