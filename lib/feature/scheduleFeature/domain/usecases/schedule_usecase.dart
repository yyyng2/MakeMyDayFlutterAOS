import 'package:realm/realm.dart';

import '../entities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

class ScheduleUsecase {
  final ScheduleRepository repository;

  ScheduleUsecase({required this.repository});

  Future<List<ScheduleEntity>> fetchScheduleItems(DateTime month) async {
    return await repository.fetchScheduleItems(month);
  }

  Future<List<ScheduleEntity>> fetchScheduleItemsByDate(DateTime selectedDate) async {
    return await repository.fetchScheduleItemsByDate(selectedDate);
  }

  Future<void> addScheduleItem(ScheduleEntity item, DateTime month) async {
    await repository.addScheduleItem(item);
    fetchScheduleItems(month);
  }

  Future<void> updateScheduleItem(ObjectId id, ScheduleEntity item, DateTime month) async {
    await repository.updateScheduleItem(id, item);
    fetchScheduleItems(month);
  }

  Future<void> deleteScheduleItem(ObjectId id, DateTime month) async {
    await repository.deleteScheduleItem(id);
    fetchScheduleItems(month);
  }
}
