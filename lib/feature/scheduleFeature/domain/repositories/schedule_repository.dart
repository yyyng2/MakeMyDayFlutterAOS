import 'package:realm/realm.dart';

import '../entities/schedule_entity.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleEntity>> fetchScheduleItemsByMonth(DateTime month);
  Future<List<ScheduleEntity>> fetchScheduleItemsByDay(DateTime selectedDate);
  Future<void> addScheduleItem(ScheduleEntity item);
  Future<void> updateScheduleItem(ObjectId id, ScheduleEntity item);
  Future<void> deleteScheduleItem(ObjectId id);
}