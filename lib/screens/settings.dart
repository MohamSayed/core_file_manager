// packages
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:dynamic_theme/theme_switcher_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// local
import 'package:basic_file_manager/notifiers/preferences.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: Consumer<PreferencesNotifier>(
          builder: (context, model, child) => ListView(
                padding: EdgeInsets.all(10.0),
                children: <Widget>[
                  // Theme
                  ListTile(
                    leading: Text(
                      "Theme",
                    ),
                    onTap: () => showChooser(),
                    dense: true,
                  ),
                  Divider(),
                  // Floating action button
                  StreamBuilder<bool>(
                    stream: model.showFloatingButton, //	a	Stream<int>	or	null
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.hasError)
                        return Text('Error:	${snapshot.error}');
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Text('Select	lot');
                        case ConnectionState.waiting:
                          return SwitchListTile.adaptive(
                            // avoid showing text ..
                            value: snapshot.data ?? false,
                            onChanged: (value) =>
                                model.setFloatingButtonEnabled(value),
                            title: Text("Show Floating Action Button"),
                          );
                        case ConnectionState.active:
                          return SwitchListTile.adaptive(
                            value: snapshot.data,
                            onChanged: (value) =>
                                model.setFloatingButtonEnabled(value),
                            title: Text("Show Floating Action Button"),
                          );
                        case ConnectionState.done:
                          return SwitchListTile.adaptive(
                            value: snapshot.data,
                            onChanged: (value) =>
                                model.setFloatingButtonEnabled(value),
                            title: Text("Show Floating Action Button"),
                          );
                      }
                      return null;
                    },
                  ),

                  Divider(),
                  SwitchListTile.adaptive(
                    value: model.hidden,
                    onChanged: (value) => model.hidden = value,
                    title: Text("Show Hidden"),
                  )
                ],
              ),
        ));
  }

  /// Credit: from https://github.com/Norbert515/dynamic_theme/blob/master/example/lib/main.dart
  void showChooser() {
    showDialog<void>(
        context: context,
        builder: (context) {
          return BrightnessSwitcherDialog(
            onSelectedTheme: (brightness) {
              DynamicTheme.of(context).setBrightness(brightness);
            },
          );
        });
  }
}
