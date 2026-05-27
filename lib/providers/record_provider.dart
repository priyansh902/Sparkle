import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/Data/repositiories/record_repository.dart';
import 'package:sparkle_lite/Data/models/health_record_model.dart';
import 'auth_provider.dart';

/// State definition
/// RecordState represents the current state of health records, including loading state, list of records,
/// recent records, any error messages, and saving state. It provides a copyWith method for easy state updates and an initial factory constructor for the default state.

class RecordState {
  final bool isLoading;
  final List<HealthRecord> records;
  final List<HealthRecord> recentRecords;
  final String? error;
  final bool isSaving;
  
  const RecordState({
    this.isLoading = false,
    this.records = const [],
    this.recentRecords = const [],
    this.error,
    this.isSaving = false,
  });
  
  RecordState copyWith({
    bool? isLoading,
    List<HealthRecord>? records,
    List<HealthRecord>? recentRecords,
    String? error,
    bool? isSaving,
  }) {
    return RecordState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      recentRecords: recentRecords ?? this.recentRecords,
      error: error ?? this.error,
      isSaving: isSaving ?? this.isSaving,
    );
  }
  
  static const initial = RecordState();
}

// Notifier
class RecordNotifier extends StateNotifier<RecordState> {
  final RecordRepository _repository;
  final String? _userId;
  
  RecordNotifier(this._repository, this._userId) : super(RecordState.initial) {
    if (_userId != null) {
      loadRecords();
    }
  }
  
  Future<void> loadRecords() async {
    if (_userId == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final records = await _repository.getHealthRecords(_userId);
      final recentRecords = await _repository.getRecentHealthRecords(_userId);
      
      state = state.copyWith(
        isLoading: false,
        records: records,
        recentRecords: recentRecords,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<bool> addRecord(HealthRecord record) async {
    if (_userId == null) return false;
    
    state = state.copyWith(isSaving: true, error: null);
    
    try {
      await _repository.saveHealthRecord(record, _userId);
      await loadRecords();
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
  
  Future<bool> updateRecord(HealthRecord record) async {
    if (_userId == null) return false;
    
    state = state.copyWith(isSaving: true, error: null);
    
    try {
      await _repository.updateHealthRecord(record, _userId);
      await loadRecords();
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
  
  Future<bool> deleteRecord(String id) async {
    if (_userId == null) return false;
    
    state = state.copyWith(isSaving: true, error: null);
    
    try {
      await _repository.deleteHealthRecord(id, _userId);
      await loadRecords();
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
  
  HealthRecord? getRecordById(String id) {
    try {
      return state.records.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Provider
final recordProvider = StateNotifierProvider<RecordNotifier, RecordState>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id;
  final repository = ref.read(recordRepositoryProvider);
  return RecordNotifier(repository, userId);
});