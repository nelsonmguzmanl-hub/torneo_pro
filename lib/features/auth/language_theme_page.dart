import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/app_preferences.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class LanguageThemePage extends StatelessWidget {
  const LanguageThemePage({super.key});

  static const primary = Color(0xFF13EC37);
  static const bgLight = Color(0xFFF6F8F6);
  static const bgDark = Color(0xFF102213);
  static const surfaceLight = Colors.white;
  static const surfaceDark = Color(0xFF1C3020);
  static const textLight = Color(0xFF0D1B10);
  static const textDark = Color(0xFFE0E6E1);
  static const textSecondaryLight = Color(0xFF4A5D50);
  static const textSecondaryDark = Color(0xFFA0B0A5);

  Future<void> _completeOnboarding(BuildContext context) async {
    await AppPreferences.completeOnboarding();

    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context)!;

    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final localeCode = languageProvider.locale.languageCode;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: isDark ? textDark : textLight),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    l10n.initialSetupTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? textDark : textLight,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // ---------------- CONTENT ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Headline
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${l10n.personalizeYour}\n',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: isDark ? textDark : textLight,
                            ),
                          ),
                          TextSpan(
                            text: l10n.experience,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.initialSetupDescription,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? textSecondaryDark
                            : textSecondaryLight,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ---------------- LANGUAGE ----------------
                    _sectionTitle(
                      icon: Icons.translate,
                      title: l10n.languageSectionTitle,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _languageCard(
                          context,
                          label: l10n.spanish,
                          selected: localeCode == 'es',
                          flagUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDMqKu-SgSOxMh_jTQmW13YsYBdanpxQaTy1F5pz_G-jAZamUWfGeBAVoHjyPiEMG28Gs8CSE69gdosZJQWpkTIdf7ErtEVXKXXFoEfKfmTWRyMOha2NrDKbluF5N-NVkXhsrTT8H6X8QnTs1T1oi8VhfOyT_LjvyfUp-mOe1KgXeRN3fpUfuIpqprs5IKGqHnM_r9q7qG1uhPCBQRx31kQ-Yw2D1hAqzkPkXud56yU-ZHe_-gK3UsExs9LufYyhuRLwFL9LZTWhIQ',
                          onTap: () =>
                              languageProvider.changeLanguage('Español'),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 16),
                        _languageCard(
                          context,
                          label: l10n.english,
                          selected: localeCode == 'en',
                          flagUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuA9j9PVblkjDvjQtIUnBUkqiobBqW6eGYEQvX3-Lm1B54L0x0nppyqpUBJyz518m45rarpjh_B3DAIef8guzUjLhu0ygL_QMm2utBNxB3uEy2SfA0h6YH6w_Ug1mZwIQNT0UoJk0C6N3nDEEVzHT-5GftutI3R9jpoIgukpc09VDNdGfW4Uwh5z8VA6D3e6l4ZgAJcYgidBMbT0cabhpJeD2GJiX9zyyKjN2oeZ1Q9esI6jVOoMUZCKi-XT6V4sXksVe1vyXopBBFc',
                          onTap: () =>
                              languageProvider.changeLanguage('English'),
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ---------------- THEME ----------------
                    _sectionTitle(
                      icon: Icons.contrast,
                      title: l10n.themeSectionTitle,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _themeCard(
                          label: l10n.lightTheme,
                          selected: !isDark,
                          previewColor: bgLight,
                          icon: Icons.light_mode,
                          onTap: () => themeProvider.setDarkMode(false),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 16),
                        _themeCard(
                          label: l10n.darkTheme,
                          selected: isDark,
                          previewColor: bgDark,
                          icon: Icons.dark_mode,
                          onTap: () => themeProvider.setDarkMode(true),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ---------------- FOOTER BUTTON ----------------
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (isDark ? bgDark : bgLight).withOpacity(0),
                    isDark ? bgDark : bgLight,
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: () => _completeOnboarding(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 6,
                  shadowColor: primary.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.continueLabel,
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- COMPONENTS ----------------

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, color: primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? textDark : textLight,
          ),
        ),
      ],
    );
  }

  Widget _languageCard(
    BuildContext context, {
    required String label,
    required bool selected,
    required String flagUrl,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: _cardContainer(
          selected: selected,
          isDark: isDark,
          child: Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(flagUrl),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected
                      ? (isDark ? textDark : textLight)
                      : (isDark
                          ? textSecondaryDark
                          : textSecondaryLight),
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                selected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: selected ? primary : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeCard({
    required String label,
    required bool selected,
    required Color previewColor,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: _cardContainer(
          selected: selected,
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 90,
                decoration: BoxDecoration(
                  color: previewColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon,
                          color: selected ? primary : Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.w500,
                          color: selected
                              ? (isDark ? textDark : textLight)
                              : (isDark
                                  ? textSecondaryDark
                                  : textSecondaryLight),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selected ? primary : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardContainer({
    required Widget child,
    required bool selected,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? surfaceDark : surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: selected
            ? Border.all(color: primary, width: 2)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: child,
    );
  }
}
