import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  static const String _languageKey = 'selected_language';
  final GetStorage _storage = GetStorage();

  final List<Map<String, dynamic>> languages = [
    {
      'code': 'en_US',
      'name': 'English',
      'nativeName': 'English',
      'flag': '🇺🇸',
    },
    {
      'code': 'ja_JP',
      'name': 'Japanese',
      'nativeName': '日本語',
      'flag': '🇯🇵',
    },
    {
      'code': 'ko_KR',
      'name': 'Korean',
      'nativeName': '한국어',
      'flag': '🇰🇷',
    },
  ];

  final RxString _currentLanguageCode = ''.obs;
  String get currentLanguageCode => _currentLanguageCode.value;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    final savedLanguage = _storage.read<String>(_languageKey);

    if (savedLanguage != null && _isValidLanguage(savedLanguage)) {
      _currentLanguageCode.value = savedLanguage;
      // FIX: Always update locale when loading saved language
      final locale = _getLocaleFromCode(savedLanguage);
      if (locale != null) {
        Get.updateLocale(locale);
      }
    } else {
      // Default to English
      _currentLanguageCode.value = 'en_US';
      Get.updateLocale(const Locale('en', 'US'));
    }
  }

  bool _isValidLanguage(String languageCode) {
    return languages.any((lang) => lang['code'] == languageCode);
  }

  void setLanguage(String languageCode) {
    if (_isValidLanguage(languageCode)) {
      _currentLanguageCode.value = languageCode;
      _saveLanguagePreference(languageCode);

      // Update the application locale
      final locale = _getLocaleFromCode(languageCode);
      if (locale != null) {
        Get.updateLocale(locale);
        update();
        print('✅ Language changed to: $languageCode'); // Debug print
      }
    }
  }

  void _saveLanguagePreference(String languageCode) {
    _storage.write(_languageKey, languageCode);
  }

  Locale? _getLocaleFromCode(String languageCode) {
    final parts = languageCode.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return null;
  }

  Locale getCurrentLocale() {
    return _getLocaleFromCode(currentLanguageCode) ?? const Locale('en', 'US');
  }

  String getLanguageName(String languageCode) {
    final language = languages.firstWhere(
          (lang) => lang['code'] == languageCode,
      orElse: () => languages.first,
    );
    return language['name'];
  }

  String getNativeLanguageName(String languageCode) {
    final language = languages.firstWhere(
          (lang) => lang['code'] == languageCode,
      orElse: () => languages.first,
    );
    return language['nativeName'];
  }

  String getLanguageFlag(String languageCode) {
    final language = languages.firstWhere(
          (lang) => lang['code'] == languageCode,
      orElse: () => languages.first,
    );
    return language['flag'];
  }

  bool isSelected(String languageCode) {
    return currentLanguageCode == languageCode;
  }

  void clearLanguagePreference() {
    _storage.remove(_languageKey);
    setLanguage('en_US');
  }
}