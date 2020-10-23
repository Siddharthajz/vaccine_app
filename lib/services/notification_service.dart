import 'dart:ui';
import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vaccineApp/locator.dart';
import 'package:vaccineApp/models/notification.dart';
import 'package:vaccineApp/services/debug_service.dart';
import 'package:vaccineApp/services/navigation_service.dart';

class Notifications {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final DebugService _debugService = locator<DebugService>();

  NotificationAppLaunchDetails notificationAppLaunchDetails;

  Notifications() {
    init();
  }

  void init() async{
    try {
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      await initNotifications(flutterLocalNotificationsPlugin);
      requestIOSPermissions(flutterLocalNotificationsPlugin);
    } catch(e,s){
      _debugService.debugException(e, s);
    }
  }

  // final BehaviorSubject<LocalNotification> didReceiveLocalNotificationSubject =
  // BehaviorSubject<LocalNotification>();
  //
  // final BehaviorSubject<String> selectNotificationSubject =
  // BehaviorSubject<String>();

  Future<void> initNotifications(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        LocalNotification receivedNotification = LocalNotification(id: id, title: title, body: body, payload: payload);
      },
    );
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
          onSelectNotification(payload);
        });
  }

  void requestIOSPermissions(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  onSelectNotification(String payLoad) async{
    if (payLoad != null && payLoad.isNotEmpty) {
      print("Notification Tapped for "+payLoad);
      try {
        // NavigationService _navigationService = locator<NavigationService>();
        // _navigationService.navigateTo(payLoad);
        var notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
        print(notificationAppLaunchDetails.payload);
      } catch(e) {
        print("Exception on Notification Tap: "+e.toString());
      }
    }
  }

  Future<void> showNotification(int notificationID, String notificationTitle, String notificationDescription, String notificationPayload) async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      "CHANNEL_DESCRIPTION",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      notificationID,
      notificationTitle,
      notificationDescription,
      platformChannelSpecifics,
      payload: notificationPayload,
    );
  }

  Future<void> scheduleNotification(int notificationID, DateTime scheduleNotificationDateTime, String notificationTitleText, String notificationBodyText, String payload) async {
    // var scheduleNotificationDateTime = DateTime.now().add(Duration(seconds: 15));
    print("Notification Scheduled for: "+ scheduleNotificationDateTime.toIso8601String());
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 1',
      'CHANNEL_NAME 1',
      "CHANNEL_DESCRIPTION 1",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );
    try {
      await flutterLocalNotificationsPlugin.schedule(
        notificationID,
        notificationTitleText,
        notificationBodyText,
        scheduleNotificationDateTime,
        platformChannelSpecifics,
        payload: payload,
      );
    } catch(e,s){
      _debugService.debugException(e, s);
    }
  }
  Future<void> cancelAllNotification() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch(e,s){
      _debugService.debugException(e, s);
    }
  }

  Future<void> cancelNotificationById(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
    } catch (e, s){
      _debugService.debugException(e, s);
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async{
    try {
      List<PendingNotificationRequest> pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      return pendingNotifications;
    } catch(e,s){
      _debugService.debugException(e, s);
    }
  }
}