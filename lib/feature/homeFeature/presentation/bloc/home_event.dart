part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class FetchHomeItems extends HomeEvent {
  final DateTime date;

  const FetchHomeItems(this.date);

  @override
  List<Object?> get props => [date];
}

class TabChangedEvent extends HomeEvent {
  final int index;
  const TabChangedEvent(this.index);
}