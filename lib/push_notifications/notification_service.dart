import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/global/global.dart' as glb;
import 'package:vt_partner/delivery_agent_pages/models/user_ride_request_information.dart';
import 'package:vt_partner/push_notifications/notification_dailog_box.dart';
import 'package:vt_partner/routings/route_names.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    print("notification permission");
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("user granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("user provisional granted permission");
    } else {
      glb.showToast("Notification Permission denied");
      Future.delayed(Duration(seconds: 2), () {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

  Future<String> getDeviceToken() async {
    final pref = await SharedPreferences.getInstance();
    NotificationSettings settings = await messaging.requestPermission(
        alert: true, badge: true, sound: true);

    String? token = await messaging.getToken();
    print("device_token=> $token");
    // pref.setString("device_token", token!);
    return token!;
  }

  Future<String> getGoodsDriverDeviceToken() async {
    final pref = await SharedPreferences.getInstance();
    NotificationSettings settings = await messaging.requestPermission(
        alert: true, badge: true, sound: true);

    String? token = await messaging.getToken();
    print("goods_driver_device_token=> $token");

    return token!;
  }

  void isTokenRefreshed() async {
    final pref = await SharedPreferences.getInstance();
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print('Firebase Token Refreshed');
      pref.setString("device_token", '');
    });
  }

  void isGoodsDriverTokenRefreshed() async {
    final pref = await SharedPreferences.getInstance();
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print('Goods Driver Firebase Token Refreshed');
      pref.setString("goods_drive_device_token", '');
    });
  }

  //initialize
  void initLocalNotifications(
      BuildContext context, RemoteMessage remoteMessage) async {
    var androidInitSetting =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInitSetting = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitSetting, iOS: iosInitSetting);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
      handleMessage(context, remoteMessage);
    });
  }

  //firebase init
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (kDebugMode) {
        print("notification title=>${notification!.title}");
        print("notification body=>${notification.body}");
      }

      //ios
      if (Platform.isIOS) {
        iosForegroundMessage();
      }

      //android
      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
        if (message != null && message.data.isNotEmpty) {
          handleMessage(context, message);
        }
      }
    });
  }

  //function to show notifications
  @pragma("vm:entry-point")
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        message.notification!.android!.channelId.toString(),
        message.notification!.android!.channelId.toString(),
        importance: Importance.high,
        showBadge: true,
        playSound: true);

//android setting
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: "Channel Description",
            importance: Importance.high,
            playSound: true,
            priority: Priority.high,
            sound: channel.sound,
            ticker: 'ticker');

    //ios Settings
    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    //merge notification
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    //show notification
    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails,
          payload: "my_data");
    });
  }

  //background and terminated
  Future<void> setupInteractMessage(BuildContext context) async {
    //background state
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        if (message != null && message.data.isNotEmpty) {
          handleMessage(context, message);
        }
      },
    );

    //terminated state
    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message != null && message.data.isNotEmpty) {
          handleMessage(context, message);
        }
      },
    );

    //2. Foreground
    //When the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      //display ride request information - user information who request a ride
      if (remoteMessage != null && remoteMessage.data.isNotEmpty) {
        handleMessage(context, remoteMessage);
      }
      // readUserRideRequestInformation(
      //     remoteMessage!.data["booking_id"], context);
    });

    //3. Background
    // //When the app is in the background and opened directly from the push notification.
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
    //   //display ride request information - user information who request a ride
    //   if (remoteMessage != null && remoteMessage.data.isNotEmpty) {
    //     handleMessage(context, remoteMessage);
    //   }
    // });
  }

  //handle message
  Future<void> handleMessage(
      BuildContext context, RemoteMessage message) async {
    final pref = await SharedPreferences.getInstance();
    print("message.data=>${message.data}");
    if (message.data['intent'] == 'driver') {
      var bookingId = message.data['booking_id'];
      print('Notification For Pickup booking_id::$bookingId');
      readUserRideRequestInformation(message.data['booking_id'], context);
      return;
    }

    if (message.data['intent'] == 'live_tracking') {
      var bookingId = message.data['booking_id'];
      print('Notification For Driver Assinged booking_id::$bookingId');
      pref.setString("current_booking_id", bookingId);
      glb.booking_id = bookingId;
      Navigator.pushNamedAndRemoveUntil(
        context,
        CustomerOngoingRideDetailsRoute,
        (Route<dynamic> route) => false, // Removes all the routes
      );
    }
  }

//ios message
  Future iosForegroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
  }

  readUserRideRequestInformation(var booking_id, BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString("current_booking_id_assigned", booking_id);
    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/booking_details_for_ride_acceptance',
          {'booking_id': booking_id});
      if (kDebugMode) {
        print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        var result = response['results'][0];
        print("booking request result::$result");
        var customer_name = result['customer_name'].toString();
        var customer_id = result['customer_id'].toString();
        var pickup_address = result['pickup_address'].toString();
        var drop_address = result['drop_address'].toString();
        var distance = result['distance'].toString();
        var total_price = double.parse(result['total_price'].toString());
        var total_time = result['total_time'].toString();
        var pickup_lat = double.parse(result['pickup_lat'].toString());
        var pickup_lng = double.parse(result['pickup_lng'].toString());
        var destination_lat =
            double.parse(result['destination_lat'].toString());
        var destination_lng =
            double.parse(result['destination_lng'].toString());

        UserRideRequestInformationModel userRideRequestInformationModel =
            UserRideRequestInformationModel();
        userRideRequestInformationModel.pickupLatLng =
            LatLng(pickup_lat, pickup_lng);
        userRideRequestInformationModel.dropLatLng =
            LatLng(destination_lat, destination_lng);
        userRideRequestInformationModel.customerName = customer_name;
        userRideRequestInformationModel.customerId = customer_id;
        userRideRequestInformationModel.totalDistance = distance;
        userRideRequestInformationModel.pickupAddress = pickup_address;
        userRideRequestInformationModel.dropAddress = drop_address;
        userRideRequestInformationModel.totalPrice = total_price;
        userRideRequestInformationModel.totalTime = total_time;

        showCupertinoDialog(
            context: context,
            builder: (BuildContext context) => NotificationDialogBox(
                userRideRequestInformationModel:
                    userRideRequestInformationModel,
                bookingId: booking_id));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showToast("No booking details found .");
      } else {
        //glb.showToast("An error occurred while fetching booking details");
        // glb.showToast("An error occurred while fetching booking details: ${e.toString()}");
      }
    }
  }
}
