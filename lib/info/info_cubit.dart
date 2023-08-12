import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/files.dart';
import '../l10n/l10n.dart';
import '../utils/system_interaction.dart';
import 'info_state.dart';

class InfoCubit extends Cubit<InfoState> {
  InfoSuccess get _infoSuccess => state as InfoSuccess;

  InfoCubit() : super(InfoInitial());

  Future<void> loadInfo() async {
    final Uri basePathUri = Uri(
      scheme: 'file',
      path: RaffleDirectory.files.getPath(),
    );

    final logFilePath = RaffleFile.log.getFilePath();
    final file = File(logFilePath);
    final log = await file.readAsString();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;

    emit(InfoSuccess(filesPath: basePathUri, log: log, version: version));
  }

  Future<bool> openFiles() async {
    if (await canLaunchUrl(_infoSuccess.filesPath)) {
      await launchUrl(_infoSuccess.filesPath);
      return true;
    }
    return false;
  }

  Future<bool> sendFeedback() async {
    if (await canSend()) {
      sendFeedbackMail(_infoSuccess.version);
      return true;
    }
    return false;
  }

  Future<bool> openGithub() async {
    final githubUri = Uri.parse(kTextGitHubLink);
    if (await canLaunchUrl(githubUri)) {
      await launchUrl(githubUri);
      return true;
    }
    return false;
  }
}
