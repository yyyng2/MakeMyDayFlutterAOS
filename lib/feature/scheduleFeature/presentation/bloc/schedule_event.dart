part of 'schedule_bloc.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class FetchScheduleItems extends ScheduleEvent {
  final DateTime month;

  const FetchScheduleItems(this.month);

  @override
  List<Object?> get props => [month];
}

class FetchScheduleItemsByDate extends ScheduleEvent {
  final DateTime date;

  const FetchScheduleItemsByDate(this.date);

  @override
  List<Object?> get props => [date];
}

class AddScheduleItem extends ScheduleEvent {
  final ScheduleEntity item;
  final DateTime month;

  const AddScheduleItem(this.item, this.month);

  @override
  List<Object?> get props => [item, month];
}

class UpdateScheduleItem extends ScheduleEvent {
  final ObjectId id;
  final ScheduleEntity item;
  final DateTime month;

  const UpdateScheduleItem(this.id, this.item, this.month);

  @override
  List<Object?> get props => [id, item, month];
}

class DeleteScheduleItem extends ScheduleEvent {
  final ObjectId id;
  final DateTime month;

  const DeleteScheduleItem(this.id, this.month);

  @override
  List<Object?> get props => [id, month];
}