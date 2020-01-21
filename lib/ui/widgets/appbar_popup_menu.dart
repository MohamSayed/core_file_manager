// framework
import 'package:flutter/material.dart';

// packages
import 'package:provider/provider.dart';

// app files
import 'package:core_file_manager/screens/about.dart';
import 'package:core_file_manager/screens/settings.dart';
import 'package:core_file_manager/notifiers/core.dart';
import 'package:core_file_manager/ui/widgets/create_dialog.dart';
import 'package:core_file_manager/helpers/filesystem_utils.dart' as filesystem;

class AppBarPopupMenu extends StatelessWidget {
  const AppBarPopupMenu({Key key}) : super(key: key);
  static int rebuildCount = 0;
  @override
  Widget build(BuildContext context) {
    rebuildCount += 1;
    print("AppBarPopupMenu: build or rebuild = $rebuildCount");
    return Consumer<CoreNotifier>(
      builder: (context, coreNotifier, child) => PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "refresh") {
              coreNotifier.reload();
            } else if (value == "folder") {
              showDialog(
                  context: context,
                  builder: (context) => CreateDialog(
                        onCreate: (path) {
                          filesystem.createFolderByPath(path);
                          // leaving dialog
                          coreNotifier.reload();
                        },
                        path: coreNotifier.currentPath.path,
                        title: Text("Create new folder"),
                      ));
            } else if (value == "settings") {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Settings()));
            } else if (value == "about") {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutScreen()));
            } else if (value == "paste") {
              coreNotifier.pasteByPath(coreNotifier.currentPath.path);
            }
            //...
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                PopupMenuItem<String>(
                    enabled: coreNotifier.copyList.isNotEmpty,
                    value: 'paste',
                    child: Text('Paste Here')),

                const PopupMenuItem<String>(
                    value: 'refresh', child: Text('Refresh')),
                const PopupMenuItem<String>(
                    value: 'sort', child: Text('Sort By')),
                const PopupMenuItem<String>(
                    value: 'folder', child: Text('New Folder')),
                const PopupMenuItem<String>(
                    value: 'settings', child: Text('Settings')),
                const PopupMenuItem<String>(
                    value: 'about', child: Text('About')),
                //...
              ]),
    );
  }
}
