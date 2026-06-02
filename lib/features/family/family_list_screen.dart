import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/Data/models/family_member_model.dart';
import 'package:sparkle_lite/providers/family_provider.dart';
import 'package:sparkle_lite/shared/widgets/empty_state_widget.dart';

/// Family List Screen - Displays user's family members and allows management
/// - Shows list of family members with relationship and age range
/// - Allows adding new family members via FAB
/// - Swipe to delete family members with confirmation dialog

class FamilyListScreen extends ConsumerWidget {
  const FamilyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(familyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Members'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              context.push(AppConstants.routeAddFamilyMember);
            },
          ),
        ],
      ),
      body: _buildBody(context, ref, familyState, isDark),
    );
  }
  
  Widget _buildBody(BuildContext context, WidgetRef ref, FamilyState state, bool isDark) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.members.isEmpty) {
      return EmptyStateWidget(
        title: 'No Family Members',
        message: 'Add family members to manage their health records',
        buttonText: 'Add Family Member',
        onButtonPressed: () {
          context.push(AppConstants.routeAddFamilyMember);
        },
        icon: Icons.family_restroom,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.members.length,
      itemBuilder: (context, index) {
        final member = state.members[index];
        return _buildFamilyCard(context, ref, member, isDark);
      },
    );
  }
  
  Widget _buildFamilyCard(BuildContext context, WidgetRef ref, FamilyMember member, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: Dismissible(
        key: Key(member.id),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Remove Family Member'),
              content: Text('Are you sure you want to remove ${member.name}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Remove'),
                ),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (direction) async {
          await ref.read(familyProvider.notifier).deleteMember(member.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Family member removed')),
            );
          }
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF7B61FF).withOpacity(isDark ? 0.2 : 0.1),
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
              style: const TextStyle(color: Color(0xFF7B61FF), fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            member.displayName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.relationship.displayName,
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              if (member.ageRange.isNotEmpty)
                Text(
                  'Age: ${member.ageRange}',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[500]),
                ),
            ],
          ),
          trailing: Icon(Icons.chevron_right, color: isDark ? Colors.grey[600] : Colors.grey[400]),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Member details coming soon')),
            );
          },
        ),
      ),
    );
  }
}