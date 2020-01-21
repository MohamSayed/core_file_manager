// framework
import 'package:flutter/material.dart';

// app
import 'package:core_file_manager/screens/directory_screen.dart';
import 'package:core_file_manager/ui/widgets/context_dialog.dart';
import 'package:core_file_manager/notifiers/core.dart';
import 'package:provider/provider.dart';

class FolderWidget extends StatelessWidget {
  final String path;
  final String name;

  const FolderWidget({@required this.path, @required this.name});
  @override
  Widget build(BuildContext context) {
    var coreNotifier = Provider.of<CoreNotifier>(context, listen: false);
    return Container(
        child: InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: () {
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => FolderListScreen(path: path)));
        coreNotifier.navigateToDirectory(path);
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
