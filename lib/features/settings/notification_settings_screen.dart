import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/providers/settings_provider.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';

/// This screen allows users to customize their notification preferences, including enabling/disabling reminders, choosing specific reminder types, and setting privacy options for notifications. It interacts with the SettingsProvider to load and save these preferences, which are persisted in a mock database service for demonstration purposes. The UI includes toggles for different notification types and a preview of how notifications will appear based on the user's settings. The screen is designed to be user-friendly and informative, helping users understand the implications of their notification choices on their privacy and app experience.
/// TODO: Integrate with actual notification scheduling and handling logic to reflect changes in real-time.

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  late bool _enableReminders;
  late bool _periodReminders;
  late bool _medicationReminders;
  late bool _appointmentReminders;
  late bool _insightAlerts;
  late bool _useGenericText;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(settingsProvider.notifier).loadSettings();
    setState(() {
      // For demo purposes, we'll initialize with defaults
      _enableReminders = true;
      _periodReminders = true;
      _medicationReminders = false;
      _appointmentReminders = true;
      _insightAlerts = true;
      _useGenericText = settings.genericNotifications;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    // Save notification preferences
    // In a real app, you'd save these to SharedPreferences or Firebase
    
    // Update privacy setting for generic notifications
    final currentSettings = ref.read(settingsProvider);
    await ref.read(settingsProvider.notifier).saveSettings(
      hideDashboardDetails: currentSettings.hideDashboardDetails,
      genericNotifications: _useGenericText,
      requireConfirmationBeforeSharing: currentSettings.requireConfirmationBeforeSharing,
      enableFamilyAccess: currentSettings.enableFamilyAccess,
      allowAnalytics: currentSettings.allowAnalytics,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification settings saved')),
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
        title: const Text('Notification Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7B61FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Color(0xFF7B61FF), size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stay Informed',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose how and when you receive health reminders and updates.',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Main notification toggle
            _buildSettingsSection(
              title: 'Notifications',
              children: [
                SwitchListTile(
                  title: const Text('Enable Reminders'),
                  subtitle: const Text('Receive health reminders and notifications'),
                  value: _enableReminders,
                  onChanged: (value) {
                    setState(() => _enableReminders = value);
                  },
                  activeColor: const Color(0xFF7B61FF),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Reminder types (only if enabled)
            if (_enableReminders) ...[
              _buildSettingsSection(
                title: 'Reminder Types',
                children: [
                  SwitchListTile(
                    title: const Text('Period Tracking Reminders'),
                    subtitle: const Text('Get reminders to log your period and symptoms'),
                    value: _periodReminders,
                    onChanged: (value) {
                      setState(() => _periodReminders = value);
                    },
                    activeColor: const Color(0xFF7B61FF),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Medication Reminders'),
                    subtitle: const Text('Reminders to take your medications'),
                    value: _medicationReminders,
                    onChanged: (value) {
                      setState(() => _medicationReminders = value);
                    },
                    activeColor: const Color(0xFF7B61FF),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Appointment Reminders'),
                    subtitle: const Text('Reminders for upcoming doctor visits'),
                    value: _appointmentReminders,
                    onChanged: (value) {
                      setState(() => _appointmentReminders = value);
                    },
                    activeColor: const Color(0xFF7B61FF),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('AI Insight Alerts'),
                    subtitle: const Text('Get notified when new health insights are available'),
                    value: _insightAlerts,
                    onChanged: (value) {
                      setState(() => _insightAlerts = value);
                    },
                    activeColor: const Color(0xFF7B61FF),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Privacy notice for notifications
              _buildSettingsSection(
                title: 'Notification Privacy',
                children: [
                  SwitchListTile(
                    title: const Text('Use generic notification text'),
                    subtitle: const Text(
                      'Example: "You have a health reminder" instead of specific medication reminders',
                    ),
                    value: _useGenericText,
                    onChanged: (value) {
                      setState(() => _useGenericText = value);
                    },
                    activeColor: const Color(0xFF7B61FF),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Generic notifications help protect your privacy by hiding sensitive health information from your lock screen.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Example notification preview
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preview',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7B61FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.notifications,
                              color: Color(0xFF7B61FF),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sparkle Lite',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _useGenericText
                                      ? 'You have a health reminder'
                                      : 'Time to log your symptoms for today',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _useGenericText
                          ? '🔒 Generic mode: No sensitive info visible'
                          : '⚠️ Specific mode: Health details may be visible on lock screen',
                      style: TextStyle(
                        fontSize: 11,
                        color: _useGenericText ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            PrimaryButton(
              text: 'Save Notification Settings',
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
}