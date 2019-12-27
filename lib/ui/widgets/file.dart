import 'package:basic_file_manager/ui/widgets/context_dialog.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class FileWidget extends StatelessWidget {
  final String path;
  final String name;
  final onTap;
  final onLongPress;
  const FileWidget(
      {@required this.name, this.onTap, this.onLongPress, this.path});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: onTap ??
          () {
            OpenFile.open(path);
          },
      onLongPress: onLongPress ??
          () {
            showDialog(
                context: context,
                builder: (context) => FileContextDialog(
                      path: path,
                      name: name,
                    ));
          },
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Image.asset(
          "assets/file/unknown_file_type2.png",
          width: 50,
          height: 50,
        ),
        Text(
          name,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: TextStyle(fontSize: 11.5),
        )
      ]),
    ));
  }
}
