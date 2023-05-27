import 'package:sprintf/sprintf.dart';

import 'l10n.dart';

Uri setupSendUrl(String mail, String subject, String mailPresetText, String raffleName, String raffleUrl, String game, String key) {
  final body = _setupMailText(mailPresetText, raffleName, raffleUrl, game, key);
  return Uri(
    scheme: 'mailto',
    path: mail,
    query: sprintf(kSendMailQuery, [subject, body]),
  );
}

String _setupMailText(String mailPreset, String raffleName, String raffleUrl, String game, String key) {
  return mailPreset
      .replaceAll('%RAFFLE_NAME%', raffleName)
      .replaceAll('%RAFFLE_URL%', raffleUrl)
      .replaceAll('%PRODUCT%', game)
      .replaceAll('%KEY%', key);
}

String? validatorNotEmpty(value) => (value == null || value.isEmpty) ? kTextErrorNotEmpty : null;
