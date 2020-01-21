// dart
import 'dart:io';

// framework
import 'package:flutter/material.dart';

// app files
import 'package:core_file_manager/notifiers/core.dart';
import 'package:core_file_manager/screens/directory_screen.dart';
import 'package:core_file_manager/notifiers/preferences.dart';
import 'package:core_file_manager/screens/storage_screen.dart';
import 'package:core_file_manager/helpers/io_extensions.dart';

// packages
import 'package:provider/provider.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:path_provider/path_provider.dart';

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
          FlutterStatusbarcolor.setStatusBarColor(theme.primaryColor);
          return MaterialApp(
              title: 'Basic FIle Manager', theme: theme, home: StorageScreen());
        });
  }
}
