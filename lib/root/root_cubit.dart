import 'dart:async';
import 'dart:convert';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../types/config.dart';
import '../utils/files.dart';
import '../utils/json.dart';

class RootCubit extends Bloc<RootEvent, RootState> {
  final configPath = RaffleFile.config.getFilePath();

  RootCubit() : super(RootInitial()) {
    on<LoadRoot>(_load, transformer: droppable());
    on<PersistRoot>(_persist);
  }

  Future<void> _load(LoadRoot event, emit) async {
    final content = await loadFileAsString(configPath);
    final json = jsonDecode(content);
    final config = Config.fromJson(json);
    emit(RootSuccess(config.width, config.height));
  }

  Future<void> _persist(PersistRoot event, emit) async {
    if (state is RootSuccess) {
      await saveData(configPath, event.size.toConfig());
    }
  }
}

abstract class RootEvent {}

class LoadRoot extends RootEvent {}

class PersistRoot extends RootEvent {
  final Size size;

  PersistRoot(this.size);
}

abstract class RootState {}

class RootInitial extends RootState {}

class RootSuccess extends RootState {
  final double width;
  final double height;

  RootSuccess(this.width, this.height);

  Size get size => Size(width, height);
}
