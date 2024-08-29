part of 'splash_bloc.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashLoaded extends SplashState {
  final bool existUpdate;

  const SplashLoaded({required this.existUpdate});

  @override
  List<Object> get props => [existUpdate];
}

class SplashError extends SplashState {
  final String errorMessage;

  const SplashError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}