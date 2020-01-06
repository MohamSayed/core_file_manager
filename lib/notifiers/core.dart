// dart
import 'dart:async';
import 'dart:io';

// framework
import 'package:flutter/foundation.dart';

// packages
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';
import 'package:path_provider/path_provider.dart';

// app files
import 'package:basic_file_manager/notifiers/preferences.dart';
import 'package:simple_permissions/simple_permissions.dart';

class CoreNotifier extends ChangeNotifier {
  CoreNotifier() {
    initialize();
  }

  // Current user path
  Directory _currentPath;

  Directory get currentPath => _currentPath;

  set currentPath(Directory currentPath) {
    _currentPath = currentPath;
  }

  Future<void> navigateToDirectory(String newPath) async {
    print("core->navigateToDirectory: $newPath");
    currentPath = Directory(newPath);
    notifyListeners();
  }

  Future<void> navigateBackdward() async {
    if (_currentPath.absolute.path == p.separator) {
      
    } else {
      _currentPath = currentPath.parent;
    }
    notifyListeners();
  }

  List<dynamic> folders = [];
  List<dynamic> subFolders = [];

  Future<void> initialize() async {
    //Requesting permissions if not granted
    if (!await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage)) {
      await SimplePermissions.requestPermission(
          Permission.WriteExternalStorage);
      notifyListeners();
    }

    print("Initializing");
    // requesting permissions
    currentPath = await getExternalStorageDirectory();
  }

  Future<void> delete(String path) async {
    try {
      if (FileSystemEntity.isFileSync(path)) {
        print("Deleting file @ $path");
        await File(path).delete();
        notifyListeners();
      } else if (FileSystemEntity.isDirectorySync(path)) {
        print("Deleting folder @ $path");
        await Directory(path)
            .delete(recursive: true)
            .then((_) => notifyListeners());
      } else if (FileSystemEntity.isFileSync(path)) {
        print("CoreNotifier->delete: $path");
        await Link(path).delete(recursive: true).then((_) => notifyListeners());
      }
      notifyListeners();
    } catch (e) {
      CoreNotifierError(e.toString());
    }
  }

  BehaviorSubject<bool> _pasteMode = BehaviorSubject.seeded(false);

  Stream<bool> get pasteMode => _pasteMode.stream.asBroadcastStream();

  List<dynamic> copyList = [];

  void copyByPath(List<String> objects) {
    copyList.addAll(objects);
    _pasteMode.add(true);
  }

  void copyFile(String path) {
    print("core->copyFile(copy): $path");
    copyList.add(path);
    _pasteMode.add(true);
  }

  void pasteByPath(String path) async {
    copyList.forEach((f) {
      if (FileSystemEntity.isDirectorySync(f)) {
      } else if (FileSystemEntity.isFileSync(f)) {
        try {
          File(f).copySync(p.join(path, p.split(f).last));
        } on FileSystemException catch (e) {
          print(e);
          // throw CoreNotifierError(e.toString());
        }
      }
    });
    copyList.clear();
    notifyListeners();
    _pasteMode.add(false);
  }

  void reload() {
    notifyListeners();
  }
}

class CoreNotifierError extends Error {
  final String message;
  CoreNotifierError(this.message);

  @override
  String toString() {
    return message;
  }
}
