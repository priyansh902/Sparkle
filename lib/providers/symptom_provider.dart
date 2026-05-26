import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/Data/repositiories/symptom_repository.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';
import 'auth_provider.dart';

/// State definition
/// SymptomState represents the current state of symptom logs, including loading state, list of symptoms,
/// recent symptoms, any error messages, and saving state. It provides a copyWith method for easy state updates and an initial factory constructor for the default state.
class SymptomState {
  final bool isLoading;
  final List<SymptomLog> symptoms;
  final List<SymptomLog> recentSymptoms;
  final String? error;
  final bool isSaving;
  
  const SymptomState({
    this.isLoading = false,
    this.symptoms = const [],
    this.recentSymptoms = const [],
    this.error,
    this.isSaving = false,
  });
  
  SymptomState copyWith({
    bool? isLoading,
    List<SymptomLog>? symptoms,
    List<SymptomLog>? recentSymptoms,
    String? error,
    bool? isSaving,
  }) {
    return SymptomState(
      isLoading: isLoading ?? this.isLoading,
      symptoms: symptoms ?? this.symptoms,
      recentSymptoms: recentSymptoms ?? this.recentSymptoms,
      error: error ?? this.error,
      isSaving: isSaving ?? this.isSaving,
    );
  }
  
  static const initial = SymptomState();
}

// Notifier
class SymptomNotifier extends StateNotifier<SymptomState> {
  final SymptomRepository _repository;
  final String? _userId;
  
  SymptomNotifier(this._repository, this._userId) : super(SymptomState.initial) {
    if (_userId != null) {
      loadSymptoms();
    }
  }
  
  Future<void> loadSymptoms() async {
    if (_userId == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final symptoms = await _repository.getSymptoms(_userId);
      final recentSymptoms = await _repository.getRecentSymptoms(_userId!);
      
      state = state.copyWith(
        isLoading: false,
        symptoms: symptoms,
        recentSymptoms: recentSymptoms,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<bool> addSymptom(SymptomLog symptom) async {
    if (_userId == null) return false;
    
    state = state.copyWith(isSaving: true, error: null);
    
    try {
      await _repository.saveSymptom(symptom, _userId!);
      await loadSymptoms(); // Reload to get updated list
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
      );
      return false;
    }
  }
  
  Future<bool> updateSymptom(SymptomLog symptom) async {
    if (_userId == null) return false;
    
    state = state.copyWith(isSaving: true, error: null);
    
    try {
      await _repository.updateSymptom(symptom, _userId!);
      await loadSymptoms();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
      );
      return false;
    }
  }
  
  Future<bool> deleteSymptom(String id) async {
    if (_userId == null) return false;
    
    state = state.copyWith(isSaving: true, error: null);
    
    try {
      await _repository.deleteSymptom(id, _userId!);
      await loadSymptoms();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
      );
      return false;
    }
  }
  
  SymptomLog? getSymptomById(String id) {
    try {
      return state.symptoms.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Provider - depends on auth provider to get userId
final symptomProvider = StateNotifierProvider<SymptomNotifier, SymptomState>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id;
  final repository = ref.read(symptomRepositoryProvider);
  return SymptomNotifier(repository, userId);
});