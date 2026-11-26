import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(
    this._prefs, {
    required this._dark,
    this._city,
    this._avatarPath,
  });

  final SharedPreferencesAsync _prefs;

  bool _dark;
  String? _city;
  String? _avatarPath;

  bool get dark => _dark;
  String? get city => _city;
  String? get avatarPath => _avatarPath;

  Future<void> setDark(bool value) async {
    _dark = value;
    notifyListeners();
    await _prefs.setBool('darkMode', value);
  }

  Future<void> setCity(String? value) async {
    _city = value;
    notifyListeners();
    if (value == null || value.isEmpty) {
      await _prefs.remove('cityFilter');
    } else {
      await _prefs.setString('cityFilter', value);
    }
  }

  Future<void> setAvatarPath(String? path) async {
    _avatarPath = path;
    notifyListeners();
    if (path == null) {
      await _prefs.remove('avatarPath');
    } else {
      await _prefs.setString('avatarPath', path);
    }
  }
}
