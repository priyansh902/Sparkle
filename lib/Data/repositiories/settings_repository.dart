import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/core/services/firebase_database_service.dart';
import '../../core/interfaces/database_interface.dart';
// import '../../core/services/mock_database_service.dart';
import '../models/privacy_settings_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {

  // final databaseService = MockDatabaseService();

  final databaseService = FirebaseDatabaseService();

  return SettingsRepository(databaseService: databaseService);
});

class SettingsRepository {
  final DatabaseInterface databaseService;
  
  SettingsRepository({required this.databaseService});
  
  Future<PrivacySettings> getSettings(String userId) async {
    return await databaseService.getPrivacySettings(userId);
  }
  
  Future<void> saveSettings(PrivacySettings settings, String userId) async {
    await databaseService.savePrivacySettings(settings, userId);
  }
}