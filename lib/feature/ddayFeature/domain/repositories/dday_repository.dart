import 'package:realm/realm.dart';

import '../entities/dday_entity.dart';

abstract class DdayRepository {
  Future<List<DdayEntity>> fetchDdayItems();
  Future<void> addDdayItem(DdayEntity item);
  Future<void> updateDdayItem(ObjectId id, DdayEntity item);
  Future<void> deleteDdayItem(ObjectId id);
}