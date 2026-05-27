import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/Data/models/family_member_model.dart';
import 'package:sparkle_lite/Data/repositiories/family_repository.dart';
import 'auth_provider.dart';

/// This provider manages the user's family members, allowing them to add, view, and delete family member information. It interacts with the database through the FamilyRepository to persist data. The FamilyState class holds the current list of family members along with loading and error states for UI feedback.
/// The FamilyNotifier class handles the business logic for loading family members, adding new members, and deleting existing members. It updates the FamilyState accordingly to reflect changes in the UI. The familyProvider is a StateNotifierProvider that provides access to the FamilyNotifier and its state throughout the app.


class FamilyState {
  final bool isLoading;
  final List<FamilyMember> members;
  final String? error;
  
  const FamilyState({
    this.isLoading = false,
    this.members = const [],
    this.error,
  });
  
  FamilyState copyWith({
    bool? isLoading,
    List<FamilyMember>? members,
    String? error,
  }) {
    return FamilyState(
      isLoading: isLoading ?? this.isLoading,
      members: members ?? this.members,
      error: error ?? this.error,
    );
  }
  
  static const initial = FamilyState();
}

class FamilyNotifier extends StateNotifier<FamilyState> {
  final FamilyRepository _repository;
  final String? _userId;
  
  FamilyNotifier(this._repository, this._userId) : super(FamilyState.initial) {
    if (_userId != null) {
      loadMembers();
    }
  }
  
  Future<void> loadMembers() async {
    if (_userId == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final members = await _repository.getFamilyMembers(_userId);
      state = state.copyWith(
        isLoading: false,
        members: members,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<bool> addMember(FamilyMember member) async {
    if (_userId == null) return false;
    
    try {
      await _repository.saveFamilyMember(member, _userId);
      await loadMembers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
  
  Future<bool> updateMember(FamilyMember member) async {
    if (_userId == null) return false;
    
    try {
      await _repository.updateFamilyMember(member, _userId);
      await loadMembers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
  
  Future<bool> deleteMember(String id) async {
    if (_userId == null) return false;
    
    try {
      await _repository.deleteFamilyMember(id, _userId);
      await loadMembers();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final familyProvider = StateNotifierProvider<FamilyNotifier, FamilyState>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id;
  final repository = ref.read(familyRepositoryProvider);
  return FamilyNotifier(repository, userId);
});