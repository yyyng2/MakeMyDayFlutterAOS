import 'package:realm/realm.dart';

import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final Realm database;

  ScheduleRepositoryImpl(this.database);

  // @override
  // Future<List<ScheduleEntity>> fetchScheduleItems() async {
  //   final results = database.query<ScheduleEntity>(
  //     'TRUEPREDICATE SORT (date DESC)');
  //   return results.toList();
  // }

  @override
  Future<List<ScheduleEntity>> fetchScheduleItems(DateTime month) async {
    // final startOfMonth = DateTime.utc(month.year, month.month, 1);

    final endOfMonth = DateTime.utc(month.year, month.month + 1, 0, 23, 59, 59);
    final startOfMonth = DateTime(endOfMonth.year, endOfMonth.month - 1, endOfMonth.day, 15, 0, 0);

    final test = database.query<ScheduleEntity>(
        'TRUEPREDICATE SORT (date ASC)');

    print(test.toList().first.date);

    // print('startOfMonth: $startOfMonth\nendOfMonth: $endOfMonth');
    final results = database.query<ScheduleEntity>(
      'date BETWEEN {\$0, \$1} SORT(date ASC)',
      [startOfMonth, endOfMonth],
    );
    return results.toList();
  }

  @override
  Future<List<ScheduleEntity>> fetchScheduleItemsByDate(DateTime selectedDate) async {
    final startOfDay = DateTime(selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    ).toUtc();

    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));

    // print('selectedDate: $selectedDate\nstartOfDay: $startOfDay\nendOfDay: $endOfDay');
    final results = database.query<ScheduleEntity>(
      'date BETWEEN {\$0, \$1} SORT (date ASC)',
      [startOfDay, endOfDay],
    );
    return results.toList();
  }

  @override
  Future<void> addScheduleItem(ScheduleEntity item) async {
    database.write(() {
      database.add(item);
    });
  }

  @override
  Future<void> updateScheduleItem(ObjectId id, ScheduleEntity item) async {
    final existingItem = database.find<ScheduleEntity>(id);
    if (existingItem != null) {
      database.write(() {
        existingItem.title = item.title;
        existingItem.content = item.content;
        existingItem.date = item.date;
      });
    }
  }

  @override
  Future<void> deleteScheduleItem(ObjectId id) async {
    final item = database.find<ScheduleEntity>(id);
    if (item != null) {
      database.write(() {
        database.delete(item);
      });
    }
  }
}