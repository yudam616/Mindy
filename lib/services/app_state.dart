import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppMode { child, parent }

enum TomatoStage { seed, sprout, young, grown }

class AppState extends ChangeNotifier {
  AppMode _currentMode = AppMode.child;
  TomatoStage _currentStage = TomatoStage.seed;
  bool _isParentModeUnlocked = false;
  String _parentPassword = '1234'; // 기본 비밀번호

  AppMode get currentMode => _currentMode;
  TomatoStage get currentStage => _currentStage;
  bool get isParentModeUnlocked => _isParentModeUnlocked;

  void setMode(AppMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  void setTomatoStage(TomatoStage stage) {
    _currentStage = stage;
    notifyListeners();
  }

  Future<bool> unlockParentMode(String password) async {
    if (password == _parentPassword) {
      _isParentModeUnlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void lockParentMode() {
    _isParentModeUnlocked = false;
    notifyListeners();
  }

  Future<void> setParentPassword(String newPassword) async {
    _parentPassword = newPassword;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parent_password', newPassword);
  }

  Future<void> loadParentPassword() async {
    final prefs = await SharedPreferences.getInstance();
    _parentPassword = prefs.getString('parent_password') ?? '1234';
  }
}
