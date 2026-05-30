import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';
import 'package:sparkle_lite/providers/auth_provider.dart';
import 'package:sparkle_lite/providers/symptom_provider.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';
import 'package:sparkle_lite/shared/widgets/form_text_field.dart';

/// Screen for adding a new symptom log entry. This screen includes a form with fields for date, period status, flow level, pain level, mood, symptoms, and notes. It uses various input widgets like date pickers, sliders, chips, and text fields to create an intuitive and engaging UI for logging symptoms. The screen also includes validation to ensure that required fields are filled out correctly before allowing the user to save the symptom log. When the user saves the log, it interacts with the SymptomProvider to add the new entry to the database and provides feedback on the success of the operation.
///   The design of the AddSymptomScreen focuses on ease of use and visual appeal, with clear labels, icons, and a consistent color scheme that aligns with the overall app design. The screen also includes loading indicators and error handling to enhance the user experience during the save operation. Overall, this screen is a key part of the symptom tracking feature, allowing users to easily log their health data and gain insights over time.
/// The AddSymptomScreen is designed to be flexible and extensible, allowing for future additions such as more symptom options, integration with wearable devices for automatic data logging, and enhanced AI insights based on the logged symptoms. The screen also emphasizes user privacy and data security, ensuring that all logged information is stored securely and handled with care.

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Symptom', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
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
                    title: Text('Date', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text(
                      _selectedDate.toString().split(' ')[0],
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
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
                  Text('Period Status', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: PeriodStatus.values.map((status) {
                      final isSelected = _periodStatus == status;
                      return FilterChip(
                        label: Text(
                          status.toString().split('.').last,
                          style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700])),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _periodStatus = selected ? status : PeriodStatus.none;
                          });
                        },
                        selectedColor: const Color(0xFF7B61FF),
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Flow Level (only if period is started/ongoing)
                  if (_periodStatus != PeriodStatus.none) ...[
                    Text('Flow Level', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: FlowLevel.values.map((level) {
                        final isSelected = _flowLevel == level;
                        return ChoiceChip(
                          label: Text(
                            level.toString().split('.').last,
                            style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700])),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _flowLevel = selected ? level : FlowLevel.none;
                            });
                          },
                          selectedColor: const Color(0xFF7B61FF),
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Pain Level
                  Text('Pain Level (0-10)', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
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
                  Text('Mood', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _moodOptions.map((mood) {
                      final isSelected = _mood == mood;
                      return FilterChip(
                        label: Text(
                          mood.toString().split('.').last,
                          style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700])),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _mood = selected ? mood : Mood.calm;
                          });
                        },
                        selectedColor: const Color(0xFF7B61FF),
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Symptoms
                  Text('Symptoms', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableSymptoms.map((symptom) {
                      final isSelected = _selectedSymptoms.contains(symptom);
                      return FilterChip(
                        label: Text(symptom, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700])),
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
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
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