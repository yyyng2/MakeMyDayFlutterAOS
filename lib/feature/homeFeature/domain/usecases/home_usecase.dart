import 'dart:io';

import '../entities/home_realm_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../ddayFeature/domain/repositories/dday_repository.dart';
import '../../../scheduleFeature/domain/repositories/schedule_repository.dart';

class HomeUsecase {
  final HomeRepository homeRepository;
  final DdayRepository ddayRepository;
  final ScheduleRepository scheduleRepository;

  HomeUsecase({
    required this.homeRepository,
    required this.ddayRepository,
    required this.scheduleRepository
  });

  Future<HomeRealmEntity> fetchHomeItems(DateTime date) async {
    final ddayItems = await ddayRepository.fetchDdayItems();
    final scheduleItems = await scheduleRepository.fetchScheduleItemsByDay(date);
    return HomeRealmEntity(ddayItems: ddayItems, scheduleItems: scheduleItems);
  }

  Future<String> fetchNickname() async {
    return homeRepository.getNickname();
  }

  Future<Map<String, dynamic>> fetchProfileImage() async {
    return homeRepository.getProfileImage();
  }
}