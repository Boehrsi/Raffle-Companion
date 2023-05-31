import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'l10n.dart';

enum RaffleDirectory {
  files(segments: [_folderFiles]),
  defaults(segments: [_folderFiles, _folderDefaults]),
  logs(segments: [_folderFiles, _logFolder]);

  const RaffleDirectory({required this.segments});

  final List<String> segments;

  String getPath() {
    var prefix = this == RaffleDirectory.defaults ? _sourcePath : _basePath;
    return p.joinAll([prefix, ...segments]);
  }
}

enum RaffleFile {
  log(directory: RaffleDirectory.logs, name: _logFile),
  config(directory: RaffleDirectory.files, name: _configFile),
  entries(directory: RaffleDirectory.files, name: _entriesFile),
  mailPreset(directory: RaffleDirectory.files, name: _mailPresetFile),
  platforms(directory: RaffleDirectory.files, name: _platformsFile),
  settings(directory: RaffleDirectory.files, name: _settingsFile);

  const RaffleFile({required this.directory, required this.name});

  final RaffleDirectory directory;
  final String name;

  String getFilePath() => p.join(directory.getPath(), name);

  String getDefaultFilePath() => p.join(RaffleDirectory.defaults.getPath(), name);

  Future<void> setup() async {
    final targetDirectoryPath = directory.getPath();
    final targetDirectory = Directory(targetDirectoryPath);
    final targetFilePath = getFilePath();
    final targetFile = File(targetFilePath);

    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }
    if (!await targetFile.exists()) {
      await File(getDefaultFilePath()).copy(targetFilePath);
    }
  }
}

const _folderFiles = 'files';
const _folderDefaults = 'defaults';
const _logFolder = 'logs';

const _logFile = 'actions.log';
const _configFile = 'config.json';
const _entriesFile = 'entries.json';
const _mailPresetFile = 'mail_presets.json';
const _platformsFile = 'platforms.json';
const _settingsFile = 'settings.json';

late String _sourcePath;
late String _basePath;

Future<void> setupData() async {
  _sourcePath = kDebugMode ? "" : p.dirname(Platform.resolvedExecutable);
  _basePath = await getBasePath();
}

Future<void> prepareFiles() async {
  await Future.forEach(RaffleFile.values, (RaffleFile raffleFile) async => await raffleFile.setup());
}

Future<String> getBasePath() async {
  final documentsPath = (await getApplicationDocumentsDirectory()).path;
  return p.join(documentsPath, kTextAppDirectoryName);
}
