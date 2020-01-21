// flutter
import 'package:core_file_manager/notifiers/preferences.dart';
import 'package:core_file_manager/ui/widgets/create_dialog.dart';
import 'package:flutter/material.dart';

// external packages
import 'package:provider/provider.dart';

// app files
import 'package:core_file_manager/notifiers/core.dart';
import 'package:core_file_manager/helpers/filesystem_utils.dart' as filesystem;

class DirectoryFAB extends StatelessWidget {
  static int rebuildCount = 0;
  const DirectoryFAB({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    rebuildCount += 1;
    debugPrint("DirectoryFAB: build or rebuild = $rebuildCount");
    return Consumer2<CoreNotifier, PreferencesNotifier>(
        builder: (context, coreNotifier, preferencesNotifier, _) =>
            StreamBuilder<bool>(
              stream: preferencesNotifier.showFloatingButton,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.hasError) return Text('Error:	${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text('Select	lot');
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  case ConnectionState.active:
                    return FloatingActionButton(
                      tooltip: "Create Folder",
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(16.0))),
                      child: Icon(Icons.add),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) => CreateDialog(
                                path: coreNotifier.currentPath.absolute.path,
                                onCreate: (path) {
                                  filesystem.createFolderByPath(path);
                                  coreNotifier.reload();
                                },
                              )),
                    );
                  case ConnectionState.done:
                    if (snapshot.data == true)
                      return FloatingActionButton(
                        tooltip: "Create Folder",
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0))),
                        child: Icon(Icons.add),
                        onPressed: () => showDialog(
                            context: context,
                            builder: (context) => CreateDialog(
                                  path: coreNotifier.currentPath.absolute.path,
                                  onCreate: (path) {
                                    filesystem.createFolderByPath(path);
                                    coreNotifier.reload();
                                  },
                                )),
                      );
                    else
                      return Container(
                        height: 0.0,
                        width: 0.0,
                      );
                }
                return Container(
                  width: 0.0,
                  height: 0.0,
                );
              },
            ));
  }
}
