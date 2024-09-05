import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:make_my_day/feature/commonFeature/domain/usecases/common_usecase.dart';

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
  }

  Future<void> _onFetchNickname(
      FetchSettingsItems event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final nickname = await usecase.fetchNickname();
      final existUpdate = await commonUsecase.checkUpdate() ?? false;
      emit(SettingsLoaded(nickname, existUpdate));
    } catch (e) {
      emit(const SettingsError("Failed to load settings items"));
    }
  }

  Future<void> _setNickname(
      SetNickname event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      await usecase.setNickname(event.nickname);
      final nickname = await usecase.fetchNickname();
      final existUpdate = await commonUsecase.checkUpdate() ?? false;
      emit(SettingsLoaded(nickname, existUpdate));
    } catch (e) {
      emit(const SettingsError("Failed to load settings items"));
    }
  }
}