import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../../core/providers/language_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final backgroundColor = isDarkMode ? Color(0xFF102213) : Color(0xFFF6F8F6);
    final cardColor = isDarkMode ? Color(0xFF1A2E1D) : Colors.white;
    final textMainColor = isDarkMode ? Colors.white : Color(0xFF0D1B10);
    final textSecondaryColor = isDarkMode ? Colors.grey[400]! : Color(0xFF4C9A59);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Color(0xFFE7F3E9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    size: 64,
                    color: Color(0xFF13EC37),
                  ),
                ),
                const SizedBox(height: 24),
                // Title & subtitle
                Text(
                  l10n.appName,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textMainColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.welcomeSubtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Start Button
                ElevatedButton.icon(
                  onPressed: () {
                    // Navegar a la siguiente pantalla, por ejemplo login
                    Navigator.pushNamed(context, '/language_theme');
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    l10n.startLabel,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF13EC37),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
