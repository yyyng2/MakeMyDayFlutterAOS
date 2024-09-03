import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/settings_usecase.dart';

part 'settings_state.dart';
part 'settings_event.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsUsecase usecase;

  SettingsBloc(this.usecase) : super(SettingsInitial()) {
    on<FetchSettingsItems>(_onFetchNickname);
    on<SetNickname>(_setNickname);
  }

  Future<void> _onFetchNickname(
      FetchSettingsItems event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final nickname = await usecase.fetchNickname();
      emit(SettingsLoaded(nickname));
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
      emit(SettingsLoaded(nickname));
    } catch (e) {
      emit(const SettingsError("Failed to load settings items"));
    }
  }
}