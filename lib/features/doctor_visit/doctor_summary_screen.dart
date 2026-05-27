import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/providers/auth_provider.dart';
import 'package:sparkle_lite/providers/symptom_provider.dart';
import 'package:sparkle_lite/providers/record_provider.dart';
import 'package:sparkle_lite/providers/summary_provider.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';
import 'package:sparkle_lite/shared/widgets/form_text_field.dart';

/// A screen that generates a doctor visit summary based on recent symptoms, records, and user notes.
/// This screen allows users to prepare for their doctor visits by creating a comprehensive summary that can be shared with their healthcare provider.


class DoctorSummaryScreen extends ConsumerStatefulWidget {
  const DoctorSummaryScreen({super.key});

  @override
  ConsumerState<DoctorSummaryScreen> createState() => _DoctorSummaryScreenState();
}

class _DoctorSummaryScreenState extends ConsumerState<DoctorSummaryScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _generateSummary() async {
    setState(() => _isGenerating = true);
    
    final authState = ref.read(authProvider);
    final symptomState = ref.read(symptomProvider);
    final recordState = ref.read(recordProvider);
    final summaryNotifier = ref.read(summaryProvider.notifier);
    
    final user = authState.user;
    if (user == null) return;
    
    final result = await summaryNotifier.generateSummary(
      notes: _notesController.text,
      user: user,
      symptoms: symptomState.symptoms,
      records: recordState.records,
    );
    
    setState(() => _isGenerating = false);
    
    if (result != null && mounted) {
      context.push(AppConstants.routeSummaryPreview);
    }
  }

  @override
  Widget build(BuildContext context) {
    final symptomState = ref.watch(symptomProvider);
    final recordState = ref.watch(recordProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Visit Summary'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7B61FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_information, color: Color(0xFF7B61FF), size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Prepare for Your Visit',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This summary includes your recent symptoms, health records, and generates questions to ask your doctor.',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Symptoms',
                    '${symptomState.symptoms.length}',
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Records',
                    '${recordState.records.length}',
                    Icons.folder,
                    const Color(0xFF7B61FF),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notes field
            FormTextField(
              controller: _notesController,
              label: 'Additional Notes for Doctor (Optional)',
              prefixIcon: Icons.note_outlined,
              hint: 'Add any specific concerns or questions...',
              maxLines: 4,
            ),
            
            const SizedBox(height: 32),
            
            // Generate button
            PrimaryButton(
              text: _isGenerating ? 'Generating Summary...' : 'Generate Visit Summary',
              onPressed: _isGenerating ? null : _generateSummary,
              isLoading: _isGenerating,
            ),
            
            const SizedBox(height: 16),
            
            // Info about what's included
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What\'s included:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint('Your personal health profile'),
                  _buildBulletPoint('Recent symptoms (last 30 days)'),
                  _buildBulletPoint('Uploaded health records'),
                  _buildBulletPoint('Current medications'),
                  _buildBulletPoint('Suggested questions for doctor'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Text('• ', style: TextStyle(fontSize: 13)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}