import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:make_my_day/infrastructure/manager/realm_schema_version_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:realm/realm.dart';

import 'feature/commonFeature/presentation/navigation/app_router.dart';
import 'feature/ddayFeature/domain/entities/dday_entity.dart';
import 'feature/scheduleFeature/domain/entities/schedule_entity.dart';
import 'firebase_options.dart';
import 'infrastructure/service/background_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting();
  await EasyLocalization.ensureInitialized();
  await MobileAds.instance.initialize();

  final config = RealmSchemaVersionManager.getConfig();
  final realm = Realm(config);

  runApp(
      EasyLocalization(
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ko', 'KR')
          ],
          fallbackLocale: const Locale('en', 'US'),
          path: 'assets/localizations',
          child: MyApp(realm: realm)
      )
  );
}

class MyApp extends StatefulWidget {
  final Realm realm;

  const MyApp({super.key, required this.realm});

  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("addPostFrameCallback");
      askPermission();
    });
  }

  Future<void> askPermission() async {
    if (await Permission.notification.request().isGranted) {
      await initializeBackgroundService();
    } else {
      await Permission.notification.request();
      print('Notification permission denied');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(WidgetsBinding.instance.window.defaultRouteName);
    print('uri: $uri');
    if (uri.toString().contains('MakeMyDayAppWidget')) {
      final widgetId = uri.pathSegments.last;
      return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: (settings) {
          return AppRouter.generateRoute(RouteSettings(
            name: AppRouter.ddaySelection,
            arguments: {'widgetId': widgetId},
          ));
        },
        initialRoute: AppRouter.ddaySelection,
      );
    } else {
      return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.splash,
      );
    }
  }
}