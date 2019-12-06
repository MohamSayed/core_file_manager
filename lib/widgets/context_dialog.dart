// framework
import 'package:flutter/material.dart';

// package
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';

// app
import 'package:basic_file_manager/notifiers/core.dart';
import 'package:basic_file_manager/screens/details.dart';

class ContextDialog extends SimpleDialog {
  const ContextDialog({
    Key key,
    this.title: const Text("Context Dialog"),
    this.titlePadding = const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
    this.children,
    this.contentPadding = const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 16.0),
    this.backgroundColor,
    this.elevation,
    this.semanticLabel,
    this.shape,
  })  : assert(titlePadding != null),
        assert(contentPadding != null),
        super(
          key: key,
        );

  final Widget title;

  final EdgeInsetsGeometry titlePadding;

  final List<Widget> children;

  final EdgeInsetsGeometry contentPadding;

  final Color backgroundColor;

  final double elevation;

  final String semanticLabel;

  final ShapeBorder shape;
}

class FolderContextDialog extends StatelessWidget {
  final String path;
  final String name;
  const FolderContextDialog({Key key, @required this.path, @required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CoreNotifier>(
        builder: (context, model, child) => ClipRect(
              child: ContextDialog(
                title: Text(name),
                children: <Widget>[
                  SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context);
                        model.delete(path);
                      },
                      child: ListTile(
                          leading: Icon(Icons.delete), title: Text('Delete'))),

                  //...
                ],
              ),
            ));
  }
}

class FileContextDialog extends StatelessWidget {
  final String path;
  final String name;
  const FileContextDialog({Key key, @required this.path, @required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CoreNotifier>(
        builder: (context, model, child) => ClipRect(
              child: SimpleDialog(
                title: Text(name),
                children: <Widget>[
                  // open option
                  SimpleDialogOption(
                    onPressed: () async {
                    //  OpenFile.open(path);
                      Navigator.pop(context);
                    },
                    child: ListTile(
                        leading: Icon(Icons.launch), title: Text('Open')),
                  ),

                  // copy single files
                  SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context);
                        model.copyByPath([path]);
                      },
                      child: ListTile(
                          leading: Icon(Icons.content_copy),
                          title: Text('Copy'))),

                  SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context);
                        model.delete(path);
                      },
                      child: ListTile(
                          leading: Icon(Icons.delete), title: Text('Delete'))),
                  SimpleDialogOption(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: ListTile(
                        leading: Icon(
                          Icons.share,
                        ),
                        title: Text('Share')),
                  ),
                  SimpleDialogOption(
                    onPressed: () async {
                      // Poping off context dialog after navigating through details screen
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                    path: path,
                                  )));
                    },
                    child: ListTile(
                        leading: Container(
                          child: Image.asset(
                            "assets/details.png",
                          ),
                          height: 24.0,
                          width: 24.0,
                        ),
                        title: Text('Details')),
                  )
                  //...
                ],
              ),
            ));
  }
}
