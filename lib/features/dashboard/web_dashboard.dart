
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/shared/utils/responsive_utils.dart';
import 'package:sparkle_lite/providers/auth_provider.dart';
import 'package:sparkle_lite/providers/symptom_provider.dart';
import 'package:sparkle_lite/providers/record_provider.dart';
import 'dashboard_components.dart';

class WebDashboard extends ConsumerWidget {
  const WebDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final symptomState = ref.watch(symptomProvider);
    final recordState = ref.watch(recordProvider);
    final user = authState.user;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar Navigation - Fixed height with scrolling
        SizedBox(
          width: context.isTablet ? 250 : 280,
          height: context.screenHeight,
          child: _buildSidebar(context, ref, user),
        ),
        
        // Main Content - Scrollable
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.responsivePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                ResponsiveText(
                  'Welcome Lady Sparkle! ✨, ${user?.name ?? "User"}!',
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 8),
                ResponsiveText(
                  'Here\'s your health overview',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: context.responsiveSpacing),

                // Stats cards in row
                DashboardComponents.buildStatCards(context, ref),
                
                SizedBox(height: context.responsiveSpacing),

                // Two column layout
                ResponsiveTwoColumns(
                  leftColumn: DashboardComponents.buildRecentSymptomsSection(context, ref, symptomState),
                  rightColumn: DashboardComponents.buildRecentRecordsSection(context, ref, recordState),
                ),
                
                SizedBox(height: context.responsiveSpacing),

                // Quick actions cards
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                DashboardComponents.buildActionCards(context),

                SizedBox(height: context.responsiveSpacing),

                // Privacy footer
                DashboardComponents.buildPrivacyReminder(context),
                
                SizedBox(height: context.responsivePadding),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref, dynamic user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B61FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.spa, color: Color(0xFF7B61FF), size: 28),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sparkle Lite',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // User info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7B61FF).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person_outline, color: Color(0xFF7B61FF)),
                  const SizedBox(height: 8),
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Navigation items - Wrap in Expanded to prevent overflow
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildNavItem(context, Icons.dashboard, 'Dashboard', true, () {}),
                  _buildNavItem(context, Icons.favorite, 'Symptoms', false, () {
                    context.push(AppConstants.routeSymptomHistory);
                  }),
                  _buildNavItem(context, Icons.folder, 'Records', false, () {
                    context.push(AppConstants.routeRecordsList);
                  }),
                  _buildNavItem(context, Icons.timeline, 'Timeline', false, () {
                    context.push(AppConstants.routeTimeline);
                  }),
                  _buildNavItem(context, Icons.psychology, 'AI Insights', false, () {
                    context.push(AppConstants.routeAIInsightInput);
                  }),
                  _buildNavItem(context, Icons.medical_services, 'Doctor Visit', false, () {
                    context.push(AppConstants.routeDoctorSummary);
                  }),
                  _buildNavItem(context, Icons.family_restroom, 'Family', false, () {
                    context.push(AppConstants.routeFamilyList);
                  }),
                  _buildNavItem(context, Icons.privacy_tip, 'Privacy', false, () {
                    context.push(AppConstants.routePrivacySettings);
                  }),
                ],
              ),
            ),
          ),
          // Logout button - at bottom, not overflowing
          Padding(
            padding: const EdgeInsets.all(24),
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go(AppConstants.routeWelcome);
                }
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7B61FF).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF7B61FF) : Colors.grey[600],
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF7B61FF) : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}