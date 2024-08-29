import 'package:realm/realm.dart';

import '../entities/schedule_entity.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleEntity>> fetchScheduleItems(DateTime month);
  Future<List<ScheduleEntity>> fetchScheduleItemsByDate(DateTime selectedDate);
  Future<void> addScheduleItem(ScheduleEntity item);
  Future<void> updateScheduleItem(ObjectId id, ScheduleEntity item);
  Future<void> deleteScheduleItem(ObjectId id);
}