import '../../../ddayFeature/domain/entities/dday_entity.dart';
import '../../../scheduleFeature/domain/entities/schedule_entity.dart';

class HomeRealmEntity {
  final List<DdayEntity> ddayItems;
  final List<ScheduleEntity> scheduleItems;

  HomeRealmEntity({required this.ddayItems, required this.scheduleItems});
}