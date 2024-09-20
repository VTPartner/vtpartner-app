import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/routings/router.dart';
import 'package:vt_partner/themes/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp(
      child: ChangeNotifierProvider(
        create: (context) => AppInfo(),
        child: MaterialApp(
            title: 'VT Partner',
            debugShowCheckedModeBanner: false,
            theme: ThemeClass.themeData,
            // home: const CustomMarkerScreen(),
            initialRoute: SplashRoute,
            onGenerateRoute: generateRoute,
          ),
      )));
}

class MyApp extends StatefulWidget {
  final Widget? child;

  MyApp({this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()!.restartApp();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();
  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}
