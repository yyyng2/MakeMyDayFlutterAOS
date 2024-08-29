import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/main_tab_usecase.dart';

part 'main_tab_event.dart';
part 'main_tab_state.dart';

class MainTabBloc extends Bloc<MainTabEvent, MainTabState> {
  final MainTabUsecase _mainTabUsecase;

  MainTabBloc(this._mainTabUsecase) : super(MainTabInitial()) {
    on<LoadMainTabThemeEvent>((event, emit) async {
      emit(MainTabLoading()); // Emit loading state
      try {
        final isDarkMode = await _mainTabUsecase.call();
        emit(MainTabLoaded(isDarkMode: isDarkMode ?? false)); // Emit loaded state
      } catch (e) {
        emit(MainTabError(errorMessage: e.toString())); // Emit error state
      }
    });

    on<ToggleMainTabThemeEvent>((event, emit) async {
      try {
        final newTheme = !(state as MainTabLoaded).isDarkMode;
        await _mainTabUsecase.setTheme(newTheme);
        emit(MainTabLoaded(isDarkMode: newTheme)); // Emit updated theme state
      } catch (e) {
        emit(MainTabError(errorMessage: e.toString())); // Emit error state
      }
    });

    add(LoadMainTabThemeEvent()); // Automatically load theme on Bloc initialization
  }
}