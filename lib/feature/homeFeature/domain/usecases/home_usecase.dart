import '../entities/home_realm_entity.dart';
import '../../../ddayFeature/domain/repositories/dday_repository.dart';
import '../../../scheduleFeature/domain/repositories/schedule_repository.dart';

class HomeUsecase {
  final DdayRepository ddayRepository;
  final ScheduleRepository scheduleRepository;

  HomeUsecase({required this.ddayRepository, required this.scheduleRepository});

  Future<HomeRealmEntity> fetchHomeItems(DateTime date) async {
    final ddayItems = await ddayRepository.fetchDdayItems();
    final scheduleItems = await scheduleRepository.fetchScheduleItemsByDate(date);
    return HomeRealmEntity(ddayItems: ddayItems, scheduleItems: scheduleItems);
  }
}