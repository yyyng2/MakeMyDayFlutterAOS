
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../commonFeature/domain/usecases/common_usecase.dart';
import '../../domain/entities/home_realm_entity.dart';
import '../../domain/usecases/home_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CommonUsecase commonUsecase;
  final HomeUsecase usecase;

  HomeBloc({required this.commonUsecase, required this.usecase}) : super(HomeInitial()) {
    on<FetchHomeItems>(_onFetchHomeItems);
  }

  Future<void> _onFetchHomeItems(
      FetchHomeItems event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final items = await usecase.fetchHomeItems(event.date);
      final nickname = await usecase.fetchNickname();
      final isDarkTheme = await commonUsecase.getTheme();
      final profileImage = await usecase.fetchProfileImage(isDarkTheme);

      emit(HomeLoaded(items, nickname, profileImage, isDarkTheme));
    } catch (e) {
      emit(const HomeError("Failed to load home items"));
    }
  }
}