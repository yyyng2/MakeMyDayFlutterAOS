part of 'dday_bloc.dart';

abstract class DdayState extends Equatable {
  const DdayState();

  @override
  List<Object?> get props => [];
}

class DdayInitial extends DdayState {}

class DdayLoading extends DdayState {}

class DdayLoaded extends DdayState {
  final List<DdayEntity> ddayItems;
  final bool isDarkTheme;

  const DdayLoaded(this.ddayItems, this.isDarkTheme);

  @override
  List<Object?> get props => [ddayItems, isDarkTheme];
}

class DdayError extends DdayState {
  final String message;

  const DdayError(this.message);

  @override
  List<Object?> get props => [message];
}