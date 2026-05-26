import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/providers/auth_provider.dart';
import 'package:sparkle_lite/providers/symptom_provider.dart';
import 'package:sparkle_lite/shared/widgets/empty_state_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final symptomState = ref.watch(symptomProvider);
    final user = authState.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppConstants.routeWelcome);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(symptomProvider.notifier).loadSymptoms();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Hello, ${user?.name ?? "User"}! Welcome Lady Sparkle',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome to your health companion',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              
              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      context,
                      'Log Symptom',
                      Icons.favorite_outline,
                      () => context.push(AppConstants.routeAddSymptom),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      context,
                      'View History',
                      Icons.history,
                      () => context.push(AppConstants.routeSymptomHistory),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Recent Symptoms
              const Text(
                'Recent Symptoms',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              _buildRecentSymptomsSection(context, ref, symptomState),
              
              const SizedBox(height: 24),
              
              // Coming Soon Section
              const Text(
                'Coming Soon',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              _buildComingSoonCard(
                context,
                'Health Records',
                'Upload and manage medical reports',
                Icons.cloud_upload_outlined,
              ),
              const SizedBox(height: 16),
              _buildComingSoonCard(
                context,
                'AI Insights',
                'Get smart health summaries',
                Icons.psychology_outlined,
              ),
              
              const SizedBox(height: 24),
              
              // Privacy reminder
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your data is private and secure',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Symptoms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            context.push(AppConstants.routeSymptomHistory);
          }
        },
      ),
    );
  }
  
  Widget _buildQuickAction(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF7B61FF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF7B61FF), size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentSymptomsSection(BuildContext context, WidgetRef ref, SymptomState state) {
    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (state.recentSymptoms.isEmpty) {
      return EmptyStateWidget(
        title: 'No symptoms yet',
        message: 'Start tracking your health journey',
        buttonText: 'Log Symptom',
        onButtonPressed: () {
          context.push(AppConstants.routeAddSymptom);
        },
        icon: Icons.favorite_outline,
      );
    }
    
    return Column(
      children: [
        ...state.recentSymptoms.map((symptom) => _buildRecentSymptomTile(context, symptom)).toList(),
        TextButton(
          onPressed: () {
            context.push(AppConstants.routeSymptomHistory);
          },
          child: const Text('View All'),
        ),
      ],
    );
  }
  
  Widget _buildRecentSymptomTile(BuildContext context, SymptomLog symptom) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: symptom.painLevel >= 7 ? Colors.red.withOpacity(0.1) : const Color(0xFF7B61FF).withOpacity(0.1),
          child: Icon(
            Icons.favorite,
            color: symptom.painLevel >= 7 ? Colors.red : const Color(0xFF7B61FF),
            size: 20,
          ),
        ),
        title: Text(
          _formatDate(symptom.date),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          symptom.symptoms.take(2).join(', '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: symptom.painLevel >= 7 ? Colors.red.withOpacity(0.1) : const Color(0xFF7B61FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Pain: ${symptom.painLevel}/10',
            style: TextStyle(
              color: symptom.painLevel >= 7 ? Colors.red : const Color(0xFF7B61FF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          context.push('${AppConstants.routeEditSymptom}?id=${symptom.id}');
        },
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
  
  Widget _buildComingSoonCard(BuildContext context, String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF7B61FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF7B61FF), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }
}