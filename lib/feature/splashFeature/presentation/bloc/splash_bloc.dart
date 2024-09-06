import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../commonFeature/domain/usecases/common_usecase.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final CommonUsecase usecase;

  SplashBloc({required this.usecase}) : super(SplashInitial()) {
    on<CheckVersionEvent>((event, emit) async {
      emit(SplashLoading());
      try {
        final existUpdate = await usecase.checkUpdate();
        if (existUpdate != null) {
          emit(SplashLoaded(existUpdate: existUpdate));
        } else {
          emit(const SplashError(errorMessage: 'existUpdate is null'));
        }
      } catch (e) {
        emit(SplashError(errorMessage: '$e'));
      }
    });

    on<GoToStoreEvent>((event, emit) async {
      await usecase.openPlayStore();
    });
  }
}