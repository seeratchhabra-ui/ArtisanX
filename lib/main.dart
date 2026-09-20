import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/auth/welcome_auth_screen.dart';
import 'screens/artisan/artisan_dashboard_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/common/kalasathi_assistant_screen.dart';
import 'widgets/responsive_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppState())],
      child: const KalaSetuApp(),
    ),
  );
}

class KalaSetuApp extends StatelessWidget {
  const KalaSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KalaSetu - ArtisanX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      builder: (context, child) {
        return ResponsiveShell(child: child ?? const SizedBox());
      },
      routes: {
        '/': (context) => const WelcomeAuthScreen(),
        '/artisan': (context) => const ArtisanDashboardScreen(),
        '/customer': (context) => const CustomerHomeScreen(),
        '/kalasathi': (context) => const KalaSathiAssistantScreen(),
      },
    );
  }
}
