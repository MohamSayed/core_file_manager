// dart
import 'dart:io';

// framework
import 'package:core_file_manager/notifiers/core.dart';
import 'package:flutter/material.dart';

// external packages
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';

// app
import 'package:core_file_manager/screens/directory_screen.dart';
import 'package:core_file_manager/ui/widgets/appbar_popup_menu.dart';
import 'package:core_file_manager/helpers/filesystem_utils.dart' as filesystem;
import 'package:provider/provider.dart';

class StorageScreen extends StatefulWidget {
  @override
  _StorageScreenState createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  @override
  Widget build(BuildContext context) {
    debugPrint("StorageScreen: built or rebuilt");
    final coreNotifier = Provider.of<CoreNotifier>(context, listen: false);
    return Scaffold(
      appBar:
          AppBar(title: Text("Storages"), actions: <Widget>[AppBarPopupMenu()]),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: filesystem.getStorageList(),
        builder: (BuildContext context,
            AsyncSnapshot<List<FileSystemEntity>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Pull to refresh!');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                  child: CircularProgressIndicator(
                value: 10,
              ));
            case ConnectionState.done:
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              return ListView.builder(
                addAutomaticKeepAlives: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, int position) {
                  return Card(
                    child: ListTile(
                      title: Text(snapshot.data[position].absolute.path),
                      subtitle: Row(children: [
                        Text("Size: ${snapshot.data[position].statSync().size}")
                      ]),
                      dense: true,
                      onTap: () {
                        coreNotifier.currentPath =
                            Directory(snapshot.data[position].absolute.path);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DirectoryScreen(
                                    path: snapshot
                                        .data[position].absolute.path)));
                      },
                    ),
                  );
                },
              );
          }
          return null; //unreachable
        },
      ),
    );
  }
}
