import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/core/interfaces/database_interface.dart';
import 'package:sparkle_lite/core/services/mock_database_service.dart';
import 'package:sparkle_lite/Data/models/family_member_model.dart';

/// This file contains the FamilyRepository and FamilyNotifier for managing family member data. The FamilyRepository abstracts the data access layer, while the FamilyNotifier manages the state of the family members in the app. The familyProvider is a StateNotifierProvider that allows the UI to interact with the family member state and perform actions like loading, adding, updating, and deleting family members.
/// The FamilyState class holds the current list of family members along with loading and error states for UI feedback. The FamilyNotifier class handles the business logic for loading family members, adding new members, updating existing members, and deleting members. It updates the FamilyState accordingly to reflect changes in the UI. The FamilyRepository interacts with the database service to persist family member data, and includes validation to ensure that required fields are provided when adding or updating family members.

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  final databaseService = MockDatabaseService();
  return FamilyRepository(databaseService: databaseService);
});

class FamilyRepository {
  final DatabaseInterface databaseService;
  
  FamilyRepository({required this.databaseService});
  
  /// Get all family members for a user
  Future<List<FamilyMember>> getFamilyMembers(String userId) async {
    try {
      return await databaseService.getFamilyMembers(userId);
    } catch (e) {
      throw Exception('Failed to load family members: $e');
    }
  }
  
  /// Get a single family member by ID
  Future<FamilyMember?> getFamilyMemberById(String id, String userId) async {
    try {
      final members = await databaseService.getFamilyMembers(userId);
      try {
        return members.firstWhere((member) => member.id == id);
      } catch (e) {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to load family member: $e');
    }
  }
  
  /// Add a new family member
  Future<void> saveFamilyMember(FamilyMember member, String userId) async {
    // Validation
    if (member.name.trim().isEmpty) {
      throw Exception('Name is required');
    }
    if (member.ageRange.isEmpty) {
      throw Exception('Age range is required');
    }
    
    try {
      await databaseService.saveFamilyMember(member, userId);
    } catch (e) {
      throw Exception('Failed to save family member: $e');
    }
  }
  
  /// Update an existing family member
  Future<void> updateFamilyMember(FamilyMember member, String userId) async {
    // Validation
    if (member.name.trim().isEmpty) {
      throw Exception('Name is required');
    }
    if (member.id.isEmpty) {
      throw Exception('Member ID is required for update');
    }
    
    try {
      await databaseService.updateFamilyMember(member, userId);
    } catch (e) {
      throw Exception('Failed to update family member: $e');
    }
  }
  
  /// Delete a family member
  Future<void> deleteFamilyMember(String id, String userId) async {
    if (id.isEmpty) {
      throw Exception('Member ID is required for deletion');
    }
    
    try {
      await databaseService.deleteFamilyMember(id, userId);
    } catch (e) {
      throw Exception('Failed to delete family member: $e');
    }
  }
  
  /// Get family members by relationship type
  Future<List<FamilyMember>> getFamilyMembersByRelationship(
    String userId, 
    Relationship relationship,
  ) async {
    try {
      final members = await databaseService.getFamilyMembers(userId);
      return members.where((member) => member.relationship == relationship).toList();
    } catch (e) {
      throw Exception('Failed to filter family members: $e');
    }
  }
}