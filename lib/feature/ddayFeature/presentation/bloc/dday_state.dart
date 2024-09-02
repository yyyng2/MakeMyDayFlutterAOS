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

  const DdayLoaded(this.ddayItems);

  @override
  List<Object?> get props => [ddayItems];
}

class DdayError extends DdayState {
  final String message;

  const DdayError(this.message);

  @override
  List<Object?> get props => [message];
}