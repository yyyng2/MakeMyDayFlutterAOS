import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:make_my_day/feature/commonFeature/domain/usecases/common_usecase.dart';
import 'package:make_my_day/feature/mainTabFeature/presentation/bloc/main_tab_bloc.dart';

import '../../domain/usecases/settings_usecase.dart';

part 'settings_state.dart';
part 'settings_event.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsUsecase usecase;
  final CommonUsecase commonUsecase;

  SettingsBloc({required this.usecase, required this.commonUsecase}) : super(SettingsInitial()) {
    on<FetchSettingsItems>(_onFetchNickname);
    on<SetNickname>(_setNickname);
    on<GoToStoreEvent>((event, emit) async {
      await commonUsecase.openPlayStore();
    });
    on<ChangeThemeEvent>(_changeTheme);
  }

  Future<void> _onFetchNickname(
      FetchSettingsItems event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final nickname = await usecase.fetchNickname();
      final existUpdate = await commonUsecase.checkUpdate() ?? false;
      final isDarkTheme = await usecase.getTheme();
      emit(SettingsLoaded(
          nickname: nickname,
          existUpdate: existUpdate,
          isDarkTheme: isDarkTheme ?? false,
      ));
    } catch (e) {
      emit(const SettingsError(message: "Failed to load settings items"));
    }
  }

  Future<void> _setNickname(
      SetNickname event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      await usecase.setNickname(event.nickname);
      final nickname = await usecase.fetchNickname();
      final existUpdate = await commonUsecase.checkUpdate() ?? false;
      final isDarkTheme = await usecase.getTheme();
      emit(SettingsLoaded(
          nickname: nickname,
          existUpdate: existUpdate,
          isDarkTheme: isDarkTheme ?? false,
      ));
    } catch (e) {
      emit(const SettingsError(message: "Failed to load settings items"));
    }
  }

  Future<void> _changeTheme(ChangeThemeEvent event, Emitter<SettingsState> emit) async {
    try {
      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        final newTheme = event.isDarkTheme;
        await usecase.setTheme(newTheme);
        emit(
          SettingsLoaded(
            nickname: currentState.nickname,
            existUpdate: currentState.existUpdate,
            isDarkTheme: newTheme,
          ),
        );
      }
    } catch (e) {
      emit(const SettingsError(message: "Failed to change theme"));
    }
  }

  Future<void> changeTheme(bool isDarkTheme, MainTabBloc mainTabBloc) async {
    try {
      final nickname = await usecase.fetchNickname();
      final existUpdate = await commonUsecase.checkUpdate() ?? false;
      final newTheme = isDarkTheme;
      await usecase.setTheme(newTheme);
      mainTabBloc.add(LoadThemeEvent());
      emit(
        SettingsLoaded(
          nickname: nickname,
          existUpdate: existUpdate,
          isDarkTheme: newTheme,
        ),
      );
    } catch (e) {
      emit(const SettingsError(message: "Failed to change theme"));
    }
  }
}