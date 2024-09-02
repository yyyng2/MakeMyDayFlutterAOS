import 'package:realm/realm.dart';

part 'dday_entity.realm.dart';

@RealmModel()
class _DdayEntity {
  @PrimaryKey()
  late final ObjectId id;

  late String title;
  late DateTime date;
  late bool dayPlus;
}