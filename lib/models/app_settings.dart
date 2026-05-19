import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const _soundKey      = 'sound_enabled';
  static const _musicKey      = 'music_enabled';
  static const _vibrationKey  = 'vibration_enabled';
  static const _timerKey      = 'show_timer';
  static const _langKey       = 'language';
  static const _themeKey      = 'active_theme';

  bool   _sound      = true;
  bool   _music      = true;
  bool   _vibration  = true;
  bool   _showTimer  = true;
  String _language   = 'en';
  String _activeTheme = 'desert';

  bool   get sound       => _sound;
  bool   get music       => _music;
  bool   get vibration   => _vibration;
  bool   get showTimer   => _showTimer;
  String get language    => _language;
  String get activeTheme => _activeTheme;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _sound       = prefs.getBool(_soundKey)     ?? true;
    _music       = prefs.getBool(_musicKey)     ?? true;
    _vibration   = prefs.getBool(_vibrationKey) ?? true;
    _showTimer   = prefs.getBool(_timerKey)     ?? true;
    _language    = prefs.getString(_langKey)    ?? 'en';
    _activeTheme = prefs.getString(_themeKey)   ?? 'desert';
    notifyListeners();
  }

  Future<void> setSound(bool v) async {
    _sound = v;
    await _save(_soundKey, v);
    notifyListeners();
  }

  Future<void> setMusic(bool v) async {
    _music = v;
    await _save(_musicKey, v);
    notifyListeners();
  }

  Future<void> setVibration(bool v) async {
    _vibration = v;
    await _save(_vibrationKey, v);
    notifyListeners();
  }

  Future<void> setShowTimer(bool v) async {
    _showTimer = v;
    await _save(_timerKey, v);
    notifyListeners();
  }

  Future<void> setLanguage(String v) async {
    _language = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, v);
    notifyListeners();
  }

  Future<void> setActiveTheme(String id) async {
    _activeTheme = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, id);
    notifyListeners();
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
