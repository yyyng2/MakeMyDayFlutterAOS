// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dday_entity.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class DdayEntity extends _DdayEntity
    with RealmEntity, RealmObjectBase, RealmObject {
  DdayEntity(
    ObjectId id,
    String title,
    DateTime date,
    bool dayPlus,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'dayPlus', dayPlus);
  }

  DdayEntity._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => throw RealmUnsupportedSetError();

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  bool get dayPlus => RealmObjectBase.get<bool>(this, 'dayPlus') as bool;
  @override
  set dayPlus(bool value) => RealmObjectBase.set(this, 'dayPlus', value);

  @override
  Stream<RealmObjectChanges<DdayEntity>> get changes =>
      RealmObjectBase.getChanges<DdayEntity>(this);

  @override
  Stream<RealmObjectChanges<DdayEntity>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<DdayEntity>(this, keyPaths);

  @override
  DdayEntity freeze() => RealmObjectBase.freezeObject<DdayEntity>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'title': title.toEJson(),
      'date': date.toEJson(),
      'dayPlus': dayPlus.toEJson(),
    };
  }

  static EJsonValue _toEJson(DdayEntity value) => value.toEJson();
  static DdayEntity _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'title': EJsonValue title,
        'date': EJsonValue date,
        'dayPlus': EJsonValue dayPlus,
      } =>
        DdayEntity(
          fromEJson(id),
          fromEJson(title),
          fromEJson(date),
          fromEJson(dayPlus),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(DdayEntity._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, DdayEntity, 'DdayEntity', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('date', RealmPropertyType.timestamp),
      SchemaProperty('dayPlus', RealmPropertyType.bool),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
