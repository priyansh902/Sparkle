import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/providers/symptom_provider.dart';
import 'package:sparkle_lite/providers/insight_provider.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';

class InsightInputScreen extends ConsumerWidget {
  const InsightInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symptomState = ref.watch(symptomProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate AI Insight'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.psychology, color: Color(0xFF4ECDC4), size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'How it works',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'This app analyzes your symptom logs to provide educational insights and suggested questions for your doctor. It does not provide medical diagnoses.',
                                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // What will be analyzed
                  const Text(
                    'What will be analyzed',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildStatItem(
                            Icons.favorite,
                            '${symptomState.symptoms.length}',
                            'Symptoms logged',
                            Colors.red,
                          ),
                          const Divider(),
                          _buildStatItem(
                            Icons.calendar_today,
                            _getDateRange(symptomState.symptoms),
                            'Date range',
                            const Color(0xFF7B61FF),
                          ),
                          const Divider(),
                          _buildStatItem(
                            Icons.analytics,
                            _getMostCommonSymptom(symptomState.symptoms),
                            'Most common symptom',
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (symptomState.symptoms.isEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You need to log at least one symptom before generating an insight.',
                              style: TextStyle(color: Colors.orange[800]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Generate button
          Padding(
            padding: const EdgeInsets.all(24),
            child: PrimaryButton(
              text: symptomState.symptoms.isEmpty ? 'Log Symptoms First' : 'Generate Insight',
              onPressed: symptomState.symptoms.isEmpty ? null : () => _generateInsight(ref, context, symptomState.symptoms),
            ),
          ),
        ],
      ),
    );
  }
  
  void _generateInsight(WidgetRef ref, BuildContext context, List<dynamic> symptoms) async {
    final insightNotifier = ref.read(insightProvider.notifier);
    final result = await insightNotifier.generateInsight(symptoms.cast());
    
    if (result != null && context.mounted) {
      context.push(AppConstants.routeAIInsightResult);
    }
  }
  
  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _getDateRange(List<dynamic> symptoms) {
    if (symptoms.isEmpty) return 'No data';
    final dates = symptoms.map((s) => s.date).toList();
    dates.sort();
    final first = dates.first;
    final last = dates.last;
    return '${first.month}/${first.day} - ${last.month}/${last.day}';
  }
  
  String _getMostCommonSymptom(List<dynamic> symptoms) {
    if (symptoms.isEmpty) return 'None';
    final Map<String, int> counts = {};
    for (final symptom in symptoms) {
      for (final s in symptom.symptoms) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return 'None';
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}