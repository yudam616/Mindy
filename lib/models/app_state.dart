import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool _isParentMode = false;
  bool _isLocked = false;

  bool get isParentMode => _isParentMode;
  bool get isLocked => _isLocked;

  void setParentMode(bool value) {
    _isParentMode = value;
    notifyListeners();
  }

  void lockParentMode() {
    _isLocked = true;
    notifyListeners();
  }

  void unlockParentMode() {
    _isLocked = false;
    notifyListeners();
  }
}
