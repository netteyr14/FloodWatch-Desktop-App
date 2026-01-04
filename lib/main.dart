import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'package:floodwatch_desktop/controllers/window_sizes.dart'; // if you moved the constants

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Set default theme to dark
  ThemeController.themeMode.value = ThemeMode.dark;

  WindowOptions windowOptions = const WindowOptions(
    size: loginWindowSize,
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.setResizable(false);        // login locked
    await windowManager.setSize(loginWindowSize);   // make sure size = card
    await windowManager.center();
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const FloodwatchAdminApp());
}

class FloodwatchAdminApp extends StatelessWidget {
  const FloodwatchAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeController.themeMode,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          // IMPORTANT: we’ll navigate by route name:
          initialRoute: '/login',
          routes: {
            '/login': (_) => const LoginScreen(),
            // you *can* also add '/dashboard' here, but you’re already
            // using DashboardShell directly in code, so not required.
          },
        );
      },
    );
  }
}
