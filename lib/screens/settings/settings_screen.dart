import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/cart_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _notificationsEnabled = true;
  double _taxRate = 0.1; // 10%

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSettings();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(settings);
  }

  Future<void> _loadSettings() async {
    final cartProvider = context.read<CartProvider>();
    setState(() {
      _taxRate = cartProvider.taxRate;
    });
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'smart_cashier_channel',
      'Smart Cashier',
      channelDescription: 'Notifications for Smart Cashier app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notificationsPlugin.show(0, title, body, details);
  }

  Future<void> _testNotification() async {
    await _showNotification(
      'Test Notification',
      'This is a test notification from Smart Cashier!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test notification sent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),

      body: Consumer3<AuthProvider, ThemeProvider, CartProvider>(
        builder: (context, authProvider, themeProvider, cartProvider, child) {
          return ListView(
            children: [
              // User Profile Section
              _buildSectionHeader('Profile', Icons.person),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    authProvider.currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(authProvider.currentUser?.name ?? 'User'),
                subtitle: Text(authProvider.currentUser?.email ?? 'email@example.com'),
                trailing: Chip(
                  label: Text(
                    authProvider.isAdmin ? 'Admin' : 'Cashier',
                    style: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                ),
              ),

              const Divider(),

              // Appearance Section
              _buildSectionHeader('Appearance', Icons.palette),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Theme'),
                subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
                trailing: DropdownButton<ThemeMode>(
                  value: themeProvider.themeMode,
                  onChanged: (ThemeMode? newMode) {
                    if (newMode != null) {
                      themeProvider.setThemeMode(newMode);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Business Settings Section
              _buildSectionHeader('Business Settings', Icons.business),
              ListTile(
                leading: const Icon(Icons.percent),
                title: const Text('Tax Rate'),
                subtitle: Text('${(_taxRate * 100).toInt()}%'),
                trailing: SizedBox(
                  width: 120,
                  child: Slider(
                    value: _taxRate,
                    min: 0.0,
                    max: 0.5,
                    divisions: 50,
                    label: '${(_taxRate * 100).toInt()}%',
                    onChanged: (value) {
                      setState(() => _taxRate = value);
                      cartProvider.taxRate = value;
                    },
                  ),
                ),
              ),

              const Divider(),

              // Notifications Section
              _buildSectionHeader('Notifications', Icons.notifications),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active),
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive alerts for low stock and updates'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),

              ListTile(
                leading: const Icon(Icons.notification_important),
                title: const Text('Test Notification'),
                subtitle: const Text('Send a test notification'),
                trailing: const Icon(Icons.send),
                onTap: _testNotification,
              ),

              const Divider(),

              // Data Management Section
              _buildSectionHeader('Data Management', Icons.storage),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Export Data'),
                subtitle: const Text('Export all data to CSV'),
                trailing: const Icon(Icons.download),
                onTap: () {
                  // TODO: Implement data export
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export feature coming soon')),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Import Data'),
                subtitle: const Text('Import data from CSV'),
                trailing: const Icon(Icons.upload),
                onTap: () {
                  // TODO: Implement data import
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Import feature coming soon')),
                  );
                },
              ),

              const Divider(),

              // About Section
              _buildSectionHeader('About', Icons.info),
              const ListTile(
                leading: Icon(Icons.app_settings_alt),
                title: Text('Version'),
                subtitle: Text('Smart Cashier v1.0.0'),
              ),

              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Show privacy policy
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy policy coming soon')),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Show terms of service
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Terms of service coming soon')),
                  );
                },
              ),

              const Divider(),

              // Account Section
              _buildSectionHeader('Account', Icons.account_circle),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sign Out'),
                subtitle: const Text('Sign out of your account'),
                onTap: () => _confirmSignOut(context, authProvider),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follow system setting';
      case ThemeMode.light:
        return 'Light theme';
      case ThemeMode.dark:
        return 'Dark theme';
    }
  }

  Future<void> _confirmSignOut(BuildContext context, AuthProvider authProvider) async {
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}