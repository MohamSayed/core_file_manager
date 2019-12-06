import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';

class PreferencesBlocError extends Error {
  final String message;

  PreferencesBlocError(this.message);
}

// State design pattern
class PreferencesState {
  final bool hidden;
  final sorting;
  final BehaviorSubject<bool> showFloatingButton;

  const PreferencesState(
      {@required this.hidden,
      @required this.showFloatingButton,
      @required this.sorting});
}

class PreferencesNotifier with ChangeNotifier {
  // Initial preferences' values
  PreferencesState _currentPrefs = PreferencesState(
      showFloatingButton: BehaviorSubject.seeded(true),
      sorting: Sorting.Type,
      hidden: false);

  bool get hidden => _currentPrefs.hidden;
  set hidden(bool newValue) {
    if (newValue == _currentPrefs.hidden) return;
    _currentPrefs = PreferencesState(
        showFloatingButton: _currentPrefs.showFloatingButton,
        sorting: _currentPrefs.sorting,
        hidden: newValue);
    notifyListeners();
    _savePreferences();
  }

  Stream<bool> get showFloatingButton {
    return _currentPrefs.showFloatingButton.stream.asBroadcastStream();
  }

  // Note(Naga): the name can cannot be as the getter,
  // if it set as the getter you will get error.
  // If someone has a better way of doing this, please do not hesitate
  setFloatingButtonEnabled(bool newValue) {
    _currentPrefs.showFloatingButton.add(newValue);
    _savePreferences();
  }

  Sorting get sorting => _currentPrefs.sorting;

  set sorting(Sorting newValue) {
    if (newValue == _currentPrefs.sorting) return;
    _currentPrefs = PreferencesState(
        sorting: newValue,
        showFloatingButton: _currentPrefs.showFloatingButton,
        hidden: _currentPrefs.hidden);
    notifyListeners();
    _savePreferences();
  }

  PreferencesNotifier() {
    _loadSharedPreferences();
  }

  Future<void> _loadSharedPreferences() async {
    print("Saving preferences");
    var sharedPrefs = await SharedPreferences.getInstance();
    // '0' is the initial value

    int sortIndex = sharedPrefs.getInt('sort') ?? 0;
    bool _showFloatingButton =
        sharedPrefs.getBool('showFloatingButton') ?? true;
    _currentPrefs = PreferencesState(
        showFloatingButton: BehaviorSubject.seeded(_showFloatingButton),
        sorting: Sorting.values[sortIndex],
        hidden: _currentPrefs.hidden);

    notifyListeners();
  }

  Future<void> _savePreferences() async {
    print("Saving preferences");
    var sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setInt('sort', _currentPrefs.sorting.index);
    // note(Naga): if someone has a better way of doing this, please do not hesitate
    // listening on showFloatingButton strean then assign a value
    _currentPrefs.showFloatingButton.stream.listen((data) async {
      await sharedPrefs.setBool('showFloatingButton', data);
    });
  }
}

enum Sorting { Type, Size, Date, Alpha, TypeDate, TypeSize }
