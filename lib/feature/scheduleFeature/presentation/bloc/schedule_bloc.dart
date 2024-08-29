import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:make_my_day/feature/scheduleFeature/domain/usecases/schedule_usecase.dart';
import 'package:realm/realm.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/schedule_entity.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleUsecase usecase;

  ScheduleBloc(this.usecase) : super(ScheduleInitial()) {
    on<FetchScheduleItems>(_onFetchScheduleItems);
    on<FetchScheduleItemsByDate>(_onFetchScheduleItemsByDate);
    on<AddScheduleItem>(_onAddScheduleItem);
    on<UpdateScheduleItem>(_onUpdateScheduleItem);
    on<DeleteScheduleItem>(_onDeleteScheduleItem);
  }

  Future<void> _onFetchScheduleItems(
      FetchScheduleItems event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoading());
    try {
      final items = await usecase.fetchScheduleItems(event.month);
      final targetItems = await usecase.fetchScheduleItemsByDate(event.month);
      emit(ScheduleLoaded(items, targetItems));
    } catch (e) {
      emit(const ScheduleError("Failed to load schedule items"));
    }
  }

  Future<void> _onFetchScheduleItemsByDate(
      FetchScheduleItemsByDate event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoading());
    try {
      final items = await usecase.fetchScheduleItems(event.date);
      final targetItems = await usecase.fetchScheduleItemsByDate(event.date);
      emit(ScheduleLoaded(items, targetItems));
    } catch (e) {
      emit(const ScheduleError("Failed to load schedule items"));
    }
  }

  Future<void> _onAddScheduleItem(
      AddScheduleItem event, Emitter<ScheduleState> emit) async {
    try {
      await usecase.addScheduleItem(event.item, event.month);
      add(FetchScheduleItems(event.month));
    } catch (e) {
      emit(const ScheduleError("Failed to add schedule item"));
    }
  }

  Future<void> _onUpdateScheduleItem(
      UpdateScheduleItem event, Emitter<ScheduleState> emit) async {
    try {
      await usecase.updateScheduleItem(event.id, event.item, event.month);
      add(FetchScheduleItems(event.month));
    } catch (e) {
      emit(const ScheduleError("Failed to update schedule item"));
    }
  }

  Future<void> _onDeleteScheduleItem(
      DeleteScheduleItem event, Emitter<ScheduleState> emit) async {
    try {
      await usecase.deleteScheduleItem(event.id, event.month);
      add(FetchScheduleItems(event.month)); // Refetch items after deleting
    } catch (e) {
      emit(const ScheduleError("Failed to delete schedule item"));
    }
  }
}