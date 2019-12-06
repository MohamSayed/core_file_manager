import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:basic_file_manager/notifiers/core.dart';
import 'package:toast/toast.dart';


class CreateFolderDialog extends StatefulWidget {
  final String path;

  /// Show a dialog that accept allowed linux name
  const CreateFolderDialog({@required this.path});
  @override
  _CreateFileDialogState createState() => _CreateFileDialogState();
}

class _CreateFileDialogState extends State<CreateFolderDialog> {
  TextEditingController _textEditingController;
  bool _allowedFolderName = true;
  // if creating hidden folder
  bool _hidden = false;
  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoreNotifier>(
        builder: (context, model, child) => Builder(
            builder: (context) => ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: SimpleDialog(
                  title: Text("Create new folder"),
                  contentPadding: EdgeInsets.all(20),
                  children: <Widget>[
                    // album textfield
                    Row(
                      children: <Widget>[
                        Flexible(
                            child: TextField(
                          controller: _textEditingController,
                          onChanged: (data) {
                            // Not allowed characters for album name, since we are creating real
                            // folder on linux
                            if (data.contains("/")) {
                              if (_allowedFolderName == true) {
                                setState(() {
                                  _allowedFolderName = false;
                                });
                              }
                            } else {
                              // creating a hidden folder helper text
                              if (data.startsWith('.')) {
                                if (_hidden == false) {
                                  setState(() {
                                    _hidden = true;
                                  });
                                }
                              } else {
                                if (_hidden == true) {
                                  setState(() {
                                    _hidden = false;
                                  });
                                }
                              }
                              if (_allowedFolderName == false) {
                                setState(() {
                                  _allowedFolderName = true;
                                });
                              }
                            }
                          },
                          decoration: InputDecoration(
                              errorText: !_allowedFolderName
                                  ? " Disallowed Chararcters: /"
                                  : null,
                              hintText: "Folder Name",
                              helperText:
                                  _hidden ? "This folder will be hidden" : null,
                              helperStyle: _hidden
                                  ? TextStyle(color: Colors.deepOrange)
                                  : TextStyle()),
                        ))
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // cancel
                      children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Cancel",
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                        ),
                        //  create button
                        FlatButton(
                          onPressed: _allowedFolderName
                              ? () async {
                                  var _directory =
                                      await model.createFolderByPath(
                                          widget.path,
                                          _textEditingController?.text);

                                  if (_directory != null) {
                                    // leaving dialog
                                    Navigator.of(context).pop();
                                  } else {
                                    Toast.show("Folder already Exists", context,
                                        duration: Toast.LENGTH_SHORT,
                                        gravity: Toast.TOP);
                                  }
                                }
                              : null,
                          child: Text(
                            "Create",
                          ),
                        ),
                      ],
                    )
                  ],
                ))));
  }
}
