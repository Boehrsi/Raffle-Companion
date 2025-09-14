import 'package:fluent_ui/fluent_ui.dart';

const kTextAppName = 'Raffle Companion';
const kTextAuthor = 'Boehrsi';
const kTextGitHubLink = 'https://github.com/Boehrsi/Raffle-Companion';
const kTextAppDirectoryName = 'Raffle Companion';
const kSendMailQuery = "subject=%s&body=%s";
const kTextEmpty = '';

const kLocalePath = 'assets/l10n';
const kLocaleEnglish = Locale('en'); // Used as fallbackLocale
const kLocaleGerman = Locale('de');
const kLocales = {"Deutsch": kLocaleGerman, "English": kLocaleEnglish};

String getUserVisibleLocaleString(String languageCode) => kLocales.entries
    .firstWhere((element) => element.value.languageCode == languageCode)
    .key;
