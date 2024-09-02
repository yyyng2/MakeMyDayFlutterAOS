part of 'dday_bloc.dart';

abstract class DdayEvent extends Equatable {
  const DdayEvent();

  @override
  List<Object?> get props => [];
}

class FetchDdayItems extends DdayEvent {}

class AddDdayItem extends DdayEvent {
  final DdayEntity item;

  const AddDdayItem(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateDdayItem extends DdayEvent {
  final ObjectId id;
  final DdayEntity item;

  const UpdateDdayItem(this.id, this.item);

  @override
  List<Object?> get props => [id, item];
}

class DeleteDdayItem extends DdayEvent {
  final ObjectId id;

  const DeleteDdayItem(this.id);

  @override
  List<Object?> get props => [id];
}