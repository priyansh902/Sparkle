import 'package:flutter/material.dart';


/// Represents the data for each onboarding step, including title, description, icon, and color.
/// used in onboarding screen to display the onboarding pages.
class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}