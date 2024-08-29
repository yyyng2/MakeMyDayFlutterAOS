import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/splash_usecase.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SplashUsecase usecase;

  SplashBloc({required this.usecase}) : super(SplashInitial()) {
    on<CheckVersionEvent>((event, emit) async {
      emit(SplashLoading());
      try {
        final existUpdate = await usecase.call();
        if (existUpdate != null) {
          emit(SplashLoaded(existUpdate: existUpdate));
        } else {
          emit(SplashError(errorMessage: 'existUpdate is null'));
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