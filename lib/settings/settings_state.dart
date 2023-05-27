import '../types/mail_preset.dart';
import '../types/platform.dart';
import '../types/settings.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsSuccess extends SettingsState {
  List<MailPreset> mailPresetList;
  List<Platform> platformList;
  Settings settings;

  SettingsSuccess({required this.mailPresetList, required this.platformList, required this.settings});

  SettingsSuccess copyWith({List<MailPreset>? mailPresetList, List<Platform>? platformList, Settings? settings}) {
    return SettingsSuccess(
      mailPresetList: mailPresetList ?? this.mailPresetList,
      platformList: platformList ?? this.platformList,
      settings: settings ?? this.settings,
    );
  }
}
