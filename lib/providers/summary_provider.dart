import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/Data/models/health_record_model.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';
import 'package:sparkle_lite/Data/models/user_model.dart';
import 'package:sparkle_lite/Data/repositiories/summary_repository.dart';
import 'package:sparkle_lite/Data/models/doctor_summary_model.dart';
import 'auth_provider.dart';

/// SummaryProvider manages the state related to doctor summaries, including loading existing summaries, generating new summaries, and saving summaries to the database. It interacts with the SummaryRepository to perform these operations and updates the UI state accordingly.
/// The provider exposes the current list of summaries, the loading and generating states, any errors that occur, and the currently generated summary data. It also provides methods to load summaries, generate a new summary based on user data, symptoms, and health records, save a generated summary, and clear the current summary from the state.
/// This provider is essential for the summary feature of the app, allowing users to easily generate and manage summaries for their doctor visits, ensuring they have all the necessary information at their fingertips when consulting with healthcare professionals.

class SummaryState {
  final bool isLoading;
  final bool isGenerating;
  final List<DoctorSummary> summaries;
  final Map<String, dynamic>? currentSummary;
  final String? error;
  
  const SummaryState({
    this.isLoading = false,
    this.isGenerating = false,
    this.summaries = const [],
    this.currentSummary,
    this.error,
  });
  
  SummaryState copyWith({
    bool? isLoading,
    bool? isGenerating,
    List<DoctorSummary>? summaries,
    Map<String, dynamic>? currentSummary,
    String? error,
  }) {
    return SummaryState(
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      summaries: summaries ?? this.summaries,
      currentSummary: currentSummary ?? this.currentSummary,
      error: error ?? this.error,
    );
  }
  
  static const initial = SummaryState();
}

class SummaryNotifier extends StateNotifier<SummaryState> {
  final SummaryRepository _repository;
  final String? _userId;
  
  SummaryNotifier(this._repository, this._userId) : super(SummaryState.initial) {
    if (_userId != null) {
      loadSummaries();
    }
  }
  
  Future<void> loadSummaries() async {
    if (_userId == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final summaries = await _repository.getDoctorSummaries(_userId);
      state = state.copyWith(
        isLoading: false,
        summaries: summaries,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<Map<String, dynamic>?> generateSummary({
    required String notes,
    required UserModel user,
    required List<SymptomLog> symptoms,
    required List<HealthRecord> records,
  }) async {
    state = state.copyWith(isGenerating: true, error: null);
    
    try {
      final summary = await _repository.generateSummary(
        user: user,
        recentSymptoms: symptoms,
        recentRecords: records,
        notes: notes,
      );
      state = state.copyWith(
        isGenerating: false,
        currentSummary: summary,
      );
      return summary;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
      );
      return null;
    }
  }
  
  Future<bool> saveSummary(Map<String, dynamic> summaryData) async {
    if (_userId == null) return false;
    
    try {
      final summary = DoctorSummary(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId,
        summaryText: summaryData['summaryText'],
        questionsForDoctor: List<String>.from(summaryData['questionsForDoctor']),
        recentSymptoms: List<String>.from(summaryData['recentSymptoms']),
        recentRecords: List<String>.from(summaryData['recentRecords']),
        currentMedications: List<String>.from(summaryData['currentMedications']),
        notes: summaryData['notes'],
        generatedDate: summaryData['generatedDate'],
        createdAt: DateTime.now(),
      );
      
      await _repository.saveDoctorSummary(summary, _userId);
      await loadSummaries();
      
      state = state.copyWith(currentSummary: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
  
  void clearCurrentSummary() {
    state = state.copyWith(currentSummary: null);
  }
}

final summaryProvider = StateNotifierProvider<SummaryNotifier, SummaryState>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id;
  final repository = ref.read(summaryRepositoryProvider);
  return SummaryNotifier(repository, userId);
});