import 'package:realm/realm.dart';

import '../entities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

class ScheduleUsecase {
  final ScheduleRepository repository;

  ScheduleUsecase({required this.repository});

  Future<List<ScheduleEntity>> fetchScheduleItems(DateTime month) async {
    return await repository.fetchScheduleItemsByMonth(month);
  }

  Future<List<ScheduleEntity>> fetchScheduleItemsByDate(DateTime selectedDate) async {
    return await repository.fetchScheduleItemsByDay(selectedDate);
  }

  Future<void> addScheduleItem(ScheduleEntity item) async {
    await repository.addScheduleItem(item);
  }

  Future<void> updateScheduleItem(ObjectId id, ScheduleEntity item) async {
    await repository.updateScheduleItem(id, item);
  }

  Future<void> deleteScheduleItem(ObjectId id) async {
    await repository.deleteScheduleItem(id);
  }
}
