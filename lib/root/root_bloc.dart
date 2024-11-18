import 'dart:async';
import 'dart:convert';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/locale_keys.g.dart';
import '../types/config.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/files.dart';
import '../utils/json.dart';

class RootBloc extends Bloc<RootEvent, RootState> {
  final configPath = RaffleFile.config.getFilePath();

  MapEntry<String, Brightness> get theme {
    final currentState = state;
    final filter = (currentState is RootSuccess ? currentState.config.theme : null) ?? LocaleKeys.uiDark;
    return kThemes.entries.firstWhere((element) => element.key == filter);
  }

  Size get size {
    final currentState = state;
    if (currentState is RootSuccess) {
      return Size(currentState.config.width, currentState.config.height);
    } else {
      return kDefaultSize;
    }
  }

  RootBloc() : super(RootInitial()) {
    on<LoadRoot>(_load, transformer: droppable());
    on<SetSize>(_setSize, transformer: restartable());
    on<SetTheme>(_setTheme);
    on<SetLocale>(_setLocale);
  }

  Future<void> _load(LoadRoot event, emit) async {
    final content = await loadFileAsString(configPath);
    final json = jsonDecode(content);
    final config = Config.fromJson(json);
    emit(RootSuccess(config));
  }

  Future<void> _setSize(SetSize event, emit) async {
    final currentState = state;
    if (currentState is RootSuccess) {
      final config = currentState.config.copyWith(size: event.size);
      await _persistConfig(config);
    }
  }

  Future<void> _setTheme(SetTheme event, emit) async {
    final currentState = state;
    if (currentState is RootSuccess) {
      final theme = kThemes.entries.firstWhere((element) => element.key.tr() == event.theme);
      final config = currentState.config.copyWith(theme: theme.key);
      await _persistConfig(config);
      emit(RootSuccess(config));
    }
  }

  Future<void> _setLocale(SetLocale event, emit) async {
    final currentState = state;
    if (currentState is RootSuccess) {
      final config = currentState.config.copyWith();
      emit(RootSuccess(config));
    }
  }

  Future<void> _persistConfig(Config config) async {
    await saveData(configPath, config);
  }
}

abstract class RootEvent {}

class LoadRoot extends RootEvent {}

class SetSize extends RootEvent {
  final Size size;

  SetSize(this.size);
}

class SetTheme extends RootEvent {
  final String theme;

  SetTheme(this.theme);
}

class SetLocale extends RootEvent {
  SetLocale();
}

abstract class RootState {}

class RootInitial extends RootState {}

class RootSuccess extends RootState {
  final Config config;

  RootSuccess(this.config);
}
