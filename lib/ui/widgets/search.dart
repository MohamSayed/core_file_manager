// framework
import 'dart:io';

import 'package:flutter/material.dart';

// packages
import 'package:provider/provider.dart';

// app files
import 'package:core_file_manager/notifiers/core.dart';
import 'package:core_file_manager/screens/directory_screen.dart';
import 'package:core_file_manager/helpers/filesystem_utils.dart' as filesystem;
import 'package:core_file_manager/helpers/io_extensions.dart';

class Search extends SearchDelegate<String> {
  final String path;
  Search({this.path});

  @override
  List<Widget> buildActions(BuildContext context) {
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        // clearing query
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Consumer<CoreNotifier>(
        builder: (context, model, child) =>
            StreamBuilder<List<FileSystemEntity>>(
              stream: filesystem.searchStream(path, query,
                  recursive: true), //	a	Stream<int>	or	null
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) return Text('Error:	${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text('Select	lot');
                  case ConnectionState.waiting:
                    return Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                          CircularProgressIndicator(),
                          Text('Searching...')
                        ]));
                  case ConnectionState.active:
                    return Container();
                  case ConnectionState.done:
                    return _Results(
                      results: snapshot.data,
                    );
                }
                return null;
              },
            ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Consumer<CoreNotifier>(
        builder: (context, model, child) => StreamBuilder(
              stream: filesystem.searchStream(path, query,
                  recursive: true), //	a	Stream<int>	or	null
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) return Text('Error:	${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text('Select	lot');
                  case ConnectionState.waiting:
                    return Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                          CircularProgressIndicator(),
                          Text('Searching...')
                        ]));
                  case ConnectionState.active:
                    return Text('${snapshot.data}');
                  case ConnectionState.done:
                    return _Results(
                      results: snapshot.data,
                    );
                }
                return null;
              },
            ));
  }
}

// note(Naga): is the right way of doing things here?
class _Results extends StatelessWidget {
  const _Results({
    Key key,
    @required this.results,
  }) : super(key: key);

  final List<FileSystemEntity> results;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      addAutomaticKeepAlives: true,
      key: key,
      itemBuilder: (context, index) {
        if (results[index] is Directory) {
          return ListTile(
            leading: Icon(Icons.folder),
            title: Text(results[index].basename()),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DirectoryScreen(
                            path: results[index].path,
                          )));
            },
          );
        } else if (results[index] is File) {
          return ListTile(
            leading: Icon(Icons.image),
            title: Text(results[index].basename()),
            onTap: () {},
          );
        } else
          return ListTile(
            leading: Icon(Icons.image),
            title: Text(results[index].basename()),
            onTap: () {},
          );
      },
    );
  }
}
