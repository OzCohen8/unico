import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationApi{
  static final _notifications = FlutterLocalNotificationsPlugin();
  // static final onNotifications = BehaviorSubject<String?>();

  static Future _notificationDetailes() async =>
  const NotificationDetails(
    android: AndroidNotificationDetails(
      "channel id",
      "channel name",
      channelDescription: "channel description",
      importance: Importance.max,
    ),
    iOS: IOSNotificationDetails(),
  );

//   static Future init({bool initScheduled = false}) async {
//   const ios = IOSInitializationSettings();
//   const android = AndroidInitializationSettings("@mipmap/ic_launcher");
//   const settings = InitializationSettings(android: android, iOS: ios);
//   await _notifications.initialize(settings, onSelectNotification: (payload) async {onNotifications.add(payload);});
// }

  static Future showNotification({int id =0, String? title, String? body, String? payload}) async =>
      _notifications.show(id, title, body, await _notificationDetailes(), payload: payload);
}


