import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/Data/models/user_model.dart';
import 'package:sparkle_lite/providers/auth_provider.dart';
import 'package:sparkle_lite/providers/record_provider.dart';
import 'package:sparkle_lite/providers/symptom_provider.dart';
import 'package:sparkle_lite/providers/family_provider.dart';
import 'package:sparkle_lite/providers/summary_provider.dart';
import 'package:sparkle_lite/providers/insight_provider.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';
import 'package:sparkle_lite/shared/widgets/form_text_field.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _ageRangeController;
  late LifeStage _selectedLifeStage;
  late CycleStatus _selectedCycleStatus;
  late List<String> _selectedConditions;
  late List<String> _selectedMedications;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoading = true;

  final List<LifeStage> _lifeStages = [
    LifeStage.generalWellness,
    LifeStage.periodTracking,
    LifeStage.fertilityPlanning,
    LifeStage.pregnancy,
    LifeStage.postpartum,
    LifeStage.menopause,
  ];

  final List<CycleStatus> _cycleStatuses = [
    CycleStatus.regular,
    CycleStatus.irregular,
    CycleStatus.notSure,
    CycleStatus.notApplicable,
  ];

  final List<String> _commonConditions = [
    'PCOS',
    'Thyroid',
    'Diabetes',
    'Endometriosis',
    'Anxiety',
    'Depression',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController = TextEditingController(text: user.name);
      _nicknameController = TextEditingController(text: user.nickname ?? '');
      _ageRangeController = TextEditingController(text: user.ageRange ?? '');
      _selectedLifeStage = user.lifeStage ?? LifeStage.generalWellness;
      _selectedCycleStatus = user.cycleStatus ?? CycleStatus.notSure;
      _selectedConditions = List.from(user.conditions);
      _selectedMedications = List.from(user.medications);
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _ageRangeController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() => _isSaving = true);

    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      name: _nameController.text.trim(),
      nickname: _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
      ageRange: _ageRangeController.text.trim().isEmpty ? null : _ageRangeController.text.trim(),
      lifeStage: _selectedLifeStage,
      cycleStatus: _selectedCycleStatus,
      conditions: _selectedConditions,
      medications: _selectedMedications,
    );

    await ref.read(authProvider.notifier).updateProfile(updatedUser);
    
    setState(() => _isSaving = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      setState(() => _isEditing = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure? This action cannot be undone. '
          'All your symptoms, health records, family data, and insights will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isSaving = true);
      
      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      
      try {
        // Delete all user data from repositories
        final userId = ref.read(authProvider).user?.id;
        if (userId != null) {
          // Delete symptoms
          final symptoms = ref.read(symptomProvider).symptoms;
          for (final symptom in symptoms) {
            await ref.read(symptomProvider.notifier).deleteSymptom(symptom.id);
          }
          
          // Delete records
          final records = ref.read(recordProvider).records;
          for (final record in records) {
            await ref.read(recordProvider.notifier).deleteRecord(record.id);
          }
          
          // Delete family members
          final familyMembers = ref.read(familyProvider).members;
          for (final member in familyMembers) {
            await ref.read(familyProvider.notifier).deleteMember(member.id);
          }
          
          // Delete summaries
          final summaries = ref.read(summaryProvider).summaries;
          for (final summary in summaries) {
            await ref.read(summaryProvider.notifier).deleteSummary(summary.id);
          }
          
          // Delete insights
          final insights = ref.read(insightProvider).insights;
          for (final insight in insights) {
            await ref.read(insightProvider.notifier).deleteInsight(insight.id);
          }
        }
        
        // Logout and delete auth account
        await ref.read(authProvider.notifier).deleteAccount();
        
        if (mounted) {
          Navigator.pop(context); // Close progress dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')),
          );
          context.go(AppConstants.routeWelcome);
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close progress dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting account: $e')),
          );
        }
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _isEditing ? _buildEditForm(isDark) : _buildProfileView(user, isDark),
      ),
    );
  }

  Widget _buildProfileView(UserModel? user, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF7B61FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 50,
              color: const Color(0xFF7B61FF),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Name
        _buildInfoRow('Name', user?.name ?? 'Not set'),
        const Divider(),
        
        // Nickname
        _buildInfoRow('Nickname', user?.nickname ?? 'Not set'),
        const Divider(),
        
        // Email
        _buildInfoRow('Email', user?.email ?? 'Not set'),
        const Divider(),
        
        // Age Range
        _buildInfoRow('Age Range', user?.ageRange ?? 'Not set'),
        const Divider(),
        
        // Life Stage
        _buildInfoRow('Life Stage', _getLifeStageLabel(user?.lifeStage)),
        const Divider(),
        
        // Cycle Status
        _buildInfoRow('Cycle Status', _getCycleStatusLabel(user?.cycleStatus)),
        const Divider(),
        
        // Conditions
        _buildInfoRow(
          'Conditions',
          user?.conditions.isEmpty == true ? 'None' : user?.conditions.join(', '),
        ),
        const Divider(),
        
        // Medications
        _buildInfoRow(
          'Medications',
          user?.medications.isEmpty == true ? 'None' : user?.medications.join(', '),
        ),
        
        const SizedBox(height: 32),
        
        // Delete Account Button
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.red[900]?.withOpacity(0.3) : Colors.red[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.red[800]! : Colors.red[200]!),
          ),
          child: ListTile(
            leading: Icon(Icons.delete_forever, color: isDark ? Colors.red[300] : Colors.red),
            title: Text('Delete Account', style: TextStyle(color: isDark ? Colors.red[300] : Colors.red)),
            subtitle: Text(
              'Permanently delete all your data',
              style: TextStyle(color: isDark ? Colors.red[300]?.withOpacity(0.7) : Colors.red[700]),
            ),
            onTap: _deleteAccount,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not set',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormTextField(
          controller: _nameController,
          label: 'Full Name',
          prefixIcon: Icons.person,
        ),
        const SizedBox(height: 16),
        
        FormTextField(
          controller: _nicknameController,
          label: 'Nickname (Optional)',
          prefixIcon: Icons.label,
        ),
        const SizedBox(height: 16),
        
        FormTextField(
          controller: _ageRangeController,
          label: 'Age Range (Optional)',
          prefixIcon: Icons.calendar_today,
          hint: 'e.g., 25-30',
        ),
        const SizedBox(height: 16),
        
        // Life Stage
        const Text('Life Stage', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _lifeStages.map((stage) {
            return FilterChip(
              label: Text(_getLifeStageLabel(stage)),
              selected: _selectedLifeStage == stage,
              onSelected: (selected) {
                setState(() {
                  _selectedLifeStage = selected ? stage : LifeStage.generalWellness;
                });
              },
              selectedColor: const Color(0xFF7B61FF).withOpacity(0.2),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        
        // Cycle Status
        const Text('Cycle Status', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _cycleStatuses.map((status) {
            return FilterChip(
              label: Text(_getCycleStatusLabel(status)),
              selected: _selectedCycleStatus == status,
              onSelected: (selected) {
                setState(() {
                  _selectedCycleStatus = selected ? status : CycleStatus.notSure;
                });
              },
              selectedColor: const Color(0xFF7B61FF).withOpacity(0.2),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        
        // Conditions
        const Text('Known Conditions', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonConditions.map((condition) {
            return FilterChip(
              label: Text(condition),
              selected: _selectedConditions.contains(condition),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedConditions.add(condition);
                  } else {
                    _selectedConditions.remove(condition);
                  }
                });
              },
              selectedColor: const Color(0xFF7B61FF).withOpacity(0.2),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 32),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _isEditing = false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                text: _isSaving ? 'Saving...' : 'Save Changes',
                onPressed: _updateProfile,
                isLoading: _isSaving,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getLifeStageLabel(LifeStage? stage) {
    switch (stage) {
      case LifeStage.generalWellness:
        return 'General Wellness';
      case LifeStage.periodTracking:
        return 'Period Tracking';
      case LifeStage.fertilityPlanning:
        return 'Fertility Planning';
      case LifeStage.pregnancy:
        return 'Pregnancy';
      case LifeStage.postpartum:
        return 'Postpartum';
      case LifeStage.menopause:
        return 'Menopause';
      default:
        return 'General Wellness';
    }
  }

  String _getCycleStatusLabel(CycleStatus? status) {
    switch (status) {
      case CycleStatus.regular:
        return 'Regular';
      case CycleStatus.irregular:
        return 'Irregular';
      case CycleStatus.notSure:
        return 'Not Sure';
      case CycleStatus.notApplicable:
        return 'Not Applicable';
      default:
        return 'Not Sure';
    }
  }
}