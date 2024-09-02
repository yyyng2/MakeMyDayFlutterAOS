import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realm/realm.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/dday_entity.dart';
import '../../domain/usecases/dday_usecase.dart';

part 'dday_event.dart';
part 'dday_state.dart';

class DdayBloc extends Bloc<DdayEvent, DdayState> {
  final DdayUsecase usecase;

  DdayBloc(this.usecase) : super(DdayInitial()) {
    on<FetchDdayItems>(_onFetchDdayItems);
    on<AddDdayItem>(_onAddDdayItem);
    on<UpdateDdayItem>(_onUpdateDdayItem);
    on<DeleteDdayItem>(_onDeleteDdayItem);
  }

  Future<void> _onFetchDdayItems(
      FetchDdayItems event, Emitter<DdayState> emit) async {
    emit(DdayLoading());
    try {
      final items = await usecase.fetchDdayItems();
      emit(DdayLoaded(items));
    } catch (e) {
      emit(const DdayError("Failed to load dday items"));
    }
  }

  Future<void> _onAddDdayItem(
      AddDdayItem event, Emitter<DdayState> emit) async {
    try {
      await usecase.addDdayItem(event.item);
      add(FetchDdayItems());
    } catch (e) {
      emit(const DdayError("Failed to add dday item"));
    }
  }

  Future<void> _onUpdateDdayItem(
      UpdateDdayItem event, Emitter<DdayState> emit) async {
    try {
      await usecase.updateDdayItem(event.id, event.item);
      add(FetchDdayItems());
    } catch (e) {
      emit(const DdayError("Failed to update dday item"));
    }
  }

  Future<void> _onDeleteDdayItem(
      DeleteDdayItem event, Emitter<DdayState> emit) async {
    try {
      await usecase.deleteDdayItem(event.id);
      add(FetchDdayItems());
    } catch (e) {
      emit(const DdayError("Failed to delete dday item"));
    }
  }
}