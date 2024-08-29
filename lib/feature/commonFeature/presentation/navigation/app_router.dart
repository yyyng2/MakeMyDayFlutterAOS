import 'package:flutter/material.dart';
import 'package:make_my_day/feature/scheduleFeature/domain/entities/schedule_entity.dart';
import 'package:realm/realm.dart';

import '../../../mainTabFeature/presentation/main_tab_screen.dart';
import '../../../scheduleFeature/presentation/bloc/schedule_bloc.dart';
import '../../../scheduleFeature/presentation/schedule_write_screen.dart';
import '../../../splashFeature/presentation/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String mainTab = '/mainTab';
  static const String scheduleWrite = '/scheduleWrite';

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