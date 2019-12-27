// dart
import 'dart:io';

// framework
import 'package:basic_file_manager/notifiers/core.dart';
import 'package:flutter/material.dart';

// packages
import 'package:path_provider/path_provider.dart';

// app
import 'package:basic_file_manager/helpers/filesystem_utils.dart';
import 'package:basic_file_manager/screens/folder_list_screen.dart';
import 'package:basic_file_manager/widgets/appbar_popup_menu.dart';
import 'package:basic_file_manager/helpers/filesystem_utils.dart' as filesystem;
import 'package:provider/provider.dart';


class StorageScreen extends StatefulWidget {
  @override
  _StorageScreenState createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  @override
  Widget build(BuildContext context) {
    var coreNotifier = Provider.of<CoreNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Storages"), actions: <Widget>[
        AppBarPopupMenu()
      ]),

      body: FutureBuilder<List<FileSystemEntity>>(
         future: getStorageList(), // a previously-obtained Future<String> or null
         builder: (BuildContext context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
           switch (snapshot.connectionState) {
             case ConnectionState.none:
               return Text('Press button to start.');
             case ConnectionState.active:
             case ConnectionState.waiting:
               return Center(child: CircularProgressIndicator(value: 10,));
             case ConnectionState.done:
               if (snapshot.hasError)
                 return Text('Error: ${snapshot.error}');
               return ListView.builder(
                 addAutomaticKeepAlives: true,
                 itemCount: snapshot.data.length,
                 itemBuilder: (context, int position){
                   return Card(
                     child: ListTile(
                       title: Text(snapshot.data[position].absolute.path),
                       subtitle: Row(children: [Text("Size: ${snapshot.data[position].statSync().size}")]),
                       dense: true,
                       onTap: (){
                         coreNotifier.currentPath = Directory(snapshot.data[position].absolute.path);
                         Navigator.push(context,
                             MaterialPageRoute(builder: (context) => FolderListScreen(path: snapshot.data[position].absolute.path)));
                       },
                     ),
                   );
                 },
               );
           }
           return null;  //unreachable
         },
       ),
    );
  }
}
