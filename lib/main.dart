// dart
import 'dart:io';

// framework
import 'package:flutter/material.dart';

// app files
import 'package:basic_file_manager/notifiers/core.dart';
import 'package:basic_file_manager/screens/folder_list_screen.dart';
import 'package:basic_file_manager/notifiers/preferences.dart';
import 'package:basic_file_manager/screens/storage_screen.dart';

// packages
import 'package:provider/provider.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:simple_permissions/simple_permissions.dart';

main() {
  runApp(MultiProvider(
    providers: [
      ValueListenableProvider(create: (context) => ValueNotifier(true)),
      ChangeNotifierProvider(create: (context) => CoreNotifier()),
      ChangeNotifierProvider(create: (context) => PreferencesNotifier()),
    ],
    child: MyApp(),
  ));
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ThemeData(
              primarySwatch: Colors.indigo,
              brightness: brightness,
            ),
        themedWidgetBuilder: (context, theme) {
          //_requestPermissions();
          FlutterStatusbarcolor.setStatusBarColor(theme.primaryColor);
          return MaterialApp(
            title: 'Flutter Demo',
            theme: theme,
            home: StorageScreen()
          );
        });
  }
}
