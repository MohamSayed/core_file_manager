// framework
import 'dart:io';

import 'package:flutter/material.dart';

// packages
import 'package:path/path.dart' as pathlib;

// app
import 'package:basic_file_manager/helpers/filesystem_utils.dart' as filesystem;

class AppBarPathWidget extends StatelessWidget {
  final String path;

  final Function(Directory) onDirectorySelected;

  const AppBarPathWidget(
      {@required this.path, @required this.onDirectorySelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.0),
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
          children: filesystem.splitPathToDirectories(path).map((splittedPath) {
        if (splittedPath.absolute.path == pathlib.separator) {
          return GestureDetector(
              onTap: () {
                onDirectorySelected(Directory("/"));
                print(splittedPath);
              },
              child: Text(pathlib.separator));
        } else {
          return GestureDetector(
            onTap: () {
              onDirectorySelected(splittedPath);
              print(splittedPath);
            },
            child: Container(
              child: Text(
                "${pathlib.basename(splittedPath.absolute.path)}${pathlib.separator}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      }).toList()),
    );
  }
}
