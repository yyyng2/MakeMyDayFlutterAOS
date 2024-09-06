part of 'main_tab_bloc.dart';

abstract class MainTabState extends Equatable {
  const MainTabState();

  @override
  List<Object> get props => [];
}

class MainTabInitial extends MainTabState {}

class MainTabLoading extends MainTabState {}

class MainTabLoaded extends MainTabState {
  final bool isDarkTheme;

  const MainTabLoaded({required this.isDarkTheme});

  @override
  List<Object> get props => [isDarkTheme];
}

class MainTabError extends MainTabState {
  final String errorMessage;

  const MainTabError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}