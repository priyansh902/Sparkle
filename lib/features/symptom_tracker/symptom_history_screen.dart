import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';
import 'package:sparkle_lite/providers/symptom_provider.dart';
import 'package:sparkle_lite/shared/widgets/empty_state_widget.dart';
import 'package:sparkle_lite/shared/widgets/loading_widget.dart';

/// SymptomHistoryScreen displays a list of all logged symptoms with options to view details, edit, or delete each entry. It also includes a button to add new symptom logs and handles empty states and loading states gracefully.
/// The screen uses a ListView to display symptom entries in a card format, showing key details like date, pain level, period status, and symptoms. Each card is tappable, allowing users to view more details or edit the entry. The screen also includes a Dismissible widget for easy deletion of entries with confirmation dialogs to prevent accidental deletions. The UI is designed to be clean and user-friendly, with clear calls to action and feedback for user interactions.
/// The SymptomHistoryScreen interacts with the SymptomProvider to fetch and manage symptom data, ensuring that the UI stays in sync with the underlying data state. It also includes error handling to display appropriate messages if there are issues loading or managing symptom logs. Overall, this screen is a crucial part of the symptom tracking feature, providing users with a comprehensive view of their health data and empowering them to take control of their health journey.
class SymptomHistoryScreen extends ConsumerWidget {
  const SymptomHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symptomState = ref.watch(symptomProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push(AppConstants.routeAddSymptom);
            },
          ),
        ],
      ),
      body: _buildBody(context, ref, symptomState),
    );
  }
  
  Widget _buildBody(BuildContext context, WidgetRef ref, SymptomState state) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Loading symptoms...');
    }
    
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(symptomProvider.notifier).loadSymptoms(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (state.symptoms.isEmpty) {
      return EmptyStateWidget(
        title: 'No Symptoms Logged Yet',
        message: 'Start tracking your symptoms to see patterns and insights.',
        buttonText: 'Log Your First Symptom',
        onButtonPressed: () {
          context.push(AppConstants.routeAddSymptom);
        },
        icon: Icons.favorite_outline,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.symptoms.length,
      itemBuilder: (context, index) {
        final symptom = state.symptoms[index];
        return _buildSymptomCard(context, ref, symptom);
      },
    );
  }
  
  Widget _buildSymptomCard(BuildContext context, WidgetRef ref, SymptomLog symptom) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Dismissible(
        key: Key(symptom.id),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Symptom'),
              content: const Text('Are you sure you want to delete this symptom log?'),
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
            await ref.read(symptomProvider.notifier).deleteSymptom(symptom.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Symptom deleted')),
              );
            }
          }
        },
        child: InkWell(
          onTap: () {
            context.push('${AppConstants.routeEditSymptom}?id=${symptom.id}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(symptom.date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: symptom.painLevel >= 7 ? Colors.red.withOpacity(0.1) : const Color(0xFF7B61FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Pain: ${symptom.painLevel}/10',
                        style: TextStyle(
                          color: symptom.painLevel >= 7 ? Colors.red : const Color(0xFF7B61FF),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (symptom.periodStatus.toString().split('.').last != 'none')
                  Chip(
                    label: Text('Period: ${symptom.periodStatus.toString().split('.').last}'),
                    backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.1),
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                const SizedBox(height: 8),
                // ✅ FIXED: Wrap with SizedBox to ensure proper typing
                SizedBox(
                  child: Wrap(
                    spacing: 8,
                    children: symptom.symptoms.map((s) => Chip(
                      label: Text(s),
                      backgroundColor: Colors.grey[200],
                      labelStyle: const TextStyle(fontSize: 12),
                    )).toList(),
                  ),
                ),
                if (symptom.notes != null && symptom.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    symptom.notes!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    return '${date.month}/${date.day}/${date.year}';
  }
}