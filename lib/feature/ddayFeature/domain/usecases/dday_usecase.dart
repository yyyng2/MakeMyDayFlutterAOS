import 'package:realm/realm.dart';

import '../entities/dday_entity.dart';
import '../repositories/dday_repository.dart';

class DdayUsecase {
  final DdayRepository repository;

  DdayUsecase({required this.repository});

  Future<List<DdayEntity>> fetchDdayItems() async {
    return await repository.fetchDdayItems();
  }

  Future<void> addDdayItem(DdayEntity item) async {
    await repository.addDdayItem(item);
  }

  Future<void> updateDdayItem(ObjectId id, DdayEntity item) async {
    await repository.updateDdayItem(id, item);
  }

  Future<void> deleteDdayItem(ObjectId id) async {
    await repository.deleteDdayItem(id);
  }
}
