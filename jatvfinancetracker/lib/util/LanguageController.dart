import 'package:flutter/foundation.dart';

class LanguageController extends ChangeNotifier {
  LanguageController._();
  static final LanguageController instance = LanguageController._();

  String _language = 'English';
  String get language => _language;

  void setLanguage(String value) {
    if (_language == value) return;
    _language = value;
    notifyListeners();
  }
}
