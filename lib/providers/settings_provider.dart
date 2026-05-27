import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/Data/models/privacy_settings_model.dart';
import 'package:sparkle_lite/Data/repositiories/settings_repository.dart';
import 'auth_provider.dart';

/// This file contains the SettingsRepository and SettingsNotifier for managing user privacy settings.
/// The SettingsRepository abstracts the data access layer, while the SettingsNotifier manages the state of the privacy settings in the app. The settingsProvider is a StateNotifierProvider that allows the UI to interact with the settings state and perform actions like loading and saving settings.
/// The PrivacySettings model is defined in the privacy_settings_model.dart file and includes fields for various privacy options that users can configure in the app. The SettingsNotifier uses the SettingsRepository to load and save these settings to a mock database service, which simulates data persistence for demonstration purposes.


class SettingsNotifier extends StateNotifier<PrivacySettings> {
  final SettingsRepository _repository;
  final String? _userId;
  
  SettingsNotifier(this._repository, this._userId) : super(const PrivacySettings()) {
    if (_userId != null) {
      loadSettings();
    }
  }
  
  Future<PrivacySettings> loadSettings() async {
    if (_userId == null) return const PrivacySettings();
    
    final settings = await _repository.getSettings(_userId);
    state = settings;
    return settings;
  }
  
  Future<void> saveSettings({
    required bool hideDashboardDetails,
    required bool genericNotifications,
    required bool requireConfirmationBeforeSharing,
    required bool enableFamilyAccess,
    required bool allowAnalytics,
  }) async {
    if (_userId == null) return;
    
    final newSettings = PrivacySettings(
      hideDashboardDetails: hideDashboardDetails,
      genericNotifications: genericNotifications,
      requireConfirmationBeforeSharing: requireConfirmationBeforeSharing,
      enableFamilyAccess: enableFamilyAccess,
      allowAnalytics: allowAnalytics,
    );
    
    await _repository.saveSettings(newSettings, _userId);
    state = newSettings;
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, PrivacySettings>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id;
  final repository = ref.read(settingsRepositoryProvider);
  return SettingsNotifier(repository, userId);
});