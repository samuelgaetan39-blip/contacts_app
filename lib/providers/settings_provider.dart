import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contacts_app/models/contact.dart';

enum SortCriteria { firstName, lastName, createdAt, updatedAt }
enum SortOrder    { ascending, descending }

extension SortCriteriaLabel on SortCriteria {
  String get label {
    switch (this) {
      case SortCriteria.firstName:  return 'Prénom';
      case SortCriteria.lastName:   return 'Nom de famille';
      case SortCriteria.createdAt:  return 'Date de création';
      case SortCriteria.updatedAt:  return 'Date de modification';
    }
  }
}

class SettingsProvider extends ChangeNotifier {
  bool             _darkMode       = false;
  SortCriteria     _sortCriteria   = SortCriteria.firstName;
  SortOrder        _sortOrder      = SortOrder.ascending;
  StorageLocation  _defaultStorage = StorageLocation.phone;

  bool             get darkMode        => _darkMode;
  SortCriteria     get sortCriteria    => _sortCriteria;
  SortOrder        get sortOrder       => _sortOrder;
  StorageLocation  get defaultStorage  => _defaultStorage;
  ThemeMode        get themeMode       => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode       = prefs.getBool('darkMode') ?? false;
    _sortCriteria   = SortCriteria.values[prefs.getInt('sortCriteria') ?? 0];
    _sortOrder      = SortOrder.values[prefs.getInt('sortOrder') ?? 0];
    // Clamp index to valid range (StorageLocation only has 2 values now)
    final storageIdx = prefs.getInt('defaultStorage') ?? 0;
    _defaultStorage = StorageLocation.values[storageIdx.clamp(0, StorageLocation.values.length - 1)];
    notifyListeners();
  }

  Future<void> setDarkMode(bool v) async {
    _darkMode = v;
    await _save('darkMode', v);
    notifyListeners();
  }

  Future<void> setSortCriteria(SortCriteria v) async {
    _sortCriteria = v;
    await _saveInt('sortCriteria', v.index);
    notifyListeners();
  }

  Future<void> setSortOrder(SortOrder v) async {
    _sortOrder = v;
    await _saveInt('sortOrder', v.index);
    notifyListeners();
  }

  Future<void> setDefaultStorage(StorageLocation v) async {
    _defaultStorage = v;
    await _saveInt('defaultStorage', v.index);
    notifyListeners();
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }
}