import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/providers/auth_provider.dart';
import 'package:sparkle_lite/providers/insight_provider.dart';
import 'package:sparkle_lite/providers/record_provider.dart';
import 'package:sparkle_lite/providers/symptom_provider.dart';
import 'package:sparkle_lite/shared/utils/responsive_utils.dart';
import 'dashboard_components.dart';


class MobileDashboard extends ConsumerWidget {
  const MobileDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final symptomState = ref.watch(symptomProvider);
    final recordState = ref.watch(recordProvider);
    final insightState = ref.watch(insightProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sparkle Lite',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => _logout(ref, context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(symptomProvider.notifier).loadSymptoms(),
              ref.read(recordProvider.notifier).loadRecords(),
              ref.read(insightProvider.notifier).loadInsights(),
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
                  'Welcome Lady Sparkle ✨ ${user?.name ?? "User"}',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                ResponsiveText(
                  'Welcome to your health companion',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                SizedBox(height: context.responsiveSpacing),

                // Quick Actions Grid
                DashboardComponents.buildQuickActionsGrid(context),
                
                SizedBox(height: context.responsiveSpacing),

                // Recent Symptoms Section
                DashboardComponents.buildRecentSymptomsSection(context, ref, symptomState),
                
                SizedBox(height: context.responsiveSpacing),

                // Recent Records Section
                DashboardComponents.buildRecentRecordsSection(context, ref, recordState),
                
                SizedBox(height: context.responsiveSpacing),

                // Recent AI Insights Section
                DashboardComponents.buildRecentInsightsSection(context, ref, insightState),

                SizedBox(height: context.responsiveSpacing),

                // Health Tools
                _buildHealthToolsSection(context, isDark),

                SizedBox(height: context.responsiveSpacing),

                // Privacy reminder
                DashboardComponents.buildPrivacyReminder(context),
                
                SizedBox(height: context.responsivePadding),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
    );
  }

  // ✅ ADD LOGOUT METHOD
  void _logout(WidgetRef ref, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        context.go(AppConstants.routeWelcome);
      }
    }
  }

  Widget _buildHealthToolsSection(BuildContext context, bool isDark) {
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
        Text(
          'Health Tools',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...tools.map((tool) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildHealthToolTile(context, tool, isDark),
        )),
      ],
    );
  }

  Widget _buildHealthToolTile(BuildContext context, _MobileHealthTool tool, bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF7B61FF).withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(tool.icon, color: const Color(0xFF7B61FF), size: 24),
        ),
        title: Text(
          tool.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          tool.subtitle,
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
        ),
        trailing: Icon(Icons.chevron_right, color: isDark ? Colors.grey[600] : Colors.grey[400]),
        onTap: () => context.push(tool.route),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isDark) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: const Color(0xFF7B61FF),
      unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
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
        } else if (index == 3) {
          context.push(AppConstants.routeProfile);
        }
      },
    );
  }
}

// Internal classes for mobile
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