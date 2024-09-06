import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../commonFeature/domain/usecases/common_usecase.dart';

part 'main_tab_event.dart';
part 'main_tab_state.dart';

class MainTabBloc extends Bloc<MainTabEvent, MainTabState> {
  final CommonUsecase _commonUsecase;

  MainTabBloc(this._commonUsecase) : super(MainTabInitial()) {
    on<LoadThemeEvent>((event, emit) async {
      emit(MainTabLoading());
      try {
        final isDarkTheme = await _commonUsecase.getTheme();
        emit(MainTabLoaded(isDarkTheme: isDarkTheme));
      } catch (e) {
        emit(MainTabError(errorMessage: e.toString()));
      }
    });
  }
}