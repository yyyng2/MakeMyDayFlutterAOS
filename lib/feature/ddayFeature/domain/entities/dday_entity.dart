import 'package:realm/realm.dart';

part 'dday_entity.realm.dart';

@RealmModel()
class _DdayEntity {
  @PrimaryKey()
  late final ObjectId id;

  late String title;
  late DateTime date;
  //-----schema 2
  late bool repeatAnniversary;
  late int notificationType;
  //schema 2-----
  late bool dayPlus;
}