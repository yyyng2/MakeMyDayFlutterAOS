part of 'schedule_bloc.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<ScheduleEntity> scheduleItems;
  final List<ScheduleEntity> scheduleTargetItems;

  const ScheduleLoaded(this.scheduleItems, this.scheduleTargetItems);

  @override
  List<Object?> get props => [scheduleItems, scheduleTargetItems];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}