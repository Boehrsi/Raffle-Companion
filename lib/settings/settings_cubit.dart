import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../types/mail_preset.dart';
import '../types/platform.dart';
import '../types/settings.dart';
import '../utils/files.dart';
import '../utils/json.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final mailPresetListFilePath = RaffleFile.mailPreset.getFilePath();
  final defaultMailPresetListFilePath = RaffleFile.mailPreset.getDefaultFilePath();
  final platformListFilePath = RaffleFile.platforms.getFilePath();
  final defaultPlatformListFilePath = RaffleFile.platforms.getDefaultFilePath();
  final settingsFilePath = RaffleFile.settings.getFilePath();

  SettingsSuccess get _settingsSuccess => state as SettingsSuccess;

  SettingsCubit() : super(SettingsInitial());

  Future<void> loadSettings() async {
    final mailPresetList = <MailPreset>[];
    final platformList = <Platform>[];

    final mailPresetListString = await loadFileAsString(mailPresetListFilePath);
    final List<dynamic> mailPresetListJson = jsonDecode(mailPresetListString);
    for (var mailPresetJson in mailPresetListJson) {
      mailPresetList.add(MailPreset.fromJson(mailPresetJson));
    }

    final platformListString = await loadFileAsString(platformListFilePath);
    final List<dynamic> platformListJson = jsonDecode(platformListString);
    for (var platformJson in platformListJson) {
      platformList.add(Platform.fromJson(platformJson));
    }

    final settingsString = await loadFileAsString(settingsFilePath);
    final settingsJson = jsonDecode(settingsString);
    final settings = Settings.fromJson(settingsJson);

    emit(SettingsSuccess(
      mailPresetList: mailPresetList,
      platformList: platformList,
      settings: settings,
    ));
  }

  Future<void> changeMailPreset(String name, String newName, String text) async {
    final mailPresetList = _settingsSuccess.mailPresetList;
    final mailPreset = _getMailPreset(name);
    if (mailPreset == null) {
      mailPresetList.add(MailPreset(name, text));
    } else {
      mailPreset.name = newName;
      mailPreset.text = text;
    }
    mailPresetList.sort((first, second) => first.name.toLowerCase().compareTo(second.name.toLowerCase()));
    await saveData(mailPresetListFilePath, mailPresetList);
    final newSuccessState = await fixSettingsIfInvalid(_settingsSuccess.copyWith(mailPresetList: mailPresetList), newPresetName: newName);
    emit(newSuccessState);
  }

  Future<void> deleteMailPreset(String name) async {
    final mailPreset = _getMailPreset(name);
    if (mailPreset != null) {
      final mailPresetList = _settingsSuccess.mailPresetList;
      mailPresetList.remove(mailPreset);
      await saveData(mailPresetListFilePath, mailPresetList);
      final newSuccessState = await fixSettingsIfInvalid(_settingsSuccess.copyWith(mailPresetList: mailPresetList));
      emit(newSuccessState);
    }
  }

  Future<void> changePlatform(String name, String newName) async {
    final platformList = _settingsSuccess.platformList;
    final platform = _getPlatform(name);
    if (platform == null) {
      platformList.add(Platform(name));
    } else {
      platform.name = newName;
    }
    platformList.sort((first, second) => first.name.toLowerCase().compareTo(second.name.toLowerCase()));
    await saveData(platformListFilePath, platformList);
    final newSuccessState = await fixSettingsIfInvalid(_settingsSuccess.copyWith(platformList: platformList), newPlatformName: newName);
    emit(newSuccessState);
  }

  Future<void> deletePlatform(String name) async {
    final platform = _getPlatform(name);
    if (platform != null) {
      final platformList = _settingsSuccess.platformList;
      platformList.remove(platform);
      await saveData(platformListFilePath, platformList);
      final newSuccessState = await fixSettingsIfInvalid(_settingsSuccess.copyWith(platformList: platformList));
      emit(newSuccessState);
    }
  }

  Future<void> restorePlatforms() async {
    final platformList = <Platform>[];
    final platformListString = await loadFileAsString(defaultPlatformListFilePath);
    List<dynamic> platformListJson = jsonDecode(platformListString);
    for (var platformJson in platformListJson) {
      platformList.add(Platform.fromJson(platformJson));
    }
    await saveData(platformListFilePath, platformList);
    final newSuccessState = await fixSettingsIfInvalid(_settingsSuccess.copyWith(platformList: platformList));
    emit(newSuccessState);
  }

  Future<void> changePlatformDefaultSelection(String name) async {
    final settings = _settingsSuccess.settings..defaultPlatform = name;
    await saveData(settingsFilePath, settings);
    emit(_settingsSuccess.copyWith(settings: settings));
  }

  Future<void> restoreMailPresets() async {
    final mailPresetList = <MailPreset>[];
    final mailPresetListString = await loadFileAsString(defaultMailPresetListFilePath);
    List<dynamic> mailPresetJsonList = jsonDecode(mailPresetListString);
    for (var mailPreset in mailPresetJsonList) {
      mailPresetList.add(MailPreset.fromJson(mailPreset));
    }
    await saveData(mailPresetListFilePath, mailPresetList);
    final newSuccessState = await fixSettingsIfInvalid(_settingsSuccess.copyWith(mailPresetList: mailPresetList));
    emit(newSuccessState);
  }

  Future<void> changeMailPresetDefaultSelection(String name) async {
    final settings = _settingsSuccess.settings..defaultMailPreset = name;
    await saveData(settingsFilePath, settings);
    emit(_settingsSuccess.copyWith(settings: settings));
  }

  Future<SettingsSuccess> fixSettingsIfInvalid(SettingsSuccess state, {String? newPlatformName, String? newPresetName}) async {
    final defaultPlatformValid = state.platformList.any((platform) => platform.name == state.settings.defaultPlatform);
    final defaultMailPresetValid = state.mailPresetList.any((preset) => preset.name == state.settings.defaultMailPreset);
    var wasInvalidDataFixed = !defaultPlatformValid || !defaultMailPresetValid;
    final settings = state.settings.copyWith(
        defaultPlatform: !defaultPlatformValid ? newPlatformName ?? state.platformList.first.name : null,
        defaultMailPreset: !defaultMailPresetValid ? newPresetName ?? state.mailPresetList.first.name : null);
    if (wasInvalidDataFixed) {
      await saveData(settingsFilePath, settings);
    }
    return wasInvalidDataFixed ? state.copyWith(settings: settings) : state;
  }

  MailPreset? _getMailPreset(String name) {
    final mailPresetList = _settingsSuccess.mailPresetList;
    final mailPresetMatcher = mailPresetList.where((mailPreset) => mailPreset.name == name);
    return mailPresetMatcher.length == 1 ? mailPresetMatcher.first : null;
  }

  Platform? _getPlatform(String name) {
    final platformList = _settingsSuccess.platformList;
    final platformMatcher = platformList.where((platform) => platform.name == name);
    return platformMatcher.length == 1 ? platformMatcher.first : null;
  }
}
