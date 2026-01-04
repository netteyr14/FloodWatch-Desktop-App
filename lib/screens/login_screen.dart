// lib/screens/login_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:window_manager/window_manager.dart';
import 'dashboard_shell.dart';
import '../models/admin_session.dart';
import 'package:floodwatch_desktop/controllers/window_sizes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _error;
  bool _isLoading = false;

  static const String _baseUrl = 'http://192.168.1.2';

  @override
  void initState() {
    super.initState();

    // When we arrive on Login (either at app start or after logout),
    // ensure the window is in "login mode" size.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await windowManager.setResizable(false);
      await windowManager.setMinimumSize(loginWindowSize);
      await windowManager.setSize(loginWindowSize);
      await windowManager.center();
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _error = null;
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/node/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final admin = data['admin'] as Map<String, dynamic>;
        AdminSession.fullname = admin['fullname']?.toString();
        AdminSession.username = admin['uname']?.toString();

        // 🔹 Enlarge + unlock the window for the dashboard
        await windowManager.setResizable(true);
        await windowManager.setMinimumSize(dashboardWindowSize);
        await windowManager.setSize(dashboardWindowSize);
        await windowManager.center();

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardShell()),
        );
      } else {
        // 🔹 Wrong credentials or backend reported failure
        setState(() {
          _error = data['message']?.toString() ??
              'Incorrect username or password.';
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Cannot connect to server. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color accent = Color(0xFF7EA531);

    // 🌙 / ☀️ theme-aware colors (sizes unchanged)
    final Color cardColor =
        isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFFFFDEB);

    final Color titleBarColor = isDark
        ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.9)
        : const Color(0xFFF2EFD6);

    final Color dividerColor =
        isDark ? Colors.black26 : const Color(0xFFE0DCC7);

    final Color titleTextColor =
        isDark ? Theme.of(context).colorScheme.onSurface : Colors.black87;

    final Color closeIconColor =
        isDark ? Theme.of(context).colorScheme.onSurface : Colors.black87;

    final Color hintTextColor =
        isDark ? Colors.grey.shade400 : Colors.grey;

    // Compact error style so "Required" doesn’t push layout too much
    const TextStyle fieldErrorStyle = TextStyle(
      color: Colors.red,
      fontSize: 11,
      height: 0.9,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 520, // ✅ unchanged
          height: 420, // ✅ unchanged
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.22),
            //     blurRadius: 32,
            //     spreadRadius: 2,
            //     offset: const Offset(5, 14),
            //   ),
            // ],
          ),
          child: Column(
            children: [
              // ------------------ CUSTOM TITLE BAR ------------------
              GestureDetector(
                onPanStart: (_) => windowManager.startDragging(),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: titleBarColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.water_drop,
                          size: 18, color: accent),
                      const SizedBox(width: 8),
                      Text(
                        "FloodWatch Admin",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: titleTextColor,
                        ),
                      ),
                      const Spacer(),

                      //MINIMIZE BUTTON
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => windowManager.minimize(),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.remove,
                            size: 18,
                            color: closeIconColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // CLOSE BUTTON
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => windowManager.close(),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: closeIconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Divider(height: 1, color: dividerColor),

              // ------------------ MAIN LOGIN UI ------------------
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Icon(Icons.analytics_outlined,
                              size: 48, color: accent),
                          const SizedBox(height: 14),
                          Text(
                            'Admin Login',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: titleTextColor,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Username
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: "Username",
                              border: OutlineInputBorder(),
                              errorStyle: fieldErrorStyle,
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                          const SizedBox(height: 12),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(),
                              errorStyle: fieldErrorStyle,
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Required'
                                    : null,
                          ),

                          const SizedBox(height: 16),

                          // Top-level error (incorrect password / server)
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                backgroundColor: accent,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                          fontWeight:
                                              FontWeight.bold),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Login with your admin account',
                            style: TextStyle(
                              fontSize: 12,
                              color: hintTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
