import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';
import '../../feature/scheduleFeature/domain/entities/schedule_entity.dart';
import '../../feature/ddayFeature/domain/entities/dday_entity.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
    playSound: false,
      showBadge: false,
      enableVibration: false
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();



  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: false,
      notificationChannelId: channel.id,
      initialNotificationTitle: 'MakeMyDay',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  Timer? timer;
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.low,
    playSound: false,
      showBadge: false,
      enableVibration: false
  );

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('mipmap/ic_launcher'),
    ),
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  final config = Configuration.local([ScheduleEntity.schema, DdayEntity.schema]);
  final realm = Realm(config);

  List<ScheduleEntity> todaySchedules = [];
  List<DdayEntity> ddays = [];

  // 데이터베이스 변경 감지를 위한 스트림 구독
  realm.all<ScheduleEntity>().changes.listen((changes) {
    _updateData(realm, todaySchedules, ddays);
    _updateNotifications(service, todaySchedules, ddays, flutterLocalNotificationsPlugin, realm, channel);
  });

  realm.all<DdayEntity>().changes.listen((changes) {
    _updateData(realm, todaySchedules, ddays);
    _updateNotifications(service, todaySchedules, ddays, flutterLocalNotificationsPlugin, realm, channel);
  });

  // 초기 데이터 로드
  _updateData(realm, todaySchedules, ddays);

  if (service is AndroidServiceInstance) {
    if (todaySchedules.isEmpty && ddays.isEmpty) {
      service.invoke('stopService');
    } else {
      _updateNotifications(
          service, todaySchedules, ddays, flutterLocalNotificationsPlugin,
          realm, channel);
    }
  }

  service.on('setAsForeground').listen((event) {
    if (service is AndroidServiceInstance) {
      if (todaySchedules.isEmpty && ddays.isEmpty) {
        service.invoke('stopService');
      } else {
        timer?.cancel();
        service.setAsForegroundService();
      }
    }
  });

  service.on('setAsBackground').listen((event) {
    if (service is AndroidServiceInstance) {
      if (todaySchedules.isEmpty && ddays.isEmpty) {
        service.invoke('stopService');
      } else {
        service.setAsBackgroundService();
        timer?.cancel();
        timer = Timer.periodic(const Duration(days: 1), (timer) async {
          _updateData(realm, todaySchedules, ddays);
          _updateNotifications(service, todaySchedules, ddays, flutterLocalNotificationsPlugin, realm, channel);
          print('Daily background service running');
          service.invoke('update');
        });
      }
    }
  });

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // 데이터 갱신 요청을 처리하는 메시지 핸들러
  service.on('updateData').listen((event) {
    _updateData(realm, todaySchedules, ddays);
    _updateNotifications(service, todaySchedules, ddays, flutterLocalNotificationsPlugin, realm, channel);
  });
}

void _updateData(Realm realm, List<ScheduleEntity> todaySchedules, List<DdayEntity> ddays) {
  todaySchedules.clear();
  todaySchedules.addAll(realm.all<ScheduleEntity>()
      .where((schedule) => schedule.date.day == DateTime.now().day)
      .toList());

  ddays.clear();
  ddays.addAll(realm.all<DdayEntity>().toList());
}

Future<void> _updateNotifications(
    ServiceInstance service,
    List<ScheduleEntity> todaySchedules,
    List<DdayEntity> ddays,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    Realm realm,
    AndroidNotificationChannel channel) async {

  // 오늘의 스케줄 알림 처리
  if (todaySchedules.isNotEmpty) {
    final timeFormat = DateFormat('a hh:mm', Intl.systemLocale);
    for (int i = 0; i < todaySchedules.length; i++) {
      final schedule = todaySchedules[i];
      final localTime = schedule.date.toLocal();
      final formattedTime = timeFormat.format(localTime);
      flutterLocalNotificationsPlugin.show(
        100 + i, // 고유한 ID를 사용합니다
        schedule.title,
        formattedTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              importance: Importance.low,
              priority: Priority.low,
              ongoing: true,
              playSound: false,
              channelShowBadge: false
          ),
        ),
      );
    }
  }

  // 디데이 알림 처리
  if (ddays.isNotEmpty) {
    final timeFormat = DateFormat('yyyy-MM-dd', Intl.systemLocale);
    for (int i = 0; i < ddays.length; i++) {
      final d = ddays[i];
      final localTime = d.date.toLocal();
      final formattedTime = timeFormat.format(localTime);
      final now = DateTime.now();
      var differenceInDays = d.date.difference(DateTime(now.year, now.month, now.day)).inDays;

      if (d.dayPlus) {
        differenceInDays = differenceInDays - 1;
      }

      String ddayText;
      if (differenceInDays == 0) {
        ddayText = "D-day";
      } else if (differenceInDays > 0) {
        ddayText = "D-${differenceInDays.abs()}";
      } else {
        ddayText = "D+${differenceInDays.abs()}";
      }

      flutterLocalNotificationsPlugin.show(
        200 + i,
        d.title,
        "$ddayText \n${formattedTime}",
        NotificationDetails(
            android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                importance: Importance.low,
                priority: Priority.low,
                ongoing: true,
                playSound: false,
                channelShowBadge: false
            )
        ),
      );
    }
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}