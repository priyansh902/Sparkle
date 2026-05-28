import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/providers/settings_provider.dart';
import 'package:sparkle_lite/providers/theme_provider.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  late bool _hideDashboardDetails;
  late bool _genericNotifications;
  late bool _requireConfirmation;
  late bool _enableFamilyAccess;
  late bool _allowAnalytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(settingsProvider.notifier).loadSettings();
    setState(() {
      _hideDashboardDetails = settings.hideDashboardDetails;
      _genericNotifications = settings.genericNotifications;
      _requireConfirmation = settings.requireConfirmationBeforeSharing;
      _enableFamilyAccess = settings.enableFamilyAccess;
      _allowAnalytics = settings.allowAnalytics;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await ref.read(settingsProvider.notifier).saveSettings(
      hideDashboardDetails: _hideDashboardDetails,
      genericNotifications: _genericNotifications,
      requireConfirmationBeforeSharing: _requireConfirmation,
      enableFamilyAccess: _enableFamilyAccess,
      allowAnalytics: _allowAnalytics,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  Future<void> _setThemeMode(ThemeModeType mode) async {
    await ref.read(themeProvider.notifier).setThemeMode(mode);
    // Force rebuild of the app by triggering a state change
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeState = ref.watch(themeProvider);
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: isDark ? Colors.blue[300] : Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your privacy matters. These settings control how your data is displayed and shared.',
                      style: TextStyle(color: isDark ? Colors.blue[300] : Colors.blue[800], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Dashboard privacy
            _buildSettingsSection(
              title: 'Dashboard Privacy',
              isDark: isDark,
              children: [
                SwitchListTile(
                  title: const Text('Hide sensitive dashboard details'),
                  subtitle: const Text('Show generic text instead of specific health information'),
                  value: _hideDashboardDetails,
                  onChanged: (value) {
                    setState(() => _hideDashboardDetails = value);
                  },
                  activeColor: const Color(0xFF7B61FF),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Notification privacy
            _buildSettingsSection(
              title: 'Notification Privacy',
              isDark: isDark,
              children: [
                SwitchListTile(
                  title: const Text('Use generic notification text'),
                  subtitle: const Text('Example: "You have a health reminder" instead of specific medication reminders'),
                  value: _genericNotifications,
                  onChanged: (value) {
                    setState(() => _genericNotifications = value);
                  },
                  activeColor: const Color(0xFF7B61FF),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Theme Section (Appearance)
            _buildThemeSection(isDark, themeState),
            
            const SizedBox(height: 16),
            
            // Sharing preferences
            _buildSettingsSection(
              title: 'Sharing Preferences',
              isDark: isDark,
              children: [
                SwitchListTile(
                  title: const Text('Require confirmation before sharing records'),
                  subtitle: const Text('Ask for confirmation when sharing health data'),
                  value: _requireConfirmation,
                  onChanged: (value) {
                    setState(() => _requireConfirmation = value);
                  },
                  activeColor: const Color(0xFF7B61FF),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Enable family profile access'),
                  subtitle: const Text('Allow family members to view your health data'),
                  value: _enableFamilyAccess,
                  onChanged: (value) {
                    setState(() => _enableFamilyAccess = value);
                  },
                  activeColor: const Color(0xFF7B61FF),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Data & analytics
            _buildSettingsSection(
              title: 'Data & Analytics',
              isDark: isDark,
              children: [
                SwitchListTile(
                  title: const Text('Allow anonymous analytics'),
                  subtitle: const Text('Help improve the app by sharing anonymous usage data'),
                  value: _allowAnalytics,
                  onChanged: (value) {
                    setState(() => _allowAnalytics = value);
                  },
                  activeColor: const Color(0xFF7B61FF),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Danger zone
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.red[900]?.withOpacity(0.3) : Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.red[800]! : Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Danger Zone',
                      style: TextStyle(
                        color: isDark ? Colors.red[300] : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Divider(height: 0, color: isDark ? Colors.red[800] : Colors.red[200]),
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: isDark ? Colors.red[300] : Colors.red),
                    title: Text('Delete Account', style: TextStyle(color: isDark ? Colors.red[300] : Colors.red)),
                    subtitle: Text('Permanently delete all your health data', style: TextStyle(color: isDark ? Colors.red[300]?.withOpacity(0.7) : Colors.red[700])),
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                  ListTile(
                    leading: Icon(Icons.download, color: isDark ? Colors.red[300] : Colors.red),
                    title: Text('Export All Data', style: TextStyle(color: isDark ? Colors.red[300] : Colors.red)),
                    subtitle: Text('Download a copy of your health data', style: TextStyle(color: isDark ? Colors.red[300]?.withOpacity(0.7) : Colors.red[700])),
                    onTap: () => _showExportDialog(context),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            PrimaryButton(
              text: 'Save Settings',
              onPressed: _saveSettings,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingsSection({
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
  
  Widget _buildThemeSection(bool isDark, ThemeState themeState) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          RadioListTile<ThemeModeType>(
            title: Text('Light Mode', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            subtitle: Text('Always use light theme', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
            value: ThemeModeType.light,
            groupValue: themeState.mode,
            onChanged: (value) {
              if (value != null) {
                _setThemeMode(value);
              }
            },
            activeColor: const Color(0xFF7B61FF),
          ),
          RadioListTile<ThemeModeType>(
            title: Text('Dark Mode', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            subtitle: Text('Always use dark theme', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
            value: ThemeModeType.dark,
            groupValue: themeState.mode,
            onChanged: (value) {
              if (value != null) {
                _setThemeMode(value);
              }
            },
            activeColor: const Color(0xFF7B61FF),
          ),
          RadioListTile<ThemeModeType>(
            title: Text('System Default', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            subtitle: Text('Follow device theme settings', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
            value: ThemeModeType.system,
            groupValue: themeState.mode,
            onChanged: (value) {
              if (value != null) {
                _setThemeMode(value);
              }
            },
            activeColor: const Color(0xFF7B61FF),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your symptoms, records, and health data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion is a mock action for this demo')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Your data export will be prepared and downloaded shortly.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export is a mock action for this demo')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}