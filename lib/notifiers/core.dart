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
import 'package:basic_file_manager/helpers/array_utils.dart' as utils;
import 'package:basic_file_manager/models/file.dart';
import 'package:basic_file_manager/models/folder.dart';
import 'package:simple_permissions/simple_permissions.dart';

class CoreNotifier extends ChangeNotifier {
  CoreNotifier() {
    initialize();
  }

  // Current user path
  Directory currentPath;

  Future<String> getRootPath() async {
    return (await getExternalStorageDirectory()).absolute.path;
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

  Future<List<dynamic>> getFoldersAndFiles(String path,
      {changeCurrentPath: true,
      Sorting sortedBy: Sorting.Type,
      reverse: false,
      recursive: false,
      showHidden: false}) async {
    Directory _path = Directory(path);

    int start = DateTime.now().millisecondsSinceEpoch;

    List<dynamic> _files;
    try {
      _files = (await _path.list(recursive: recursive).toList()).map((path) {
        if (FileSystemEntity.isDirectorySync(path.path))
          return MyFolder(
              name: p.split(path.absolute.path).last,
              path: path.absolute.path,
              type: "Directory");
        else
          return MyFile(
              name: p.split(path.absolute.path).last,
              path: path.absolute.path,
              type: "File");
      }).toList();

      // Removing hidden files & folders from the list
      if (!showHidden) {
        print("Core: excluding hidden");
        _files.removeWhere((test) {
          bool _isHidden = test.name.startsWith('.') == true;
          print("filtering: " + test.name + "\nhidden: $_isHidden");
          return test.name.startsWith('.') == true;
        });
      }
    } catch (e) {
      throw CoreNotifierError(e.toString());
    }

    int end = DateTime.now().millisecondsSinceEpoch;
    print("[Core] Elapsed time : ${end - start} ms");
    return utils.sort(_files, sortedBy, reverse: reverse);
  }

  /// search for files and folder in current directory & sub-directories,
  /// and return [File] or [Directory]
  ///
  /// [path]: start point
  ///
  /// [query]: regex or simple string
  Future<List<dynamic>> search(dynamic path, String query,
      {bool matchCase: false, recursive: true, bool hidden: false}) async {
    int start = DateTime.now().millisecondsSinceEpoch;

    List<dynamic> files =
        await getFoldersAndFiles(path, recursive: recursive, showHidden: hidden)
          ..retainWhere(
              (test) => test.name.toLowerCase().contains(query.toLowerCase()));

    int end = DateTime.now().millisecondsSinceEpoch;
    print("Search time: ${end - start} ms");
    return files;
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
        print("Deleting link @ $path");
        await Link(path).delete(recursive: true).then((_) => notifyListeners());
      }
      notifyListeners();
    } catch (e) {
      CoreNotifierError(e.toString());
    }
  }

  /// Create folder by path
  /// * i.e: `.createFolderByPath("/storage/emulated/0/", "folder name" )`
  Future<Directory> createFolderByPath(String path, String folderName) async {
    print("Creating folder: $folderName @ $path");
    var _directory = Directory(p.join(path, folderName));
    try {
      if (!_directory.existsSync()) {
        _directory.create();
        notifyListeners();
      } else {
        CoreNotifierError("File already exists");
      }
      return _directory;
    } catch (e) {
      throw CoreNotifierError(e);
    }
  }

  Future<void> refresh() async {
    notifyListeners();
  }

  BehaviorSubject<bool> _pasteMode = BehaviorSubject.seeded(false);

  Stream<bool> get pasteMode => _pasteMode.stream.asBroadcastStream();

  List<dynamic> copyList = [];

  void copyByPath(List<String> objects) {
    copyList.addAll(objects);
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
}

class CoreNotifierError extends Error {
  final String message;
  CoreNotifierError(this.message);

  @override
  String toString() {
    return message;
  }
}
