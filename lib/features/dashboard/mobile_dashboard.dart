import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/shared/utils/responsive_utils.dart';
import 'package:sparkle_lite/providers/auth_provider.dart';
import 'package:sparkle_lite/providers/symptom_provider.dart';
import 'package:sparkle_lite/providers/record_provider.dart';
import 'dashboard_components.dart';


class MobileDashboard extends ConsumerWidget {
  const MobileDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final symptomState = ref.watch(symptomProvider);
    final recordState = ref.watch(recordProvider);
    final user = authState.user;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(symptomProvider.notifier).loadSymptoms(),
              ref.read(recordProvider.notifier).loadRecords(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(context.responsivePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                ResponsiveText(
                  'Hello, ${user?.name ?? "User"}! 👋',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ResponsiveText(
                  'Welcome to your health companion',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: context.responsiveSpacing),

                // Quick Actions Grid
                _buildQuickActionsGrid(context),
                
                SizedBox(height: context.responsiveSpacing),

                // Recent Symptoms Section
                DashboardComponents.buildRecentSymptomsSection(context, ref, symptomState),
                
                SizedBox(height: context.responsiveSpacing),

                // Recent Records Section
                DashboardComponents.buildRecentRecordsSection(context, ref, recordState),
                
                SizedBox(height: context.responsiveSpacing),

                // Health Tools
                _buildHealthToolsSection(context),

                SizedBox(height: context.responsiveSpacing),

                // Privacy reminder
                DashboardComponents.buildPrivacyReminder(context),
                
                SizedBox(height: context.responsivePadding),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      _MobileQuickAction(
        title: 'Log Symptom',
        icon: Icons.favorite_outline,
        color: Colors.red,
        route: AppConstants.routeAddSymptom,
      ),
      _MobileQuickAction(
        title: 'Upload Record',
        icon: Icons.cloud_upload_outlined,
        color: const Color(0xFF7B61FF),
        route: AppConstants.routeUploadRecord,
      ),
      _MobileQuickAction(
        title: 'AI Insight',
        icon: Icons.psychology_outlined,
        color: const Color(0xFF4ECDC4),
        route: AppConstants.routeAIInsightInput,
      ),
      _MobileQuickAction(
        title: 'Timeline',
        icon: Icons.timeline,
        color: Colors.orange,
        route: AppConstants.routeTimeline,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.actionsPerRow,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildQuickActionCard(context, action);
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, _MobileQuickAction action) {
    return InkWell(
      onTap: () => context.push(action.route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.color, size: 32),
            const SizedBox(height: 8),
                    Text(
              action.title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthToolsSection(BuildContext context) {
    final tools = [
      _MobileHealthTool(
        title: 'Doctor Visit Summary',
        subtitle: 'Prepare for your appointment',
        icon: Icons.medical_services_outlined,
        route: AppConstants.routeDoctorSummary,
      ),
      _MobileHealthTool(
        title: 'Privacy Settings',
        subtitle: 'Control your data',
        icon: Icons.privacy_tip_outlined,
        route: AppConstants.routePrivacySettings,
      ),
      _MobileHealthTool(
        title: 'Family Members',
        subtitle: 'Manage family profiles',
        icon: Icons.family_restroom,
        route: AppConstants.routeFamilyList,
      ),
      _MobileHealthTool(
        title: 'Notifications',
        subtitle: 'Configure alerts',
        icon: Icons.notifications_outlined,
        route: AppConstants.routeNotificationSettings,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Tools',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        const SizedBox(height: 12),
        ...tools.map((tool) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildHealthToolTile(context, tool),
        )),
      ],
    );
  }

  Widget _buildHealthToolTile(BuildContext context, _MobileHealthTool tool) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF7B61FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(tool.icon, color: const Color(0xFF7B61FF), size: 24),
        ),
        title: Text(
          tool.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          tool.subtitle,
          style: const TextStyle(fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => context.push(tool.route),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: const Color(0xFF7B61FF),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: 'Symptoms',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_outlined),
          activeIcon: Icon(Icons.folder),
          label: 'Records',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        if (index == 1) {
          context.push(AppConstants.routeSymptomHistory);
        } else if (index == 2) {
          context.push(AppConstants.routeRecordsList);
        }
      },
    );
  }
}

// Internal classes for mobile
class _MobileQuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  
  _MobileQuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _MobileHealthTool {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  
  _MobileHealthTool({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}