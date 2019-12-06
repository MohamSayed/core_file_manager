import 'package:flutter/material.dart';


class FileWidget extends StatelessWidget {
  final String name;
  final onTap;
  final onLongPress;
  const FileWidget({@required this.name, this.onTap, this.onLongPress});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: onTap,
      onLongPress: onLongPress,
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
