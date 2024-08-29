import 'package:realm/realm.dart';

part 'schedule_entity.realm.dart';

@RealmModel()
class _ScheduleEntity {
  @PrimaryKey()
  late final ObjectId id;

  late String title;
  String? content;
  late DateTime date;
}