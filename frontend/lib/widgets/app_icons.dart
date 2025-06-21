import 'package:flutter/widgets.dart';

// Этот класс будет нашим центральным хранилищем кастомных иконок
// Используем пак Feather Icons. Коды можно найти на их сайте или в .json файле пака.
class AppIcons {
  AppIcons._(); // Приватный конструктор

  static const _kFontFam = 'AppIcons'; // Имя семьи, которое мы задали в pubspec.yaml
  static const String? _kFontPkg = null;

  // Коды иконок из файла feather.ttf
  static const IconData phone = IconData(0xe900, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData bar_chart = IconData(0xe901, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData users = IconData(0xe902, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData archive = IconData(0xe903, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData info = IconData(0xe904, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData user = IconData(0xe905, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData arrow_right = IconData(0xe906, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData settings = IconData(0xe907, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData edit = IconData(0xe908, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dollar_sign = IconData(0xe909, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData link = IconData(0xe90a, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}