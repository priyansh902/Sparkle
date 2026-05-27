import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/providers/settings_provider.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';

/// This screen allows users to manage their privacy settings, including dashboard visibility, notification preferences, sharing options, and data analytics permissions. It also includes a "Danger Zone" for account deletion and data export.
/// The settings are loaded from the repository when the screen initializes and can be saved back to the repository when the user taps the "Save Settings" button. The screen uses Riverpod for state management and assumes that the `SettingsRepository` is properly implemented to handle data persistence.
/// The UI is designed to be user-friendly, with clear sections for different types of settings and a prominent save button. The "Danger Zone" is visually distinct to warn users about the consequences of those actions.

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

  @override
  Widget build(BuildContext context) {
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
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your privacy matters. These settings control how your data is displayed and shared.',
                      style: TextStyle(color: Colors.blue[800], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Dashboard privacy
            _buildSettingsSection(
              title: 'Dashboard Privacy',
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
            
            // Sharing preferences
            _buildSettingsSection(
              title: 'Sharing Preferences',
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
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Danger Zone',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(height: 0, color: Colors.red),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Delete Account'),
                    subtitle: const Text('Permanently delete all your health data'),
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.download, color: Colors.red),
                    title: const Text('Export All Data'),
                    subtitle: const Text('Download a copy of your health data'),
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
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          ...children,
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