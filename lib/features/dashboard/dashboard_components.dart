import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/Data/models/health_record_model.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';
import 'package:sparkle_lite/providers/record_provider.dart';
import 'package:sparkle_lite/providers/symptom_provider.dart';
import 'package:sparkle_lite/shared/utils/responsive_utils.dart';
import 'package:sparkle_lite/shared/widgets/empty_state_widget.dart'; 

/// This file contains reusable components for the dashboard screen, such as stat cards, recent activity sections, and quick action buttons.
/// These components are designed to be used in both the mobile and web versions of the dashboard,

class DashboardComponents {
  // QUICK ACTIONS 
  static Widget buildQuickActionsGrid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final actions = [
      _QuickAction(
        title: 'Log Symptom',
        icon: Icons.favorite_outline,
        color: Colors.red,
        route: AppConstants.routeAddSymptom,
      ),
      _QuickAction(
        title: 'Upload Record',
        icon: Icons.cloud_upload_outlined,
        color: const Color(0xFF7B61FF),
        route: AppConstants.routeUploadRecord,
      ),
      _QuickAction(
        title: 'AI Insight',
        icon: Icons.psychology_outlined,
        color: const Color(0xFF4ECDC4),
        route: AppConstants.routeAIInsightInput,
      ),
      _QuickAction(
        title: 'Timeline',
        icon: Icons.timeline,
        color: Colors.orange,
        route: AppConstants.routeTimeline,
      ),
      _QuickAction(
        title: 'Doctor Visit',
        icon: Icons.medical_services_outlined,
        color: Colors.purple,
        route: AppConstants.routeDoctorSummary,
      ),
      _QuickAction(
        title: 'Family',
        icon: Icons.family_restroom,
        color: Colors.teal,
        route: AppConstants.routeFamilyList,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ResponsiveGrid(
          children: actions.map((action) => _buildQuickActionCard(context, action)).toList(),
          childAspectRatio: context.quickActionHeight / 100,
        ),
      ],
    );
  }

  static Widget _buildQuickActionCard(BuildContext context, _QuickAction action) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: () => context.push(action.route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: action.color.withOpacity(isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.color, size: 28),
            const SizedBox(height: 8),
            ResponsiveText(
              action.title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // STAT CARDS (Web) 
  static Widget buildStatCards(BuildContext context, WidgetRef ref) {
    final symptomState = ref.watch(symptomProvider);
    final recordState = ref.watch(recordProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveRow(
      children: [
        _buildStatCard(
          context,
          'Total Symptoms',
          '${symptomState.symptoms.length}',
          Icons.favorite,
          Colors.red,
          isDark,
        ),
        _buildStatCard(
          context,
          'Health Records',
          '${recordState.records.length}',
          Icons.folder,
          const Color(0xFF7B61FF),
          isDark,
        ),
        _buildStatCard(
          context,
          'AI Insights',
          '0',
          Icons.psychology,
          const Color(0xFF4ECDC4),
          isDark,
        ),
      ],
    );
  }

  static Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.all(context.responsivePadding),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: context.isMobile ? 24 : 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: context.captionSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // RECENT SYMPTOMS 
  static Widget buildRecentSymptomsSection(BuildContext context, WidgetRef ref, SymptomState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Symptoms',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppConstants.routeSymptomHistory),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRecentSymptomsContent(context, ref, state),
      ],
    );
  }

  static Widget _buildRecentSymptomsContent(BuildContext context, WidgetRef ref, SymptomState state) {
    if (state.isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ));
    }

    if (state.recentSymptoms.isEmpty) {
      return EmptyStateWidget(
        title: 'No symptoms yet',
        message: 'Start tracking your health journey',
        buttonText: 'Log Symptom',
        onButtonPressed: () => context.push(AppConstants.routeAddSymptom),
        icon: Icons.favorite_outline,
      );
    }

    return Column(
      children: state.recentSymptoms.map((symptom) => _buildSymptomTile(context, symptom)).toList(),
    );
  }

  static Widget _buildSymptomTile(BuildContext context, SymptomLog symptom) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: ListTile(
        dense: context.isDesktop,
        leading: CircleAvatar(
          radius: context.isMobile ? 20 : 24,
          backgroundColor: symptom.painLevel >= 7
              ? Colors.red.withOpacity(0.2)
              : const Color(0xFF7B61FF).withOpacity(0.2),
          child: Icon(
            Icons.favorite,
            color: symptom.painLevel >= 7 ? Colors.red : const Color(0xFF7B61FF),
            size: context.isMobile ? 20 : 24,
          ),
        ),
        title: Text(
          _formatDate(symptom.date),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: context.bodySize,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          symptom.symptoms.take(2).join(', '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: context.captionSize,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: symptom.painLevel >= 7
                ? Colors.red.withOpacity(0.2)
                : const Color(0xFF7B61FF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Pain: ${symptom.painLevel}/10',
            style: TextStyle(
              color: symptom.painLevel >= 7 ? Colors.red : const Color(0xFF7B61FF),
              fontSize: context.captionSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () => context.push('${AppConstants.routeEditSymptom}?id=${symptom.id}'),
      ),
    );
  }

  //  RECENT RECORDS
  static Widget buildRecentRecordsSection(BuildContext context, WidgetRef ref, RecordState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Health Records',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppConstants.routeRecordsList),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRecentRecordsContent(context, ref, state),
      ],
    );
  }

  static Widget _buildRecentRecordsContent(BuildContext context, WidgetRef ref, RecordState state) {
    if (state.isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ));
    }

    if (state.recentRecords.isEmpty) {
      return EmptyStateWidget(
        title: 'No records yet',
        message: 'Upload health records to keep them organized',
        buttonText: 'Upload Record',
        onButtonPressed: () => context.push(AppConstants.routeUploadRecord),
        icon: Icons.folder_outlined,
      );
    }

    return Column(
      children: state.recentRecords.map((record) => _buildRecordTile(context, record)).toList(),
    );
  }

  static Widget _buildRecordTile(BuildContext context, HealthRecord record) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: ListTile(
        dense: context.isDesktop,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF7B61FF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(record.recordType.icon, color: const Color(0xFF7B61FF), size: context.isMobile ? 20 : 24),
        ),
        title: Text(
          record.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: context.bodySize,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${record.recordType.displayName} • ${_formatDate(record.recordDate)}',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: context.captionSize,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: isDark ? Colors.grey[600] : Colors.grey[400]),
        onTap: () => context.push('${AppConstants.routeRecordDetail}?id=${record.id}'),
      ),
    );
  }

  // ACTION CARDS (Web) 
  static Widget buildActionCards(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final actions = [
      _ActionCard(
        title: 'Log Symptom',
        subtitle: 'Track your daily symptoms',
        icon: Icons.favorite_outline,
        color: Colors.red,
        route: AppConstants.routeAddSymptom,
      ),
      _ActionCard(
        title: 'Upload Record',
        subtitle: 'Add health documents',
        icon: Icons.cloud_upload_outlined,
        color: const Color(0xFF7B61FF),
        route: AppConstants.routeUploadRecord,
      ),
      _ActionCard(
        title: 'AI Insight',
        subtitle: 'Generate health insights',
        icon: Icons.psychology_outlined,
        color: const Color(0xFF4ECDC4),
        route: AppConstants.routeAIInsightInput,
      ),
      _ActionCard(
        title: 'Doctor Summary',
        subtitle: 'Prepare for visit',
        icon: Icons.medical_services_outlined,
        color: Colors.purple,
        route: AppConstants.routeDoctorSummary,
      ),
    ];

    return ResponsiveRow(
      children: actions.map((action) => _buildActionCard(context, action)).toList(),
    );
  }

  static Widget _buildActionCard(BuildContext context, _ActionCard action) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: InkWell(
        onTap: () => context.push(action.route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(context.responsivePadding),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color, size: context.isMobile ? 28 : 32),
              ),
              SizedBox(height: context.smallSpacing),
              ResponsiveText(
                action.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              ResponsiveText(
                action.subtitle,
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  HEALTH TOOLS 
  static Widget buildHealthToolsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final tools = [
      _HealthTool(
        title: 'Doctor Visit Summary',
        subtitle: 'Prepare for your next appointment',
        icon: Icons.medical_services_outlined,
        route: AppConstants.routeDoctorSummary,
      ),
      _HealthTool(
        title: 'Privacy Settings',
        subtitle: 'Control your data preferences',
        icon: Icons.privacy_tip_outlined,
        route: AppConstants.routePrivacySettings,
      ),
      _HealthTool(
        title: 'Family Members',
        subtitle: 'Manage family health profiles',
        icon: Icons.family_restroom,
        route: AppConstants.routeFamilyList,
      ),
      _HealthTool(
        title: 'Notification Settings',
        subtitle: 'Configure your alerts',
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
          child: _buildHealthToolTile(context, tool),
        )),
      ],
    );
  }

  static Widget _buildHealthToolTile(BuildContext context, _HealthTool tool) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF7B61FF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(tool.icon, color: const Color(0xFF7B61FF)),
        ),
        title: Text(
          tool.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: context.bodySize,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          tool.subtitle,
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: context.captionSize),
        ),
        trailing: Icon(Icons.chevron_right, color: isDark ? Colors.grey[600] : Colors.grey[400]),
        onTap: () => context.push(tool.route),
      ),
    );
  }

  //  PRIVACY REMINDER 
  static Widget buildPrivacyReminder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(context.responsivePadding),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: context.isMobile ? 18 : 20, color: isDark ? Colors.grey[500] : Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: ResponsiveText(
              'Your data is private and secure',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  //  HELPERS 
  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    return '${date.month}/${date.day}/${date.year}';
  }
}

//  INTERNAL CLASSES 
class _QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  
  _QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _ActionCard {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  
  _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _HealthTool {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  
  _HealthTool({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}