import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';
import 'package:sparkle_lite/providers/auth_provider.dart';
import 'package:sparkle_lite/providers/symptom_provider.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';
import 'package:sparkle_lite/shared/widgets/form_text_field.dart';

class AddSymptomScreen extends ConsumerStatefulWidget {
  const AddSymptomScreen({super.key});

  @override
  ConsumerState<AddSymptomScreen> createState() => _AddSymptomScreenState();
}

class _AddSymptomScreenState extends ConsumerState<AddSymptomScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late DateTime _selectedDate;
  PeriodStatus _periodStatus = PeriodStatus.none;
  FlowLevel _flowLevel = FlowLevel.none;
  int _painLevel = 0;
  Mood _mood = Mood.calm;
  final List<String> _selectedSymptoms = [];
  final TextEditingController _notesController = TextEditingController();
  
  final List<String> _availableSymptoms = [
    'Cramps', 'Headache', 'Bloating', 'Fatigue', 
    'Nausea', 'Spotting', 'Irregular bleeding', 'Other'
  ];
  
  final List<Mood> _moodOptions = [
    Mood.calm, Mood.anxious, Mood.tired, 
    Mood.irritable, Mood.happy, Mood.sad
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveSymptom() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedSymptoms.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one symptom')),
        );
        return;
      }
      
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;
      
      if (userId == null) return;
      
      final newSymptom = SymptomLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        date: _selectedDate,
        periodStatus: _periodStatus,
        flowLevel: _flowLevel,
        painLevel: _painLevel,
        mood: _mood,
        symptoms: _selectedSymptoms,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final success = await ref.read(symptomProvider.notifier).addSymptom(newSymptom);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Symptom logged successfully!')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final symptomState = ref.watch(symptomProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Symptom'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today, color: Color(0xFF7B61FF)),
                    title: const Text('Date'),
                    subtitle: Text(_selectedDate.toString().split(' ')[0]),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Period Status
                  const Text('Period Status', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: PeriodStatus.values.map((status) {
                      return FilterChip(
                        label: Text(status.toString().split('.').last),
                        selected: _periodStatus == status,
                        onSelected: (selected) {
                          setState(() {
                            _periodStatus = selected ? status : PeriodStatus.none;
                          });
                        },
                        selectedColor: const Color(0xFF7B61FF).withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Flow Level (only if period is started/ongoing)
                  if (_periodStatus != PeriodStatus.none) ...[
                    const Text('Flow Level', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: FlowLevel.values.map((level) {
                        return ChoiceChip(
                          label: Text(level.toString().split('.').last),
                          selected: _flowLevel == level,
                          onSelected: (selected) {
                            setState(() {
                              _flowLevel = selected ? level : FlowLevel.none;
                            });
                          },
                          selectedColor: const Color(0xFF7B61FF),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Pain Level
                  const Text('Pain Level (0-10)', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _painLevel.toDouble(),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          activeColor: _painLevel >= 7 ? Colors.red : const Color(0xFF7B61FF),
                          label: _painLevel.toString(),
                          onChanged: (value) {
                            setState(() => _painLevel = value.round());
                          },
                        ),
                      ),
                      Container(
                        width: 50,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _painLevel >= 7 ? Colors.red.withOpacity(0.1) : const Color(0xFF7B61FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _painLevel.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _painLevel >= 7 ? Colors.red : const Color(0xFF7B61FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Mood
                  const Text('Mood', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _moodOptions.map((mood) {
                      return FilterChip(
                        label: Text(mood.toString().split('.').last),
                        selected: _mood == mood,
                        onSelected: (selected) {
                          setState(() {
                            _mood = selected ? mood : Mood.calm;
                          });
                        },
                        selectedColor: const Color(0xFF7B61FF).withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Symptoms
                  const Text('Symptoms', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableSymptoms.map((symptom) {
                      final isSelected = _selectedSymptoms.contains(symptom);
                      return FilterChip(
                        label: Text(symptom),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSymptoms.add(symptom);
                            } else {
                              _selectedSymptoms.remove(symptom);
                            }
                          });
                        },
                        selectedColor: const Color(0xFF7B61FF).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF7B61FF),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Notes
                  FormTextField(
                    controller: _notesController,
                    label: 'Notes (Optional)',
                    prefixIcon: Icons.note_outlined,
                    hint: 'Add any additional notes...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  
                  PrimaryButton(
                    text: symptomState.isSaving ? 'Saving...' : 'Save Symptom Log',
                    onPressed: _saveSymptom,
                    isLoading: symptomState.isSaving,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (symptomState.isSaving)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}