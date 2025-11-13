part of 'schedule_bloc.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
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

class ToggleCalendarMode extends ScheduleEvent {
  const ToggleCalendarMode();
}

class SearchScheduleItems extends ScheduleEvent {
  final String query;

  const SearchScheduleItems(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleSearchPopup extends ScheduleEvent {
  final bool isVisible;

  const ToggleSearchPopup(this.isVisible);

  @override
  List<Object?> get props => [isVisible];
}