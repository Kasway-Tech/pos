import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(const LocaleState()) {
    _load();
  }

  static const _key = 'app_language_code';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code == null) return;
    final language = LocaleState.supportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => LocaleState.defaultLanguage,
    );
    emit(LocaleState(language: language));
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language.code);
    emit(LocaleState(language: language));
  }
}
