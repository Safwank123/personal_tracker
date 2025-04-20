import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_tracker/app/theme.dart';
import 'package:personal_tracker/auth/auth_service.dart';
import 'package:personal_tracker/auth/login_screen.dart';
import 'package:personal_tracker/auth/sigin_up_screen.dart';
import 'package:personal_tracker/dashbord/dashbord_screen.dart';
import 'package:personal_tracker/services/subabase_services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ztqqupflharvxrllpbbg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp0cXF1cGZsaGFydnhybGxwYmJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwNzg5MzIsImV4cCI6MjA2MDY1NDkzMn0.Sh-hVI8MlShdLp6rCCKLYzxBBE38dpeuaoXLu4VNwX0',
  );

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => SupabaseService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          final router = GoRouter(
            refreshListenable: authService,
            redirect: (context, state) {
              final isLoggedIn = authService.currentUser != null;
              final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

              if (!isLoggedIn && !loggingIn) return '/login';
              if (isLoggedIn && loggingIn) return '/dashboard';

              return null;
            },
            routes: [
              GoRoute(path: '/', redirect: (_, __) => '/dashboard'),
              GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
              GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
              GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
            ],
          );

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            checkerboardOffscreenLayers: false,
            title: 'Personal Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: authService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
