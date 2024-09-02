import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/home_realm_entity.dart';
import '../../domain/usecases/home_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeUsecase usecase;

  HomeBloc(this.usecase) : super(HomeInitial()) {
    on<FetchHomeItems>(_onFetchHomeItems);
  }

  Future<void> _onFetchHomeItems(
      FetchHomeItems event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final items = await usecase.fetchHomeItems(event.date);
      emit(HomeLoaded(items));
    } catch (e) {
      emit(const HomeError("Failed to load home items"));
    }
  }
}