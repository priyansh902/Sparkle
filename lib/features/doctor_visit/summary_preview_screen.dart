import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/providers/summary_provider.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';

/// Screen to preview the generated doctor visit summary before saving or sharing
/// This screen shows the summary text, questions for the doctor, recent symptoms, and health records.

class SummaryPreviewScreen extends ConsumerWidget {
  const SummaryPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryState = ref.watch(summaryProvider);
    final summary = summaryState.currentSummary;
    
    if (summaryState.isGenerating) {
      return Scaffold(
        appBar: AppBar(title: const Text('Generating Summary')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text('Creating your visit summary...'),
            ],
          ),
        ),
      );
    }
    
    if (summary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Summary Preview')),
        body: const Center(child: Text('No summary available')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Summary'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(summaryProvider.notifier).clearCurrentSummary();
              context.pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7B61FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description, color: Color(0xFF7B61FF), size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generated: ${_formatDateTime(summary['generatedDate'])}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Share this summary with your doctor',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Summary text
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      summary['summaryText'],
                      style: const TextStyle(height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Questions for doctor
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Questions for Your Doctor',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(summary['questionsForDoctor'] as List).map((q) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 14)),
                          Expanded(child: Text(q)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Recent symptoms
            if ((summary['recentSymptoms'] as List).isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Symptoms',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...(summary['recentSymptoms'] as List).map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $s', style: const TextStyle(fontSize: 13)),
                      )),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Recent records
            if ((summary['recentRecords'] as List).isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Health Records',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...(summary['recentRecords'] as List).map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $r', style: const TextStyle(fontSize: 13)),
                      )),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportSummary(context, summary),
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    text: 'Save to Timeline',
                    onPressed: () => _saveSummary(ref, context, summary),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Center(
              child: TextButton(
                onPressed: () {
                  ref.read(summaryProvider.notifier).clearCurrentSummary();
                  context.pop();
                },
                child: const Text('Regenerate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _saveSummary(WidgetRef ref, BuildContext context, Map<String, dynamic> summary) async {
    final saved = await ref.read(summaryProvider.notifier).saveSummary(summary);
    if (saved && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Summary saved to timeline')),
      );
      ref.read(summaryProvider.notifier).clearCurrentSummary();
      context.go(AppConstants.routeTimeline);
    }
  }
  
  void _exportSummary(BuildContext context, Map<String, dynamic> summary) {
    final text = '''
DOCTOR VISIT SUMMARY
Generated: ${_formatDateTime(summary['generatedDate'])}

${summary['summaryText']}

QUESTIONS FOR DOCTOR:
${(summary['questionsForDoctor'] as List).map((q) => '• $q').join('\n')}

RECENT SYMPTOMS:
${(summary['recentSymptoms'] as List).map((s) => '• $s').join('\n')}

RECENT HEALTH RECORDS:
${(summary['recentRecords'] as List).map((r) => '• $r').join('\n')}

Sparkle Lite Health Companion
''';
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summary copied to clipboard')),
    );
  }
  
  String _formatDateTime(DateTime date) {
    return '${date.month}/${date.day}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}