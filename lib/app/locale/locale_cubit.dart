import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/preference_keys.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(const LocaleState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(PreferenceKeys.appLanguageCode);
    if (code == null) return;
    final language = LocaleState.supportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => LocaleState.defaultLanguage,
    );
    emit(LocaleState(language: language));
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.appLanguageCode, language.code);
    emit(LocaleState(language: language));
  }
}
