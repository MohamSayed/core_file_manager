// framework
import 'package:flutter/material.dart';

// packages
import 'package:flutter_file_manager/flutter_file_manager.dart';

// local files
class DetailScreen extends StatelessWidget {
  final String path;
  const DetailScreen({@required this.path});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: FutureBuilder<Map>(
        future: FileManager.fileDetails(
            path), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Press button to start.');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              return ListView(children: _detailWidgets(snapshot.data));
          }
          return null; // unreachable
        },
      ),
    );
  }

  List<Widget> _detailWidgets(data) {
    List<Widget> widgets = <Widget>[];
    data.forEach((key, value) => widgets.add(ListTile(
          leading: Text(key + ": "),
          title: Text(value.toString()),
        )));
    return widgets;
  }
}
