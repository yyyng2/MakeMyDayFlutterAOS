part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HomeRealmEntity homeItems;
  final String nickname;
  final Map<String, dynamic> profileImage;
  final bool isDarkTheme;

  const HomeLoaded(
      this.homeItems,
      this.nickname,
      this.profileImage,
      this.isDarkTheme
      );

  @override
  List<Object?> get props => [homeItems, nickname, profileImage, isDarkTheme];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}