import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'feature/commonFeature/presentation/navigation/app_router.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting();
  await EasyLocalization.ensureInitialized();
  await MobileAds.instance.initialize();

  runApp(
      EasyLocalization(
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ko', 'KR')
          ],
          fallbackLocale: const Locale('en', 'US'),
          path: 'assets/localizations',
          child: const MyApp()
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
