import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/Data/models/user_model.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/providers/auth_provider.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';

/// Screen for users to input their health profile information during onboarding. This helps personalize the app experience and AI insights.
class HealthProfileScreen extends ConsumerStatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  ConsumerState<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends ConsumerState<HealthProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedAgeRange;
  LifeStage? _selectedLifeStage;
  CycleStatus? _selectedCycleStatus;
  final List<String> _selectedConditions = [];
  final List<String> _selectedMedications = [];

  final List<String> _ageRanges = [
    '18-24',
    '25-30',
    '31-35',
    '36-40',
    '41-45',
    '46-50',
    '50+',
  ];

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

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = ref.read(authProvider).user;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          ageRange: _selectedAgeRange,
          lifeStage: _selectedLifeStage,
          cycleStatus: _selectedCycleStatus,
          conditions: _selectedConditions,
          medications: _selectedMedications,
        );
        
        await ref.read(authProvider.notifier).updateProfile(updatedUser);
        
        if (mounted) {
          context.go(AppConstants.routeDashboard);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Profile'),
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
              Text(
                'Let\'s personalize your experience',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This information helps us provide relevant insights',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              
              // Age Range
              Text(
                'Age Range',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: _ageRanges.map((range) {
                  final isSelected = _selectedAgeRange == range;
                  return ChoiceChip(
                    label: Text(range),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedAgeRange = selected ? range : null;
                      });
                    },
                    selectedColor: const Color(0xFF7B61FF),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Life Stage
              Text(
                'Life Stage',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _lifeStages.map((stage) {
                  final isSelected = _selectedLifeStage == stage;
                  final label = _getLifeStageLabel(stage);
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedLifeStage = selected ? stage : null;
                      });
                    },
                    selectedColor: const Color(0xFF7B61FF),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Cycle Status
              Text(
                'Menstrual Cycle Status (Optional)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: _cycleStatuses.map((status) {
                  final isSelected = _selectedCycleStatus == status;
                  final label = _getCycleStatusLabel(status);
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCycleStatus = selected ? status : null;
                      });
                    },
                    selectedColor: const Color(0xFF7B61FF),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Known Conditions
              Text(
                'Known Conditions (Optional)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _commonConditions.map((condition) {
                  final isSelected = _selectedConditions.contains(condition);
                  return FilterChip(
                    label: Text(condition),
                    selected: isSelected,
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
                    checkmarkColor: const Color(0xFF7B61FF),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              // Privacy Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your health data is private and will never be shared without your consent',
                        style: TextStyle(color: Colors.blue[800], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              PrimaryButton(
                text: 'Complete Setup',
                onPressed: _saveProfile,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getLifeStageLabel(LifeStage stage) {
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
    }
  }

  String _getCycleStatusLabel(CycleStatus status) {
    switch (status) {
      case CycleStatus.regular:
        return 'Regular';
      case CycleStatus.irregular:
        return 'Irregular';
      case CycleStatus.notSure:
        return 'Not Sure';
      case CycleStatus.notApplicable:
        return 'Not Applicable';
    }
  }
}