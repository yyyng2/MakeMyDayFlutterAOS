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
  }

  Future<void> _onFetchScheduleItemsByDate(
      FetchScheduleItemsByDate event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoading());
    try {
      final items = await usecase.fetchScheduleItems(event.date);
      final targetItems = await usecase.fetchScheduleItemsByDate(event.date);
      final isDarkTheme = await commonUsecase.getTheme();
      emit(ScheduleLoaded(items, targetItems, isDarkTheme));
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
}