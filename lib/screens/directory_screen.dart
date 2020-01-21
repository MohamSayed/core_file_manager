// dart
import 'dart:io';

// framework
import 'package:flutter/material.dart';

// packages
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as pathlib;
import 'package:tuple/tuple.dart';

// app files
import 'package:core_file_manager/notifiers/core.dart';
import 'package:core_file_manager/ui/widgets/appbar_popup_menu.dart';
import 'package:core_file_manager/ui/widgets/search.dart';
import 'package:core_file_manager/notifiers/preferences.dart';
import 'package:core_file_manager/ui/widgets/file.dart';
import 'package:core_file_manager/ui/widgets/folder.dart';
import 'package:core_file_manager/helpers/filesystem_utils.dart' as filesystem;
import 'package:core_file_manager/ui/widgets/context_dialog.dart';
import 'package:core_file_manager/helpers/io_extensions.dart';
import 'package:core_file_manager/ui/widgets/appbar_path_widget.dart';
import 'package:core_file_manager/ui/widgets/floating_action_button.dart';

class DirectoryScreen extends StatefulWidget {
  final String path;
  const DirectoryScreen({@required this.path}) : assert(path != null);
  @override
  _DirectoryScreenState createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen>
    with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController(keepScrollOffset: true);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    debugPrint("FolderListScreen: built or rebuilt");
    return Consumer2<CoreNotifier, PreferencesNotifier>(
      child: DirectoryFAB(),
      builder: (_, coreNotifier, preferencesNotifier, child) => Scaffold(
          body: RefreshIndicator(
            onRefresh: () {
              return Future.delayed(Duration(milliseconds: 100))
                  .then((_) => setState(() {}));
            },
            // It is better solution for `NestedScrollView` to be wrapped in `RefreshIndicator` widget
            child: NestedScrollView(
              headerSliverBuilder: (context, val) => [
                SliverAppBar(
                  floating: true,
                  leading: BackButton(onPressed: () {
                    if (coreNotifier.currentPath.absolute.path ==
                        pathlib.separator) {
                      Navigator.popUntil(context,
                          ModalRoute.withName(Navigator.defaultRouteName));
                    } else {
                      coreNotifier.navigateBackdward();
                    }
                  }),
                  actions: <Widget>[
                    IconButton(
                      // Go home
                      onPressed: () {
                        Navigator.popUntil(context,
                            ModalRoute.withName(Navigator.defaultRouteName));
                      },
                      icon: Icon(Icons.home),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () => showSearch(
                          context: context,
                          delegate: Search(path: widget.path)),
                    ),
                    AppBarPopupMenu()
                  ],
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(25),
                    child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.all(4.0),
                        child: AppBarPathWidget(
                          onDirectorySelected: (dir) {
                            coreNotifier.navigateToDirectory(dir.absolute.path);
                          },
                          path: coreNotifier.currentPath.absolute.path,
                        )),
                  ),
                ),
              ],
              body: StreamBuilder<List<FileSystemEntity>>(
                // This function Invoked every time user go back to the previous directory
                stream: filesystem.fileStream(
                    coreNotifier.currentPath.absolute.path,
                    keepHidden: preferencesNotifier.hidden),
                builder: (BuildContext context,
                    AsyncSnapshot<List<FileSystemEntity>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Center(child: Text('Refresh!'));
                    case ConnectionState.active:
                      return Container(width: 0.0, height: 0.0);
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        if (snapshot.error is FileSystemException) {
                          return Center(child: Text("Permission Denied"));
                        }
                      } else if (snapshot.data.length != 0) {
                        return GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            controller: _scrollController,
                            key: PageStorageKey(widget.path),
                            padding: const EdgeInsets.only(
                                left: 10.0, right: 10.0, top: 0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4),
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              // folder
                              if (snapshot.data[index] is Directory) {
                                return FolderWidget(
                                    path: snapshot.data[index].path,
                                    name: snapshot.data[index].basename());
                                // file
                              } else if (snapshot.data[index] is File) {
                                return FileWidget(
                                  name: snapshot.data[index].basename(),
                                  onTap: () {
                                    OpenFile.open(snapshot.data[index].path)
                                        .then(print);
                                  },
                                  onLongPress: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => FileContextDialog(
                                              path: snapshot.data[index].path,
                                              name: snapshot.data[index]
                                                  .basename(),
                                            ));
                                  },
                                );
                              }
                              return Container();
                            });
                      } else {
                        return Center(
                          child: Text("Empty Directory!"),
                        );
                      }
                  }
                  return null; // unreachable
                },
              ),
            ),
          ),
          floatingActionButton: child),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
