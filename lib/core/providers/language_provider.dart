import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('es');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('languageCode') ?? 'es';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> changeLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();

    if (language == 'English') {
      _locale = const Locale('en');
      await prefs.setString('languageCode', 'en');
    } else {
      _locale = const Locale('es');
      await prefs.setString('languageCode', 'es');
    }

    notifyListeners();
  }
}
