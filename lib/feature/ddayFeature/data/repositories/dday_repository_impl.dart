import 'package:realm/realm.dart';

import '../../domain/entities/dday_entity.dart';
import '../../domain/repositories/dday_repository.dart';

class DdayRepositoryImpl implements DdayRepository {
  final Realm database;

  DdayRepositoryImpl(this.database);

  // @override
  // Future<List<ScheduleEntity>> fetchScheduleItems() async {
  //   final results = database.query<ScheduleEntity>(
  //     'TRUEPREDICATE SORT (date DESC)');
  //   return results.toList();
  // }

  @override
  Future<List<DdayEntity>> fetchDdayItems() async {
    final results = database.query<DdayEntity>(
        'TRUEPREDICATE SORT (date ASC)');

    return results.toList();
  }

  @override
  Future<void> addDdayItem(DdayEntity item) async {
    database.write(() {
      database.add(item);
    });
  }

  @override
  Future<void> updateDdayItem(ObjectId id, DdayEntity item) async {
    final existingItem = database.find<DdayEntity>(id);
    if (existingItem != null) {
      database.write(() {
        existingItem.title = item.title;
        existingItem.date = item.date;
        existingItem.repeatAnniversary = item.repeatAnniversary;
        existingItem.notificationType = item.notificationType;
        existingItem.dayPlus = item.dayPlus;
      });
    }
  }

  @override
  Future<void> deleteDdayItem(ObjectId id) async {
    final item = database.find<DdayEntity>(id);
    if (item != null) {
      database.write(() {
        database.delete(item);
      });
    }
  }
}