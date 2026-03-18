import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppLanguage extends Equatable {
  const AppLanguage({
    required this.code,
    required this.countryCode,
    required this.displayName,
    required this.nativeName,
  });

  /// BCP-47 language code, e.g. 'en', 'id'.
  final String code;

  /// ISO 3166-1 alpha-2 country code used for the flag, e.g. 'US', 'ID'.
  final String countryCode;

  /// English display name.
  final String displayName;

  /// Name in the language itself.
  final String nativeName;

  Locale get locale => Locale(code);

  @override
  List<Object?> get props => [code];
}

class LocaleState extends Equatable {
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
      code: 'en',
      countryCode: 'US',
      displayName: 'English',
      nativeName: 'English',
    ),
    AppLanguage(
      code: 'id',
      countryCode: 'ID',
      displayName: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
    ),
    AppLanguage(
      code: 'ms',
      countryCode: 'MY',
      displayName: 'Malay',
      nativeName: 'Bahasa Melayu',
    ),
    AppLanguage(
      code: 'zh',
      countryCode: 'CN',
      displayName: 'Chinese (Simplified)',
      nativeName: '简体中文',
    ),
    AppLanguage(
      code: 'ja',
      countryCode: 'JP',
      displayName: 'Japanese',
      nativeName: '日本語',
    ),
    AppLanguage(
      code: 'ko',
      countryCode: 'KR',
      displayName: 'Korean',
      nativeName: '한국어',
    ),
  ];

  static const AppLanguage defaultLanguage = AppLanguage(
    code: 'en',
    countryCode: 'US',
    displayName: 'English',
    nativeName: 'English',
  );

  const LocaleState({this.language = defaultLanguage});

  final AppLanguage language;

  Locale get locale => language.locale;

  @override
  List<Object?> get props => [language];
}
