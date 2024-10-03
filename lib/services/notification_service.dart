  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:flutter_local_notifications/flutter_local_notifications.dart';
  import 'package:timezone/data/latest.dart' as tz;
  import 'package:timezone/timezone.dart' as tz;
  import 'package:permission_handler/permission_handler.dart';
  import '../model/enum.dart';

  class NotificationService {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    static const String channelId = 'notification_channel';
    static const String channelName = 'Notifications';
    static const String channelDescription = 'Notifications for bills';

    NotificationService() {
      _init();
    }

    Future<void> _init() async {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh')); // Thiết lập múi giờ cho Việt Nam

      const androidInitializationSettings = AndroidInitializationSettings('notification_icon');
      const initializationSettings = InitializationSettings(android: androidInitializationSettings);

      try {
        bool? initialized = await flutterLocalNotificationsPlugin.initialize(initializationSettings);
        if (initialized == null || initialized == false) {
          print('Failed to initialize notifications plugin');
        } else {
          print('Notification plugin initialized successfully');
        }
        await _requestPermissions();
      } catch (e) {
        print('Error during notification initialization: $e');
      }
    }

    Future<void> _requestPermissions() async {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      } else {
        print('Notification permission granted');
      }

      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      } else {
        print('Schedule exact alarm permission granted');
      }
    }

    Future<void> scheduleNotification(
        int id, String title, String body, DateTime date, TimeOfDay time, Repeat repeat) async {
      try {
        tz.TZDateTime scheduledDate = _nextInstanceOfTime(date, time, repeat);
        print('Scheduling notification at: $scheduledDate for repeat: $repeat');

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelName,
              channelDescription: channelDescription,
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidAllowWhileIdle: true, // Cho phép thông báo khi thiết bị đang không hoạt động
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: _getDateTimeComponents(repeat), // Xác định cách lặp lại thông báo
        );

        if (repeat == Repeat.Quarterly) {
          _scheduleQuarterlyNotification(id, title, body, scheduledDate, time);
        }

        print('Notification scheduled successfully');
      } catch (e) {
        print('Error scheduling notification: $e');
      }
    }


    // Tính toán thời gian thông báo kế tiếp dựa trên chu kỳ lặp lại
    tz.TZDateTime _nextInstanceOfTime(DateTime date, TimeOfDay time, Repeat repeat) {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, date.year, date.month, date.day, time.hour, time.minute);

      print('Current time: $now');
      print('Initial scheduled time: $scheduledDate');

      // Nếu scheduledDate là trước now hoặc cùng ngày nhưng đã qua giờ hiện tại
      if (scheduledDate.isBefore(now) || (scheduledDate.day == now.day && scheduledDate.isBefore(now))) {
        print('Scheduled time is before now or the same day but past current time. Adjusting time...');
        switch (repeat) {
          case Repeat.Daily:
            scheduledDate = scheduledDate.add(const Duration(days: 1));
            break;
          case Repeat.Weekly:
            scheduledDate = scheduledDate.add(const Duration(days: 7));
            break;
          case Repeat.Monthly:
            scheduledDate = tz.TZDateTime(tz.local, scheduledDate.year, scheduledDate.month + 1, date.day, time.hour, time.minute);
            break;
          case Repeat.Quarterly:
            scheduledDate = _nextQuarterlyDate(scheduledDate, date.day, time);
            break;
          case Repeat.Yearly:
            scheduledDate = tz.TZDateTime(tz.local, scheduledDate.year + 1, date.month, date.day, time.hour, time.minute);
            break;
        }
        print('Adjusted scheduled time: $scheduledDate');
      }

      return scheduledDate;
    }

    tz.TZDateTime _nextQuarterlyDate(tz.TZDateTime scheduledDate, int day, TimeOfDay time) {
      int month = scheduledDate.month + 3;
      int year = scheduledDate.year;
      if (month > 12) {
        month -= 12;
        year += 1;
      }

      int maxDayOfMonth = DateTime(year, month + 1, 0).day;
      int adjustedDay = day <= maxDayOfMonth ? day : maxDayOfMonth;

      tz.TZDateTime nextDate = tz.TZDateTime(
          tz.local, year, month, adjustedDay, time.hour, time.minute);
      print('Calculated next quarterly date: $nextDate');
      return nextDate;
    }

    DateTimeComponents _getDateTimeComponents(Repeat repeat) {
      const componentMap = {
        Repeat.Daily: DateTimeComponents.time,
        Repeat.Weekly: DateTimeComponents.dayOfWeekAndTime,
        Repeat.Monthly: DateTimeComponents.dayOfMonthAndTime,
        Repeat.Quarterly: DateTimeComponents.dateAndTime,
        Repeat.Yearly: DateTimeComponents.dateAndTime,
      };
      return componentMap[repeat] ?? DateTimeComponents.dateAndTime;
    }

    void _scheduleQuarterlyNotification(
        int id, String title, String body, tz.TZDateTime scheduledDate, TimeOfDay time) {
      Timer(
        scheduledDate.difference(tz.TZDateTime.now(tz.local)),
            () async {
          try {
            tz.TZDateTime nextQuarterlyDate = _nextQuarterlyDate(scheduledDate, scheduledDate.day, time);

            print('Scheduling next quarterly notification at: $nextQuarterlyDate');
            await scheduleNotification(id, title, body, nextQuarterlyDate, time, Repeat.Quarterly);
          } catch (e) {
            print('Error scheduling quarterly notification: $e');
          }
        },
      );
    }

    // Chuyển string to int cho notification ID
    int _convertStringToInt(String str) => str.hashCode;

    // Hủy thông báo
    Future<void> cancelNotification(String id) async {
      try {
        int notificationId = _convertStringToInt(id);
        await flutterLocalNotificationsPlugin.cancel(notificationId);
        print('Notification with id $id canceled');
      } catch (e) {
        print('Error canceling notification: $e');
      }
    }
  }