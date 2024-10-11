import 'package:flutter/material.dart';
import 'package:make_my_day/feature/mainTabFeature/presentation/bloc/main_tab_bloc.dart';
import 'package:make_my_day/feature/scheduleFeature/domain/entities/schedule_entity.dart';
import 'package:make_my_day/feature/settingsFeature/presentation/settings_app_info_screen.dart';
import 'package:make_my_day/feature/settingsFeature/presentation/settings_theme_screen.dart';

import '../../../ddayFeature/domain/entities/dday_entity.dart';
import '../../../ddayFeature/presentation/bloc/dday_bloc.dart';
import '../../../ddayFeature/presentation/dday_write_screen.dart';
import '../../../mainTabFeature/presentation/main_tab_screen.dart';
import '../../../scheduleFeature/presentation/bloc/schedule_bloc.dart';
import '../../../scheduleFeature/presentation/schedule_write_screen.dart';
import '../../../settingsFeature/presentation/bloc/settings_bloc.dart';
import '../../../settingsFeature/presentation/settings_edit_profile_screen.dart';
import '../../../splashFeature/presentation/splash_screen.dart';
import '../../../ddaySelectionFeature/presentation/dday_selection_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String mainTab = '/mainTab';
  static const String scheduleWrite = '/scheduleWrite';
  static const String ddayWrite = '/ddayWrite';
  static const String appInfo = '/appInfo';
  static const String editProfile = '/editProfile';
  static const String theme = '/theme';
  static const String ddaySelection = '/ddaySelection';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final uri = Uri.parse(settings.name ?? '');
    // final routeName = uri.path;
    // final params = uri.queryParameters;
    // print('uri: $uri, $routeName, $params, ${settings.name}');
    if (settings.name.toString().contains('appWidgetId=')) {
      final widgetId = settings.name.toString().split('=').asMap()[1];
      return MaterialPageRoute(
        builder: (_) => DdaySelectionScreen(widgetId: widgetId ?? ''),
      );
    }
    switch (settings.name) {
      case AppRouter.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRouter.mainTab:
        return MaterialPageRoute(builder: (_) => const MainTabScreen());

      case AppRouter.scheduleWrite:
        final args = settings.arguments as Map<String, dynamic>;
        final isEdit = args['isEdit'] as bool;
        final scheduleEntity = args['scheduleObject'] as ScheduleEntity?;
        final scheduleBloc = args['scheduleBloc'] as ScheduleBloc;
        final isDarkTheme = args['isDarkTheme'] as bool;

        return MaterialPageRoute(
          builder: (_) => ScheduleWriteScreen(
            isEdit: isEdit,
            scheduleEntity: scheduleEntity,
            scheduleBloc: scheduleBloc,
            isDarkTheme: isDarkTheme,
          ),
        );

      case AppRouter.ddayWrite:
        final args = settings.arguments as Map<String, dynamic>;
        final isEdit = args['isEdit'] as bool;
        final ddayEntity = args['ddayObject'] as DdayEntity?;
        final ddayBloc = args['ddayBloc'] as DdayBloc;
        final isDarkTheme = args['isDarkTheme'] as bool;

        return MaterialPageRoute(
          builder: (_) => DdayWriteScreen(
            isEdit: isEdit,
            ddayEntity: ddayEntity,
            ddayBloc: ddayBloc,
            isDarkTheme: isDarkTheme,
          ),
        );

      case AppRouter.appInfo:
        final args = settings.arguments as Map<String, dynamic>;
        final currentVersion = args['currentVersion'] as String;
        final settingsBloc = args['settingsBloc'] as SettingsBloc;
        final existUpdate = args['existUpdate'] as bool;
        final isDarkTheme = args['isDarkTheme'] as bool;

        return MaterialPageRoute(
          builder: (_) => SettingsAppInfoScreen(
            currentVersion: currentVersion,
            settingsBloc: settingsBloc,
            existUpdate: existUpdate,
            isDarkTheme: isDarkTheme,
          ),
        );

      case AppRouter.editProfile:
        final args = settings.arguments as Map<String, dynamic>;
        final nickname = args['nickname'] as String;
        final settingsBloc = args['settingsBloc'] as SettingsBloc;
        final isDarkTheme = args['isDarkTheme'] as bool;

        return MaterialPageRoute(
            builder: (_) => SettingsEditProfileScreen(
                  nickname: nickname,
                  settingsBloc: settingsBloc,
                  isDarkTheme: isDarkTheme,
                ));

      case AppRouter.theme:
        final args = settings.arguments as Map<String, dynamic>;
        final isDarkTheme = args['isDarkTheme'] as bool;
        final settingsBloc = args['settingsBloc'] as SettingsBloc;
        final mainTabBloc = args['mainTabBloc'] as MainTabBloc;

        return MaterialPageRoute(
            builder: (_) => SettingsThemeScreen(
                  isDarkTheme: isDarkTheme,
                  settingsBloc: settingsBloc,
                  mainTabBloc: mainTabBloc,
                ));

      case AppRouter.ddaySelection:
        final args = settings.arguments as Map<String, dynamic>?;
        final widgetId = args?['widgetId'] as String?;
        return MaterialPageRoute(
          builder: (_) => DdaySelectionScreen(widgetId: widgetId ?? ''),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
