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
  final String currentVersion;

  @override
  const SettingsLoaded({
    required this.nickname,
    required this.existUpdate,
    required this.isDarkTheme,
    required this.currentVersion
  });

  @override
  List<Object?> get props => [nickname, existUpdate, isDarkTheme, currentVersion];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}