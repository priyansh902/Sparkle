import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';
import 'package:sparkle_lite/Data/repositiories/insight_repository.dart';
import 'package:sparkle_lite/Data/models/ai_insight_model.dart';
import 'package:sparkle_lite/providers/auth_provider.dart';

// State definition
class InsightState {
  final bool isLoading;
  final bool isGenerating;
  final List<AIInsight> insights;
  final Map<String, dynamic>? currentInsight;
  final String? error;
  
  const InsightState({
    this.isLoading = false,
    this.isGenerating = false,
    this.insights = const [],
    this.currentInsight,
    this.error,
  });
  
  InsightState copyWith({
    bool? isLoading,
    bool? isGenerating,
    List<AIInsight>? insights,
    Map<String, dynamic>? currentInsight,
    String? error,
  }) {
    return InsightState(
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      insights: insights ?? this.insights,
      currentInsight: currentInsight ?? this.currentInsight,
      error: error ?? this.error,
    );
  }
  
  static const initial = InsightState();
}

// Notifier
class InsightNotifier extends StateNotifier<InsightState> {
  final InsightRepository _repository;
  final String? _userId;
  
  InsightNotifier(this._repository, this._userId) : super(InsightState.initial) {
    if (_userId != null) {
      loadInsights();
    }
  }
  
  Future<void> loadInsights() async {
    if (_userId == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final insights = await _repository.getAIInsights(_userId!);
      state = state.copyWith(
        isLoading: false,
        insights: insights,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<Map<String, dynamic>?> generateInsight(List<SymptomLog> symptoms) async {
    state = state.copyWith(isGenerating: true, error: null);
    
    try {
      final insight = await _repository.generateInsight(symptoms);
      state = state.copyWith(
        isGenerating: false,
        currentInsight: insight,
      );
      return insight;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
      );
      return null;
    }
  }
  
  Future<bool> saveInsight(Map<String, dynamic> insightData) async {
    if (_userId == null) return false;
    
    state = state.copyWith(isGenerating: true, error: null);
    
    try {
      final insight = AIInsight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId!,
        summary: insightData['summary'],
        possiblePattern: insightData['possiblePattern'],
        careGuidance: insightData['careGuidance'],
        doctorQuestions: List<String>.from(insightData['doctorQuestions']),
        disclaimer: insightData['disclaimer'],
        createdAt: DateTime.now(),
        symptomsAnalyzed: List<String>.from(insightData['symptomsAnalyzed']),
        symptomsCount: insightData['symptomsCount'],
      );
      
      await _repository.saveAIInsight(insight, _userId!);
      await loadInsights();
      
      state = state.copyWith(
        isGenerating: false,
        currentInsight: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
      );
      return false;
    }
  }
  
  Future<bool> deleteInsight(String id) async {
    if (_userId == null) return false;
    
    try {
      await _repository.deleteAIInsight(id, _userId!);
      await loadInsights();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
  
  void clearCurrentInsight() {
    state = state.copyWith(currentInsight: null);
  }
}

// Provider
final insightProvider = StateNotifierProvider<InsightNotifier, InsightState>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id;
  final repository = ref.read(insightRepositoryProvider);
  return InsightNotifier(repository, userId);
});