import 'package:flutter/cupertino.dart';

class LanguageNotifier extends ValueNotifier<Locale> {
  LanguageNotifier(Locale value) : super(value);

  void changeLanguage(Locale locale) {
    value = locale;
  }
}

final languageNotifier = LanguageNotifier(const Locale('en'));