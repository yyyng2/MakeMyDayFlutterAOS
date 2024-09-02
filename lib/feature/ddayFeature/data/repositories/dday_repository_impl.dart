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
  Future<List<DdayEntity>> fetchDdayItemsByDate(DateTime selectedDate) async {
    final startOfDay = DateTime(selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    ).toUtc();

    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));

    print('selectedDate: $selectedDate\nstartOfDay: $startOfDay\nendOfDay: $endOfDay');
    final results = database.query<DdayEntity>(
      'date BETWEEN {\$0, \$1} SORT (date DESC)',
      [startOfDay, endOfDay],
    );
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