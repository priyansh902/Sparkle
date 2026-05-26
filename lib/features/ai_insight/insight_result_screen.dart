// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sparkle_lite/core/constants/app_constants.dart';
// import 'package:sparkle_lite/providers/insight_provider.dart';
// import 'package:sparkle_lite/shared/widgets/primary_button.dart';

// class InsightResultScreen extends ConsumerWidget {
//   const InsightResultScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final insightState = ref.watch(insightProvider);
//     final insight = insightState.currentInsight;
    
//     if (insightState.isGenerating) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Generating Insight'),
//           backgroundColor: Colors.transparent,
//         ),
//         body: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 24),
//               Text('Analyzing your health data...'),
//               SizedBox(height: 8),
//               Text(
//                 'This may take a moment',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
    
//     if (insight == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('AI Insight')),
//         body: const Center(child: Text('No insight generated')),
//       );
//     }
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Health Insight'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () {
//               ref.read(insightProvider.notifier).clearCurrentInsight();
//               context.pop();
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Summary Card
//             _buildSectionCard(
//               icon: Icons.lightbulb_outline,
//               iconColor: Colors.amber,
//               title: 'Summary',
//               content: insight['summary'],
//             ),
            
//             const SizedBox(height: 16),
            
//             // Pattern Card
//             _buildSectionCard(
//               icon: Icons.timeline,
//               iconColor: const Color(0xFF7B61FF),
//               title: 'Patterns Noticed',
//               content: insight['possiblePattern'],
//             ),
            
//             const SizedBox(height: 16),
            
//             // Care Guidance Card
//             _buildSectionCard(
//               icon: Icons.health_and_safety,
//               iconColor: Colors.green,
//               title: 'Care Guidance',
//               content: insight['careGuidance'],
//             ),
            
//             const SizedBox(height: 16),
            
//             // Doctor Questions Card
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Colors.grey[200]!),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF4ECDC4).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(Icons.question_answer, color: Color(0xFF4ECDC4)),
//                         ),
//                         const SizedBox(width: 12),
//                         const Text(
//                           'Questions for Your Doctor',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     ...(insight['doctorQuestions'] as List).map((q) => Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('• ', style: TextStyle(fontSize: 14)),
//                           Expanded(child: Text(q, style: const TextStyle(fontSize: 14))),
//                         ],
//                       ),
//                     )),
//                   ],
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             // Disclaimer
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       insight['disclaimer'],
//                       style: TextStyle(color: Colors.grey[600], fontSize: 11, fontStyle: FontStyle.italic),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             const SizedBox(height: 24),
            
//             // Actions
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () {
//                       _shareInsight(context, insight);
//                     },
//                     icon: const Icon(Icons.share),
//                     label: const Text('Share'),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: PrimaryButton(
//                     text: 'Save to Timeline',
//                     onPressed: () async {
//                       final saved = await ref.read(insightProvider.notifier).saveInsight(insight);
//                       if (saved && context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Insight saved to timeline')),
//                         );
//                         ref.read(insightProvider.notifier).clearCurrentInsight();
//                         context.go(AppConstants.routeTimeline);
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 16),
            
//             // Regenerate button
//             Center(
//               child: TextButton(
//                 onPressed: () {
//                   ref.read(insightProvider.notifier).clearCurrentInsight();
//                   context.pop();
//                 },
//                 child: const Text('Go Back'),
//               ),
//             ),
            
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildSectionCard({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String content,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: iconColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, color: iconColor),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               content,
//               style: TextStyle(color: Colors.grey[700], height: 1.5),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   void _shareInsight(BuildContext context, Map<String, dynamic> insight) {
//     final text = '''
// Health Insight from Sparkle Lite

// Summary: ${insight['summary']}

// Pattern: ${insight['possiblePattern']}

// Guidance: ${insight['careGuidance']}

// Questions for doctor:
// ${(insight['doctorQuestions'] as List).map((q) => '• $q').join('\n')}

// ${insight['disclaimer']}
// ''';
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Insight copied to clipboard'),
//         action: SnackBarAction(
//           label: 'Share',
//           onPressed: () {
//             // In production, use Share.share(text)
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/insight_provider.dart';
import '../../shared/widgets/primary_button.dart';

class InsightResultScreen extends ConsumerWidget {
  const InsightResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightState = ref.watch(insightProvider);
    final insight = insightState.currentInsight;
    
    if (insightState.isGenerating) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Generating Insight'),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text('Analyzing your health data...'),
              SizedBox(height: 8),
              Text(
                'This may take a moment',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    
    if (insight == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Insight')),
        body: const Center(child: Text('No insight generated')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Health Insight'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(insightProvider.notifier).clearCurrentInsight();
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
            // Summary Card
            _buildSectionCard(
              icon: Icons.lightbulb_outline,
              iconColor: Colors.amber,
              title: 'Summary',
              content: insight['summary'],
            ),
            
            const SizedBox(height: 16),
            
            // Pattern Card
            _buildSectionCard(
              icon: Icons.timeline,
              iconColor: const Color(0xFF7B61FF),
              title: 'Patterns Noticed',
              content: insight['possiblePattern'],
            ),
            
            const SizedBox(height: 16),
            
            // Care Guidance Card
            _buildSectionCard(
              icon: Icons.health_and_safety,
              iconColor: Colors.green,
              title: 'Care Guidance',
              content: insight['careGuidance'],
            ),
            
            const SizedBox(height: 16),
            
            // Doctor Questions Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.question_answer, color: Color(0xFF4ECDC4)),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Questions for Your Doctor',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...(insight['doctorQuestions'] as List).map((q) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 14)),
                          Expanded(child: Text(q, style: const TextStyle(fontSize: 14))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight['disclaimer'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareInsight(context, insight),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
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
                    onPressed: () => _saveInsightToTimeline(ref, context, insight),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Regenerate button
            Center(
              child: TextButton(
                onPressed: () {
                  ref.read(insightProvider.notifier).clearCurrentInsight();
                  context.pop();
                },
                child: const Text('Go Back'),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  void _saveInsightToTimeline(WidgetRef ref, BuildContext context, Map<String, dynamic> insight) async {
    final saved = await ref.read(insightProvider.notifier).saveInsight(insight);
    if (saved && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insight saved to timeline')),
      );
      ref.read(insightProvider.notifier).clearCurrentInsight();
      context.go(AppConstants.routeTimeline);
    }
  }
  
  void _shareInsight(BuildContext context, Map<String, dynamic> insight) {
    final text = '''
Health Insight from Sparkle Lite

Summary: ${insight['summary']}

Pattern: ${insight['possiblePattern']}

Guidance: ${insight['careGuidance']}

Questions for doctor:
${(insight['doctorQuestions'] as List).map((q) => '• $q').join('\n')}

${insight['disclaimer']}
''';
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Insight copied to clipboard'),
      ),
    );
  }
  
  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}