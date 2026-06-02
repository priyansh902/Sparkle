import 'package:equatable/equatable.dart';

class PrivacySettings extends Equatable {
  final bool hideDashboardDetails;
  final bool genericNotifications;
  final bool requireConfirmationBeforeSharing;
  final bool enableFamilyAccess;
  final bool allowAnalytics;
  
  const PrivacySettings({
    this.hideDashboardDetails = false,
    this.genericNotifications = true,
    this.requireConfirmationBeforeSharing = true,
    this.enableFamilyAccess = false,
    this.allowAnalytics = false,
  });
  
  @override
  List<Object?> get props => [
    hideDashboardDetails,
    genericNotifications,
    requireConfirmationBeforeSharing,
    enableFamilyAccess,
    allowAnalytics,
  ];
  
  Map<String, dynamic> toJson() {
    return {
      'hideDashboardDetails': hideDashboardDetails,
      'genericNotifications': genericNotifications,
      'requireConfirmationBeforeSharing': requireConfirmationBeforeSharing,
      'enableFamilyAccess': enableFamilyAccess,
      'allowAnalytics': allowAnalytics,
    };
  }
  
  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      hideDashboardDetails: json['hideDashboardDetails'] ?? false,
      genericNotifications: json['genericNotifications'] ?? true,
      requireConfirmationBeforeSharing: json['requireConfirmationBeforeSharing'] ?? true,
      enableFamilyAccess: json['enableFamilyAccess'] ?? false,
      allowAnalytics: json['allowAnalytics'] ?? false,
    );
  }
  
  PrivacySettings copyWith({
    bool? hideDashboardDetails,
    bool? genericNotifications,
    bool? requireConfirmationBeforeSharing,
    bool? enableFamilyAccess,
    bool? allowAnalytics,
  }) {
    return PrivacySettings(
      hideDashboardDetails: hideDashboardDetails ?? this.hideDashboardDetails,
      genericNotifications: genericNotifications ?? this.genericNotifications,
      requireConfirmationBeforeSharing: requireConfirmationBeforeSharing ?? this.requireConfirmationBeforeSharing,
      enableFamilyAccess: enableFamilyAccess ?? this.enableFamilyAccess,
      allowAnalytics: allowAnalytics ?? this.allowAnalytics,
    );
  }
}