part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final String nickname;
  final bool existUpdate;
  final bool isDarkTheme;

  @override
  const SettingsLoaded({
    required this.nickname,
    required this.existUpdate,
    required this.isDarkTheme,
  });

  @override
  List<Object?> get props => [nickname, existUpdate, isDarkTheme];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}