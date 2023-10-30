import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../entry_list/entry_list_cubit.dart';
import '../entry_list/entry_list_state.dart';
import '../l10n/l10n.dart';
import '../l10n/locale_keys.g.dart';
import '../settings/settings_cubit.dart';
import '../settings/settings_state.dart';
import '../types/entry.dart';
import '../types/mail_preset.dart';
import '../utils/system_interaction.dart';
import '../utils/text.dart';
import '../widgets/input.dart';
import '../widgets/layout.dart';
import '../widgets/text.dart';

class NotifyWinners extends StatefulWidget {
  const NotifyWinners({super.key});

  @override
  State<NotifyWinners> createState() => _NotifyWinnersState();
}

class _NotifyWinnersState extends State<NotifyWinners> {
  final _formKey = GlobalKey<FormState>();
  final _mailInputFieldList = <FormTextBox>[];
  final _keyInputFieldList = <FormTextBox>[];
  final _platformList = <String>[];
  final _nameInputField = FormTextBox(
    label: LocaleKeys.winnerName.tr(),
    validator: validatorNotEmpty,
  );
  final _urlInputField = FormTextBox(
    label: LocaleKeys.winnerUrl.tr(),
    validator: validatorNotEmpty,
  );
  final _subjectInputField = FormTextBox(
    label: LocaleKeys.winnerSubject.tr(),
    validator: validatorNotEmpty,
  );
  final _mailPresetComboBox = FormComboBox();

  var _infoBarText = '';
  var _infoBarSeverity = InfoBarSeverity.info;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupEntryForm();
    _setupMailPresetBox();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (BuildContext context, state) {
        if (state is SettingsSuccess && state.mailPresetList.isNotEmpty) {
          return NavigationView(
            appBar: const NavigationAppBar(
              title: AppBarTitle(text: kTextEmpty),
              actions: AppBarActions(),
            ),
            content: ScaffoldPage(
              header: PageHeader(
                title: Text(LocaleKeys.winnerNotify.tr()),
                commandBar: CommandBar(
                  primaryItems: [
                    CommandBarButton(
                      icon: const Icon(FluentIcons.check_mark),
                      label: Text(LocaleKeys.markUsed.tr()),
                      onPressed: _markUsed,
                    ),
                    CommandBarButton(
                      icon: const Icon(FluentIcons.send),
                      label: Text(LocaleKeys.winnerSendMail.tr()),
                      onPressed: () => _sendMails(state.mailPresetList),
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: Center(
                  child: ConstraintWidthContainer(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_infoBarText.isNotEmpty)
                              InfoBar(
                                title: Text(_infoBarSeverity == InfoBarSeverity.error ? LocaleKeys.error.tr() : LocaleKeys.info.tr()),
                                content: Text(_infoBarText),
                                severity: _infoBarSeverity,
                                onClose: () {
                                  setState(() => _infoBarText = '');
                                },
                              ),
                            LargeLabel(label: LocaleKeys.winnerSettings.tr()),
                            _nameInputField,
                            _urlInputField,
                            _subjectInputField,
                            InfoLabel(label: LocaleKeys.winnerPreset.tr()),
                            ConstraintWidthInput(child: _mailPresetComboBox),
                            LargeLabel(label: LocaleKeys.winnerList.tr()),
                            ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              itemCount: _mailInputFieldList.length,
                              itemBuilder: (context, index) {
                                final mailInputField = _mailInputFieldList[index];
                                final keyInputField = _keyInputFieldList[index];
                                return WinnerRow(
                                  mailInputField: mailInputField,
                                  keyInputField: keyInputField,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else if (state is SettingsSuccess && state.mailPresetList.isEmpty) {
          return Center(child: Text(LocaleKeys.errorView.tr()));
        } else {
          return const Center(child: ProgressRing());
        }
      },
    );
  }

  void _setupEntryForm() {
    final state = context.read<EntryListCubit>().state;
    if (state is EntryListSuccess) {
      for (Entry entry in state.selectedList) {
        _mailInputFieldList.add(FormTextBox(
          label: LocaleKeys.mail.tr(),
          validator: validatorNotEmpty,
        ));
        _keyInputFieldList.add(FormTextBox(
          label: entry.name,
          validator: validatorNotEmpty,
        )..controller.text = entry.key ?? '');
        _platformList.add(entry.platform);
      }
    }
  }

  void _setupMailPresetBox() {
    final state = context.read<SettingsCubit>().state;
    if (state is SettingsSuccess) {
      final mailPresetNameList = state.mailPresetList.map((mailPreset) => mailPreset.name);
      _mailPresetComboBox.controller.setup(state.settings.defaultMailPreset, mailPresetNameList);
    }
  }

  void _sendMails(Iterable<MailPreset> mailPresetList) async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      if (!await canSend()) {
        setState(() {
          _infoBarText = LocaleKeys.errorNoMailApp.tr();
          _infoBarSeverity = InfoBarSeverity.error;
        });
        return;
      }

      final raffleName = _nameInputField.controller.text;
      final raffleUrl = _urlInputField.controller.text;
      final mailSubject = _subjectInputField.controller.text;
      final mailPresetSelection = _mailPresetComboBox.controller.value;
      final mailPreset = mailPresetList.firstWhere((element) => element.name == mailPresetSelection);
      await sendMails(_mailInputFieldList, _keyInputFieldList, _platformList, raffleName, raffleUrl, mailSubject, mailPreset.text);
    }
  }

  void _markUsed() {
    context.read<EntryListCubit>().markUsed();
    setState(() {
      _infoBarText = LocaleKeys.entriesMarkedUsed.tr();
      _infoBarSeverity = InfoBarSeverity.info;
    });
  }
}

class WinnerRow extends StatelessWidget {
  const WinnerRow({
    super.key,
    required this.mailInputField,
    required this.keyInputField,
  });

  final FormTextBox mailInputField;
  final FormTextBox keyInputField;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: mailInputField,
          ),
        ),
        Flexible(child: keyInputField),
      ],
    );
  }
}
