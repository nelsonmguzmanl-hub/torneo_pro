import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'core/providers/user_provider.dart';
import 'core/auth/auth_gate.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/theme_provider.dart';
import '../../core/services/app_preferences.dart';

import 'features/auth/welcome_page.dart';
import 'features/auth/language_theme_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/auth/reset_password_page.dart';
import 'features/home/admin_home_page.dart';
import 'features/home/user_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final onboardingCompleted =
    await AppPreferences.hasCompletedOnboarding();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(onboardingCompleted: onboardingCompleted),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;
  const MyApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Torneos de Fútbol',

      // 🌍 Idioma
      locale: languageProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 🎨 Tema
      theme: ThemeData(
        primaryColor: const Color(0xFF13EC37),
        scaffoldBackgroundColor: const Color(0xFFF6F8F6),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,

      // 🚀 RUTA INICIAL CONTROLADA
      initialRoute: onboardingCompleted ? '/' : '/welcome',

      routes: {
        '/welcome': (_) => const WelcomePage(),
        '/language_theme': (_) => const LanguageThemePage(),
        '/login': (_) => const LoginPage(),
        '/reset-password': (_) => const ResetPasswordPage(),
        '/register': (_) => const RegisterPage(),
        '/': (_) => const AuthGate(),
        '/admin_home': (_) => const AdminHomePage(),
        '/user_home': (_) => const UserHomePage(),
      },
    );
  }
}