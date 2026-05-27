import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return RefreshIndicator(
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
            DashboardComponents.buildQuickActionsGrid(context),
            
            SizedBox(height: context.responsiveSpacing),

            // Recent Symptoms Section
            DashboardComponents.buildRecentSymptomsSection(context, ref, symptomState),
            
            SizedBox(height: context.responsiveSpacing),

            // Recent Records Section
            DashboardComponents.buildRecentRecordsSection(context, ref, recordState),
            
            SizedBox(height: context.responsiveSpacing),

            // Health Tools
            DashboardComponents.buildHealthToolsSection(context),

            SizedBox(height: context.responsiveSpacing),

            // Privacy reminder
            DashboardComponents.buildPrivacyReminder(context),
            
            SizedBox(height: context.responsivePadding),
          ],
        ),
      ),
    );
  }
}