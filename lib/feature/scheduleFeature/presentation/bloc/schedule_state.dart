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
  final bool isDarkTheme;
  final bool isWeekMode;
  final List<ScheduleEntity> searchResults;
  final bool isSearchVisible;

  const ScheduleLoaded(
      this.scheduleItems,
      this.scheduleTargetItems,
      this.isDarkTheme,
      {
        this.isWeekMode = false,
        this.searchResults = const [],
        this.isSearchVisible = false,
      }
      );


  @override
  List<Object?> get props => [
    scheduleItems,
    scheduleTargetItems,
    isDarkTheme,
    isWeekMode,
    searchResults,
    isSearchVisible
  ];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}