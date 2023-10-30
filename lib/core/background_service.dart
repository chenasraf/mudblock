import 'dart:io';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

final backgroundService = FlutterBackgroundService();
final notifs = AwesomeNotifications();

const notificationGroupId = 'mudblock';
const notificationChannelId = 'mudblock_game';
// final notificationId = Random().nextInt(1000);
const notificationId = 1337;

final channel = NotificationChannel(
  channelGroupKey: notificationGroupId,
  channelKey: notificationChannelId,
  channelName: 'Active Game Session',
  channelDescription: 'Primary notification channel for keeping game active',
  defaultColor: const Color(0xFF9D50DD),
  ledColor: Colors.white,
  importance: NotificationImportance.High,
  // locked: true,
  // criticalAlerts: true,
);

Future<void> initBackgroundService() async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    return;
  }
  notifs.initialize(
    null,
    // 'resource://drawable/res_app_icon',
    [channel],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: notificationGroupId,
        channelGroupName: 'Mudblock',
      )
    ],
    debug: true,
  );

  await backgroundService.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,

      // auto start service
      autoStart: false,
      isForegroundMode: true,

      foregroundServiceNotificationId: notificationId,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'Mudblock Background Service',
      initialNotificationContent: 'Initializing',
    ),
    iosConfiguration: IosConfiguration(
        // TODO
        ),
  );
}

Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
}

