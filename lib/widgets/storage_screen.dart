// dart
import 'dart:io';
// framework
import 'package:basic_file_manager/screens/folder_list_screen.dart';
import 'package:basic_file_manager/widgets/appbar_popup_menu.dart';
import 'package:flutter/material.dart';

// packages
import 'package:path_provider/path_provider.dart';

class StorageScreen extends StatefulWidget {
  @override
  _StorageScreenState createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Storages"), actions: <Widget>[
        AppBarPopupMenu()
      ]),

      body: FutureBuilder<List<Directory>>(
         future: getExternalStorageDirectories(), // a previously-obtained Future<String> or null
         builder: (BuildContext context, AsyncSnapshot<List<Directory>> snapshot) {
           switch (snapshot.connectionState) {
             case ConnectionState.none:
               return Text('Press button to start.');
             case ConnectionState.active:
             case ConnectionState.waiting:
               return Text('Awaiting result...');
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
                       dense: true,
                       onTap: (){
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
