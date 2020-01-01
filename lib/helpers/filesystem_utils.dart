// dart
import 'dart:io';

// packages
import 'package:basic_file_manager/notifiers/preferences.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as pathlib;
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

// local files
import 'package:basic_file_manager/helpers/io_extensions.dart';

String storageRootPath = "/storage/emulated/0/";

/// Return all **paths**
Future<List<Directory>> getStorageList() async {
  List<Directory> paths = await getExternalStorageDirectories();
  List<Directory> filteredPaths = List<Directory>();
  for (Directory dir in paths) {
    filteredPaths
        .add(await getExternalStorageWithoutDataDir(dir.absolute.path));
  }
  return filteredPaths;
}

/// This function aims to get path like: `/storage/emulated/0/`
/// not like `/storage/emulated/0/Android/data/package.name.example/files`
Future<Directory> getExternalStorageWithoutDataDir(
    String unfilteredPath) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  print("storage_helper->getExternalStorageWithoutDataDir: " +
      packageInfo.packageName);
  String subPath =
      pathlib.join("Android", "data", packageInfo.packageName, "files");
  if (unfilteredPath.contains(subPath)) {
    String filteredPath = unfilteredPath.split(subPath).first;
    print("storage_helper->getExternalStorageWithoutDataDir: " + filteredPath);
    return Directory(filteredPath);
  } else {
    return Directory(unfilteredPath);
  }
}

/// keepHidden: show files that start with .
Future<List<FileSystemEntity>> getFoldersAndFiles(String path,
    {changeCurrentPath: true,
    Sorting sortedBy: Sorting.Type,
    reverse: false,
    recursive: false,
    keepHidden: false}) async {
  Directory _path = Directory(path);
  List<FileSystemEntity> _files;
  try {
    _files = await _path.list(recursive: recursive).toList();
    _files = _files.map((path) {
      if (FileSystemEntity.isDirectorySync(path.path))
        return Directory(
          path.absolute.path,
        );
      else
        return File(
          path.absolute.path,
        );
    }).toList();

    // Removing hidden files & folders from the list
    if (!keepHidden) {
      print("filesystem->getFoldersAndFiles: excluding hidden");
      _files.removeWhere((FileSystemEntity test) {
        return test.basename().startsWith('.') == true;
      });
    }
  } on FileSystemException catch (e) {
    print(e);
    return [];
  }
  return sort(_files, sortedBy, reverse: reverse);
}

/// search for files and folder in current directory & sub-directories,
/// and return [File] or [Directory]
///
/// [path]: start point
///
/// [query]: regex or simple string
Future<List<FileSystemEntity>> search(dynamic path, String query,
    {bool matchCase: false, recursive: true, bool hidden: false}) async {
  int start = DateTime.now().millisecondsSinceEpoch;

  List<FileSystemEntity> files = await getFoldersAndFiles(path,
      recursive: recursive, keepHidden: hidden)
    ..retainWhere(
        (test) => test.basename().toLowerCase().contains(query.toLowerCase()));

  int end = DateTime.now().millisecondsSinceEpoch;
  print("Search time: ${end - start} ms");
  return files;
}

Future<int> getFreeSpace(String path) async {
  MethodChannel platform = const MethodChannel('samples.flutter.dev/battery');
  int freeSpace = await platform.invokeMethod("getFreeStorageSpace");
  return freeSpace;
}

/// Create folder by path
/// * i.e: `.createFolderByPath("/storage/emulated/0/", "folder name" )`
Future<Directory> createFolderByPath(String path, String folderName) async {
  print("filesystem_utils->createFolderByPath: $folderName @ $path");
  var _directory = Directory(pathlib.join(path, folderName));
  try {
    if (!_directory.existsSync()) {
      _directory.create();
    } else {
      FileSystemException("File already exists");
    }
    return _directory;
  } catch (e) {
    throw FileSystemException(e);
  }
}

/// This function returns every [Directory] in th path
List<Directory> splitPathToDirectories(String path) {
  List<Directory> splittedPath = List();
  Directory pathDir = Directory(path);
  splittedPath.add(pathDir);
  for (var item in pathlib.split(path)) {
    splittedPath.add(pathDir.parent);
    pathDir = pathDir.parent;
  }
  return splittedPath.reversed.toList();
}

Future<List<FileSystemEntity>> sort(List<FileSystemEntity> elements, Sorting by,
    {bool reverse: false}) async {
  try {
    switch (by) {
      case Sorting.Type:
        if (!reverse)
          return elements
            ..sort((f1, f2) => FileSystemEntity.isDirectorySync(f1.path) ==
                    FileSystemEntity.isDirectorySync(f2.path)
                ? 0
                : 1);
        else
          return (elements..sort()).reversed;
        break;
      default:
        return elements..sort();
    }
  } catch (e) {
    print(e);
    return [];
  }
}
