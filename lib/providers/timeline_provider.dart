import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/Data/repositiories/timeline_repository.dart';
import 'package:sparkle_lite/Data/models/timeline_item_model.dart';
import 'auth_provider.dart';

/// State definition
/// TimelineState represents the state of the timeline feature, including loading status, list of timeline items, filtered items based on selected filter, currently selected filter type, and any error messages.
/// This state is designed to be easily extendable in the future, allowing for additional properties or filters to be added without affecting the existing structure. It provides a clear separation of concerns, with the TimelineNotifier responsible for managing the state and business logic of the timeline feature.

class TimelineState {
  final bool isLoading;
  final List<TimelineItem> items;
  final List<TimelineItem> filteredItems;
  final TimelineItemType? selectedFilter;
  final String? error;
  
  const TimelineState({
    this.isLoading = false,
    this.items = const [],
    this.filteredItems = const [],
    this.selectedFilter,
    this.error,
  });
  
  TimelineState copyWith({
    bool? isLoading,
    List<TimelineItem>? items,
    List<TimelineItem>? filteredItems,
    TimelineItemType? selectedFilter,
    String? error,
  }) {
    return TimelineState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      error: error ?? this.error,
    );
  }
  
  static const initial = TimelineState();
}

// Notifier
class TimelineNotifier extends StateNotifier<TimelineState> {
  final TimelineRepository _repository;
  final String? _userId;
  
  TimelineNotifier(this._repository, this._userId) : super(TimelineState.initial) {
    if (_userId != null) {
      loadTimeline();
    }
  }
  
  Future<void> loadTimeline() async {
    if (_userId == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final items = await _repository.getTimeline(_userId);
      state = state.copyWith(
        isLoading: false,
        items: items,
        filteredItems: items,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  void filterByType(TimelineItemType? type) {
    if (type == null) {
      state = state.copyWith(
        selectedFilter: null,
        filteredItems: state.items,
      );
    } else {
      final filtered = state.items.where((item) => item.type == type).toList();
      state = state.copyWith(
        selectedFilter: type,
        filteredItems: filtered,
      );
    }
  }
  
  Future<void> refresh() async {
    await loadTimeline();
  }
}

// Provider
final timelineProvider = StateNotifierProvider<TimelineNotifier, TimelineState>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id;
  final repository = ref.read(timelineRepositoryProvider);
  return TimelineNotifier(repository, userId);
});