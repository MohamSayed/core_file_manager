// dart
import 'dart:io';

// framework
import 'package:flutter/material.dart';

// packages & plugins
import 'package:path/path.dart' as pathlib;

// app
import 'package:core_file_manager/helpers/filesystem_utils.dart' as filesystem;

class CreateDialog extends StatefulWidget {
  final String path;
  final Text title;
  final Function(String) onCreate;

  /// Show a dialog that accept allowed linux name
  const CreateDialog(
      {@required this.path, this.title, @required this.onCreate});
  @override
  _CreateDialogState createState() => _CreateDialogState();
}

class _CreateDialogState extends State<CreateDialog> {
  TextEditingController _textEditingController;

  int _status = 0;

  // if creating hidden folder
  bool _helperText = false;

  String _fileName;

  bool _emptyText = true;

  // 1
  String _disallowedCharsError = "Disallowed Characters";

  // 2
  String _fileAlreadyExistsError = "File already exists!";

  String hiddenFileText = "This folder will be hidden";

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
    return Builder(
        builder: (context) => ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: SimpleDialog(
              title: widget.title ?? Text("Create new"),
              contentPadding: EdgeInsets.all(20),
              children: <Widget>[
                // album textfield
                Row(
                  children: <Widget>[
                    Flexible(
                        child: TextField(
                      controller: _textEditingController,
                      onChanged: (name) {
                        _fileName = name;
                        setState(() {
                          _status = _validName(name, widget.path);
                          if (name.isNotEmpty) {
                            _emptyText = false;
                          } else {
                            _emptyText = true;
                          }
                          _helperText = name.startsWith('.');
                        });
                      },
                      decoration: InputDecoration(
                          errorText: _statusText(),
                          hintText: "Folder Name",
                          helperText: _helperText ? hiddenFileText : null,
                          helperStyle: _helperText
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
                      onPressed: _status == 0 && _emptyText == false
                          ? () {
                              widget.onCreate(
                                  pathlib.join(widget.path, _fileName));
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: Text(
                        "Create",
                      ),
                    ),
                  ],
                )
              ],
            )));
  }

  // 0: valid
  // 1: invalid unexpected character
  // 2: already exists
  int _validName(String name, String currentPath) {
    if (name.contains('/') || name.contains(r'\')) {
      return 1;
    } else if (Directory(pathlib.join(currentPath, name)).existsSync()) {
      if (name.isEmpty) {
        return 0;
      } else
        return 2;
    } else {
      return 0;
    }
  }

  // 0: valid
  // 1: invalid unexpected character
  // 2: already exists
  String _statusText() {
    if (_status == 0) {
      return null;
    } else if (_status == 1) {
      return _disallowedCharsError;
    } else if (_status == 2) {
      return _fileAlreadyExistsError;
    }
    return null;
  }
}
