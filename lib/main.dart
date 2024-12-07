import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/routings/router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(message.notification!.title.toString());
  print(message.notification!.body.toString());
  print(message.data.toString());
  print("Handling a background message: ${message.messageId}");
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  // runApp(MyApp(
  //     child: ChangeNotifierProvider(
  //       create: (context) => AppInfo(),
  //       child: MaterialApp(
  //           title: 'VT Partner',
  //           debugShowCheckedModeBanner: false,
  //           theme: ThemeClass.themeData,
  //           // home: const CustomMarkerScreen(),
  //           initialRoute: SplashRoute,
  //           onGenerateRoute: generateRoute,
  //         ),
  //     )));
  runApp(MyApp(
      child: ChangeNotifierProvider(
        create: (context) => AppInfo(),
        child: MaterialApp(
            title: 'VT Partner',
            debugShowCheckedModeBanner: false,
theme: ThemeClass.themeData,
      // home: const MySplashScreen(),
      // onGenerateRoute: routes,
      initialRoute: SplashRoute,
            onGenerateRoute: generateRoute,
          ),
      )));
      
}

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//   print(message.notification!.title.toString());
//   print(message.notification!.body.toString());
//   print(message.data.toString());
//   print("Handling a background message: ${message.messageId}");
// }

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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}
