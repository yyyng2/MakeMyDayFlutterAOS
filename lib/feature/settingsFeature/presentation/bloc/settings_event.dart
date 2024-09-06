part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class FetchSettingsItems extends SettingsEvent {}

class SetNickname extends SettingsEvent {
  final String nickname;

  const SetNickname(this.nickname);

  @override
  List<Object?> get props => [nickname];
}

class GoToStoreEvent extends SettingsEvent {}

class ChangeThemeEvent extends SettingsEvent {
  final bool isDarkTheme;

  const ChangeThemeEvent(this.isDarkTheme);

  @override
  List<Object?> get props => [isDarkTheme];
}