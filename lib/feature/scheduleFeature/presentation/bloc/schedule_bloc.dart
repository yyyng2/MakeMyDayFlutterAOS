import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realm/realm.dart';
import 'package:equatable/equatable.dart';

import '../../../commonFeature/domain/usecases/common_usecase.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/usecases/schedule_usecase.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final CommonUsecase commonUsecase;
  final ScheduleUsecase usecase;

  ScheduleBloc({required this.commonUsecase, required this.usecase}) : super(ScheduleInitial()) {
    on<FetchScheduleItemsByDate>(_onFetchScheduleItemsByDate);
    on<AddScheduleItem>(_onAddScheduleItem);
    on<UpdateScheduleItem>(_onUpdateScheduleItem);
    on<DeleteScheduleItem>(_onDeleteScheduleItem);
    on<ToggleCalendarMode>(_onToggleCalendarMode); // 추가
    on<SearchScheduleItems>(_onSearchScheduleItems); // 추가
    on<ToggleSearchPopup>(_onToggleSearchPopup); // 추가
  }

  Future<void> _onFetchScheduleItemsByDate(
      FetchScheduleItemsByDate event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoading());
    try {
      final items = await usecase.fetchScheduleItems(event.date);
      final targetItems = await usecase.fetchScheduleItemsByDate(event.date);
      final isDarkTheme = await commonUsecase.getTheme();

      final currentState = state;
      final isWeekMode = currentState is ScheduleLoaded ? currentState.isWeekMode : false;
      final searchResults = currentState is ScheduleLoaded ? currentState.searchResults : <ScheduleEntity>[];
      final isSearchVisible = currentState is ScheduleLoaded ? currentState.isSearchVisible : false;

      emit(ScheduleLoaded(items, targetItems, isDarkTheme,
          isWeekMode: isWeekMode,
          searchResults: searchResults,
          isSearchVisible: isSearchVisible));
    } catch (e) {
      print('error fetchScheduleItemsByDate: $e');
      emit(const ScheduleError("Failed to load schedule items"));
    }
  }

  Future<void> _onAddScheduleItem(
      AddScheduleItem event, Emitter<ScheduleState> emit) async {
    try {
      await usecase.addScheduleItem(event.item);
      FlutterBackgroundService().invoke('updateData');
      add(FetchScheduleItemsByDate(event.month));
    } catch (e) {
      emit(const ScheduleError("Failed to add schedule item"));
    }
  }

  Future<void> _onUpdateScheduleItem(
      UpdateScheduleItem event, Emitter<ScheduleState> emit) async {
    try {
      await usecase.updateScheduleItem(event.id, event.item);
      FlutterBackgroundService().invoke('updateData');
      add(FetchScheduleItemsByDate(event.month));
    } catch (e) {
      emit(const ScheduleError("Failed to update schedule item"));
    }
  }

  Future<void> _onDeleteScheduleItem(
      DeleteScheduleItem event, Emitter<ScheduleState> emit) async {
    try {
      await usecase.deleteScheduleItem(event.id);
      FlutterBackgroundService().invoke('updateData');
      add(FetchScheduleItemsByDate(event.month));
    } catch (e) {
      emit(const ScheduleError("Failed to delete schedule item"));
    }
  }

  Future<void> _onToggleCalendarMode(
      ToggleCalendarMode event, Emitter<ScheduleState> emit) async {
    if (state is ScheduleLoaded) {
      final currentState = state as ScheduleLoaded;
      emit(ScheduleLoaded(
        currentState.scheduleItems,
        currentState.scheduleTargetItems,
        currentState.isDarkTheme,
        isWeekMode: !currentState.isWeekMode,
        searchResults: currentState.searchResults,
        isSearchVisible: currentState.isSearchVisible,
      ));
    }
  }

  Future<void> _onSearchScheduleItems(
      SearchScheduleItems event, Emitter<ScheduleState> emit) async {
    if (state is ScheduleLoaded) {
      final currentState = state as ScheduleLoaded;
      if (event.query.isEmpty) {
        emit(ScheduleLoaded(
          currentState.scheduleItems,
          currentState.scheduleTargetItems,
          currentState.isDarkTheme,
          isWeekMode: currentState.isWeekMode,
          searchResults: [],
          isSearchVisible: currentState.isSearchVisible,
        ));
      } else {
        final results = currentState.scheduleItems
            .where((item) => item.title.toLowerCase().contains(event.query.toLowerCase()))
            .toList();
        emit(ScheduleLoaded(
          currentState.scheduleItems,
          currentState.scheduleTargetItems,
          currentState.isDarkTheme,
          isWeekMode: currentState.isWeekMode,
          searchResults: results,
          isSearchVisible: currentState.isSearchVisible,
        ));
      }
    }
  }

  Future<void> _onToggleSearchPopup(
      ToggleSearchPopup event, Emitter<ScheduleState> emit) async {
    if (state is ScheduleLoaded) {
      final currentState = state as ScheduleLoaded;
      emit(ScheduleLoaded(
        currentState.scheduleItems,
        currentState.scheduleTargetItems,
        currentState.isDarkTheme,
        isWeekMode: currentState.isWeekMode,
        searchResults: event.isVisible ? currentState.searchResults : [],
        isSearchVisible: event.isVisible,
      ));
    }
  }
}