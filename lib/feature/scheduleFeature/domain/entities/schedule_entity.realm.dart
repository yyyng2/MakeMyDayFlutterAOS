// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_entity.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class ScheduleEntity extends _ScheduleEntity
    with RealmEntity, RealmObjectBase, RealmObject {
  ScheduleEntity(
    ObjectId id,
    String title,
    DateTime date, {
    String? content,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'content', content);
    RealmObjectBase.set(this, 'date', date);
  }

  ScheduleEntity._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => throw RealmUnsupportedSetError();

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  String? get content =>
      RealmObjectBase.get<String>(this, 'content') as String?;
  @override
  set content(String? value) => RealmObjectBase.set(this, 'content', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  Stream<RealmObjectChanges<ScheduleEntity>> get changes =>
      RealmObjectBase.getChanges<ScheduleEntity>(this);

  @override
  Stream<RealmObjectChanges<ScheduleEntity>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ScheduleEntity>(this, keyPaths);

  @override
  ScheduleEntity freeze() => RealmObjectBase.freezeObject<ScheduleEntity>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'title': title.toEJson(),
      'content': content.toEJson(),
      'date': date.toEJson(),
    };
  }

  static EJsonValue _toEJson(ScheduleEntity value) => value.toEJson();
  static ScheduleEntity _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'title': EJsonValue title,
        'date': EJsonValue date,
      } =>
        ScheduleEntity(
          fromEJson(id),
          fromEJson(title),
          fromEJson(date),
          content: fromEJson(ejson['content']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ScheduleEntity._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ScheduleEntity, 'ScheduleEntity', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('content', RealmPropertyType.string, optional: true),
      SchemaProperty('date', RealmPropertyType.timestamp),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
