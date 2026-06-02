import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/Data/models/family_member_model.dart';
import 'package:sparkle_lite/providers/auth_provider.dart';
import 'package:sparkle_lite/providers/family_provider.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';
import 'package:sparkle_lite/shared/widgets/form_text_field.dart';

/// This screen allows users to add a new family member to their account. It includes fields for the family member's name, relationship, age range, and optional notes. The data is saved to the database and associated with the user's account.
/// The screen also includes a privacy note to reassure users that family member data is kept separate from their personal health records. The form validates required fields and provides feedback on successful addition of a family member.
/// This screen is accessible from the Family List screen via an "Add" button in the app bar. After successfully adding a family member, the user is navigated back to the Family List screen where the new member will be displayed.

class AddFamilyMemberScreen extends ConsumerStatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  ConsumerState<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends ConsumerState<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  Relationship _selectedRelationship = Relationship.other;
  String _selectedAgeRange = '18-24';
  bool _isSaving = false;

  final List<String> _ageRanges = [
    '0-2', '3-5', '6-12', '13-17', '18-24', '25-30', '31-35', 
    '36-40', '41-45', '46-50', '50+',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMember() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;
      
      if (userId == null) return;
      
      final newMember = FamilyMember(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim(),
        relationship: _selectedRelationship,
        ageRange: _selectedAgeRange,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: DateTime.now(),
      );
      
      final success = await ref.read(familyProvider.notifier).addMember(newMember);
      
      setState(() => _isSaving = false);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Family member added')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Family Member'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Privacy note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.family_restroom, color: isDark ? Colors.blue[300] : Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Family member data is kept separate from your personal health records for privacy.',
                        style: TextStyle(
                          color: isDark ? Colors.blue[300] : Colors.blue[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Name
              FormTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Nickname
              FormTextField(
                controller: _nicknameController,
                label: 'Nickname (Optional)',
                prefixIcon: Icons.label,
              ),
              const SizedBox(height: 16),
              
              // Relationship
              Text(
                'Relationship',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Relationship>(
                value: _selectedRelationship,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                  labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                items: Relationship.values.map((rel) {
                  return DropdownMenuItem(
                    value: rel,
                    child: Text(
                      rel.displayName,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRelationship = value ?? Relationship.other;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Age Range
              Text(
                'Age Range',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedAgeRange,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                  labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                items: _ageRanges.map((range) {
                  return DropdownMenuItem(
                    value: range,
                    child: Text(
                      range,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAgeRange = value ?? '18-24';
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Notes
              FormTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                prefixIcon: Icons.note_outlined,
                maxLines: 3,
                hint: 'Any health notes or special considerations...',
              ),
              
              const SizedBox(height: 32),
              
              PrimaryButton(
                text: _isSaving ? 'Saving...' : 'Add Family Member',
                onPressed: _saveMember,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}