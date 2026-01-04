// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../widgets/curved_header.dart';
import '../theme/app_theme.dart';
import '../models/admin_session.dart';
import 'package:window_manager/window_manager.dart';
import 'package:floodwatch_desktop/controllers/window_sizes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.themeMode.value == ThemeMode.dark;

    // fullname → username → "Admin"
    final displayName =
        AdminSession.fullname?.isNotEmpty == true
            ? AdminSession.fullname!
            : (AdminSession.username?.isNotEmpty == true
                ? AdminSession.username!
                : "Admin");

    return Column(
      children: [
        const CurvedHeader(
          title: 'PROFILE',
          subtitle: 'Your information and settings',
          icon: Icons.person,
          compact: true,
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // USER CARD
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Administrator",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // SETTINGS TITLE
                const Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                // const _SettingItem(title: "Account Details", icon: Icons.person_outline),
                const _SettingItem(title: "Change Password", icon: Icons.lock_outline),
                // const _SettingItem(title: "Appearance", icon: Icons.palette_outlined),
                // const _SettingItem(title: "Notifications", icon: Icons.notifications_outlined),
                const _SettingItem(title: "Help & Support", icon: Icons.help_outline),

                // DARK MODE TOGGLE
                SwitchListTile(
                  title: const Text("Dark Mode"),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: isDark,
                  onChanged: (value) {
                    ThemeController.toggleTheme(value);
                  },
                ),

                const SizedBox(height: 30),

                // LOGOUT
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      AdminSession.clear();

                      if (!context.mounted) return;

                      // Go back to the login route first
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );

                      // After the new frame (login screen) is drawn, shrink the window
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        await windowManager.setResizable(false);
                        await windowManager.setMinimumSize(loginWindowSize);
                        await windowManager.setSize(loginWindowSize);
                        await windowManager.center();
                      });
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SettingItem({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
