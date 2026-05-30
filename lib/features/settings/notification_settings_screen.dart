import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/providers/settings_provider.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';

/// A screen for managing notification settings, including reminder types and privacy options.
/// This screen allows users to customize how they receive health reminders and notifications, with a focus on privacy and user control.  

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
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
                color: const Color(0xFF7B61FF).withOpacity(isDark ? 0.15 : 0.1),
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
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 13),
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
              isDark: isDark,
              children: [
                SwitchListTile(
                  title: Text('Enable Reminders', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  subtitle: Text('Receive health reminders and notifications', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
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
                isDark: isDark,
                children: [
                  SwitchListTile(
                    title: Text('Period Tracking Reminders', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text('Get reminders to log your period and symptoms', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    value: _periodReminders,
                    onChanged: (value) {
                      setState(() => _periodReminders = value);
                    },
                    activeColor: const Color(0xFF7B61FF),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: Text('Medication Reminders', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text('Reminders to take your medications', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    value: _medicationReminders,
                    onChanged: (value) {
                      setState(() => _medicationReminders = value);
                    },
                    activeColor: const Color(0xFF7B61FF),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: Text('Appointment Reminders', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text('Reminders for upcoming doctor visits', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    value: _appointmentReminders,
                    onChanged: (value) {
                      setState(() => _appointmentReminders = value);
                    },
                    activeColor: const Color(0xFF7B61FF),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: Text('AI Insight Alerts', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text('Get notified when new health insights are available', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
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
                isDark: isDark,
                children: [
                  SwitchListTile(
                    title: Text('Use generic notification text', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text(
                      'Example: "You have a health reminder" instead of specific medication reminders',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    value: _useGenericText,
                    onChanged: (value) {
                      setState(() => _useGenericText = value);
                    },
                    activeColor: const Color(0xFF7B61FF),
                    contentPadding: EdgeInsets.zero,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Generic notifications help protect your privacy by hiding sensitive health information from your lock screen.',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Example notification preview
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
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
                                Text(
                                  'Sparkle Lite',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  _useGenericText
                                      ? 'You have a health reminder'
                                      : 'Time to log your symptoms for today',
                                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
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
}