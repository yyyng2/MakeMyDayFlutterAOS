part of 'main_tab_bloc.dart';

abstract class MainTabEvent {
  const MainTabEvent();

  List<Object?> get props => [];
}

class LoadThemeEvent extends MainTabEvent {}