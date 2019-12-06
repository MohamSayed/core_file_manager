// framework
import 'package:flutter/material.dart';

// app
import 'package:basic_file_manager/screens/folder_list_screen.dart';
import 'package:basic_file_manager/widgets/context_dialog.dart';

class FolderWidget extends StatelessWidget {
  final String path;
  final String name;

  const FolderWidget({@required this.path, @required this.name});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => FolderListScreen(path: path)));
      },
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) => FolderContextDialog(
                  path: path,
                  name: name,
                ));
      },
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Icon(
          Icons.folder,
          size: 50.0,
        ),
        Text(
          name,
          style: TextStyle(fontSize: 11.5),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        )
      ]),
    ));
  }
}
