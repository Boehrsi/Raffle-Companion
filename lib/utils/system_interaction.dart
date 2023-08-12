import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/locale_keys.g.dart';
import '../types/entry.dart';
import '../widgets/input.dart';
import '../l10n/l10n.dart';
import 'text.dart';

Future<bool> canSend() async {
  final uri = Uri(scheme: 'mailto', path: "test@mail.com", queryParameters: {'subject': 'subject=subject', 'body': 'body'});
  return await canLaunchUrl(uri);
}

Future<void> sendMails(
  List<FormTextBox> mailInputFieldList,
  List<FormTextBox> keyInputFieldList,
  String raffleName,
  String raffleUrl,
  String mailSubject,
  String mailPreset,
) async {
  await Future.forEach(mailInputFieldList, (FormTextBox element) async {
    final index = mailInputFieldList.indexOf(element);
    final mail = mailInputFieldList[index].controller.text;
    final game = keyInputFieldList[index].label;
    final key = keyInputFieldList[index].controller.text;

    final uri = setupSendUrl(mail, mailSubject, mailPreset, raffleName, raffleUrl, game, key);
    await Future.delayed(Duration(milliseconds: index == 0 ? 0 : 500), () => launchUrl(uri));
  });
}

Future<void> sendFeedbackMail(String version) async {
  final uri = Uri(
    scheme: 'mailto',
    path: "rafflecompanion@boehrsi.de",
    query: sprintf(kSendMailQuery, ['Raffle Companion feedback', '${LocaleKeys.infoVersion.tr()}: $version\n\n']),
  );
  await launchUrl(uri);
}

Future<void> copyToClipboard(List<Entry> entryList, bool isMarkdown) async {
  var uniqueEntryNameList = entryList.uniqueNameList();
  var text = isMarkdown ? '' : '<ul>\n';
  for (String entryName in uniqueEntryNameList) {
    text += "${isMarkdown ? "- $entryName" : "<li>$entryName</li>"}\n";
  }
  text += isMarkdown ? '' : '</ul>';
  await Clipboard.setData(ClipboardData(text: text));
}
