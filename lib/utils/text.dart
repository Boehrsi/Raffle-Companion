import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:sprintf/sprintf.dart';

import '../l10n/l10n.dart';
import '../l10n/locale_keys.g.dart';

final numberInputFormatter = [FilteringTextInputFormatter.digitsOnly];

final _dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss");

Uri setupSendUrl(
  String mail,
  String subject,
  String mailPresetText,
  String raffleName,
  String raffleUrl,
  String game,
  String key,
  String? platform,
) {
  final body = _setupMailText(
    mailPresetText,
    raffleName,
    raffleUrl,
    game,
    key,
    platform,
  );
  return Uri(
    scheme: 'mailto',
    path: mail,
    query: sprintf(kSendMailQuery, [subject, body]),
  );
}

String? validatorNotEmpty(String? value) =>
    (value == null || value.isEmpty) ? LocaleKeys.errorNotEmpty.tr() : null;

String formatDateTime(DateTime date) {
  final timezoneHours = date.timeZoneOffset.inHours;
  final timezone =
      "${timezoneHours.isNegative ? "-" : "+"}${timezoneHours < 10 ? "0" : ""}$timezoneHours:00";
  return _dateFormat.format(date) + timezone;
}

void copyToClipboard(String value) {
  Clipboard.setData(ClipboardData(text: value));
}

String _setupMailText(
  String mailPreset,
  String raffleName,
  String raffleUrl,
  String game,
  String key,
  String? platform,
) {
  var result = mailPreset
      .replaceAll('%RAFFLE_NAME%', raffleName)
      .replaceAll('%RAFFLE_URL%', raffleUrl)
      .replaceAll('%PRODUCT%', game)
      .replaceAll('%KEY%', key);
  if (platform?.isNotEmpty == true) {
    result = result.replaceAll('%PLATFORM%', platform!);
  }
  return _sanitizeMailText(result);
}

String _sanitizeMailText(String input) => Uri.encodeComponent(input);
