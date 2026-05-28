import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/shared/utils/responsive_utils.dart';
import 'mobile_dashboard.dart';
import 'web_dashboard.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ResponsiveBuilder(
        builder: (context, isMobile, isTablet, isDesktop) {
          if (isDesktop || isTablet) {
            return const WebDashboard();
          } else {
            return const MobileDashboard();
          }
        },
      ),
    );
  }
}