import 'package:flutter/material.dart';
import 'package:make_my_day/feature/scheduleFeature/domain/entities/schedule_entity.dart';
import 'package:make_my_day/feature/settingsFeature/presentation/settings_app_info_screen.dart';

import '../../../ddayFeature/domain/entities/dday_entity.dart';
import '../../../ddayFeature/presentation/bloc/dday_bloc.dart';
import '../../../ddayFeature/presentation/dday_write_screen.dart';
import '../../../mainTabFeature/presentation/main_tab_screen.dart';
import '../../../scheduleFeature/presentation/bloc/schedule_bloc.dart';
import '../../../scheduleFeature/presentation/schedule_write_screen.dart';
import '../../../settingsFeature/presentation/bloc/settings_bloc.dart';
import '../../../settingsFeature/presentation/settings_edit_profile_screen.dart';
import '../../../splashFeature/presentation/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String mainTab = '/mainTab';
  static const String scheduleWrite = '/scheduleWrite';
  static const String ddayWrite = '/ddayWrite';
  static const String appInfo = '/appInfo';
  static const String editProfile = '/editProfile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
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

        return MaterialPageRoute(
          builder: (_) => ScheduleWriteScreen(
            isEdit: isEdit,
            scheduleEntity: scheduleEntity,
            scheduleBloc: scheduleBloc,
          ),
        );

      case AppRouter.ddayWrite:
        final args = settings.arguments as Map<String, dynamic>;
        final isEdit = args['isEdit'] as bool;
        final ddayEntity = args['ddayObject'] as DdayEntity?;
        final ddayBloc = args['ddayBloc'] as DdayBloc;

        return MaterialPageRoute(
          builder: (_) => DdayWriteScreen(
            isEdit: isEdit,
            ddayEntity: ddayEntity,
            ddayBloc: ddayBloc,
          ),
        );

      case AppRouter.appInfo:
        final args = settings.arguments as Map<String, dynamic>;
        final currentVersion = args['currentVersion'] as String;
        final currentAppstoreVersion = args['currentAppstoreVersion'] as String;

        return MaterialPageRoute(
          builder: (_) => SettingsAppInfoScreen(
            currentVersion: currentVersion,
            currentAppstoreVersion: currentAppstoreVersion,
          ),
        );

      case AppRouter.editProfile:
        final args = settings.arguments as Map<String, dynamic>;
        final nickname = args['nickname'] as String;
        final settingsBloc = args['settingsBloc'] as SettingsBloc;

        return MaterialPageRoute(builder: (_) => SettingsEditProfileScreen(
          nickname: nickname,
          settingsBloc: settingsBloc
        )
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
