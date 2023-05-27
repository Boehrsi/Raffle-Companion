import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../entry_list/entry_list_cubit.dart';
import '../entry_list/entry_list_state.dart';
import '../settings/settings_cubit.dart';
import '../settings/settings_state.dart';
import '../types/entry.dart';
import '../types/mail_preset.dart';
import '../utils/l10n.dart';
import '../utils/system_interaction.dart';
import '../utils/text.dart';
import '../widgets/input.dart';
import '../widgets/layout.dart';
import '../widgets/text.dart';

class NotifyWinners extends StatefulWidget {
  const NotifyWinners({Key? key}) : super(key: key);

  @override
  State<NotifyWinners> createState() => _NotifyWinnersState();
}

class _NotifyWinnersState extends State<NotifyWinners> {
  final _formKey = GlobalKey<FormState>();
  final _mailInputFieldList = <FormTextBox>[];
  final _keyInputFieldList = <FormTextBox>[];
  final _nameInputField = FormTextBox(
    label: kTextWinnerName,
    validator: validatorNotEmpty,
  );
  final _urlInputField = FormTextBox(
    label: kTextWinnerUrl,
    validator: validatorNotEmpty,
  );
  final _subjectInputField = FormTextBox(
    label: kTextWinnerSubject,
    validator: validatorNotEmpty,
  );
  final _mailPresetComboBox = FormComboBox();

  var _infoBarText = '';
  var _infoBarSeverity = InfoBarSeverity.info;

  @override
  void initState() {
    super.initState();
    final entryListCubit = context.read<EntryListCubit>();
    context.read<SettingsCubit>().loadSettings();
    if (entryListCubit.state is EntryListSuccess) {
      final selectedList = (entryListCubit.state as EntryListSuccess).selectedList;
      for (Entry entry in selectedList) {
        _mailInputFieldList.add(FormTextBox(
          label: kTextMail,
          validator: validatorNotEmpty,
        ));
        _keyInputFieldList.add(FormTextBox(
          label: entry.name,
          validator: validatorNotEmpty,
        )..controller.text = entry.key ?? '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (BuildContext context, state) {
        if (state is SettingsSuccess) {
          final mailPresetNameList = state.mailPresetList.map((mailPreset) => mailPreset.name);
          _mailPresetComboBox.controller.setup(state.settings.defaultMailPreset, mailPresetNameList);
        }
      },
      builder: (BuildContext context, state) {
        if (state is SettingsSuccess && state.mailPresetList.isNotEmpty) {
          return NavigationView(
            appBar: const NavigationAppBar(
              title: AppBarTitle(text: kTextEmpty),
              actions: AppBarActions(),
            ),
            content: ScaffoldPage(
              header: PageHeader(
                title: const Text(kTextWinnerNotify),
                commandBar: CommandBar(
                  primaryItems: [
                    CommandBarButton(
                      icon: const Icon(FluentIcons.check_mark),
                      label: const Text(kTextMarkUsed),
                      onPressed: _markUsed,
                    ),
                    CommandBarButton(
                      icon: const Icon(FluentIcons.send),
                      label: const Text(kTextWinnerSendMail),
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
                                title: Text(_infoBarSeverity == InfoBarSeverity.error ? kTextError : kTextInfo),
                                content: Text(_infoBarText),
                                severity: _infoBarSeverity,
                                onClose: () {
                                  setState(() => _infoBarText = '');
                                },
                              ),
                            const LargeLabel(label: kTextWinnerSettings),
                            _nameInputField,
                            _urlInputField,
                            _subjectInputField,
                            InfoLabel(label: kTextWinnerPreset),
                            ConstraintWidthInput(child: _mailPresetComboBox),
                            const LargeLabel(label: kTextWinnerList),
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
          return const Center(child: Text(kTextErrorWinnerView));
        } else {
          return const Center(child: ProgressRing());
        }
      },
    );
  }

  void _sendMails(Iterable<MailPreset> mailPresetList) async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      if (!await canSend()) {
        setState(() {
          _infoBarText = kTextErrorNoMailApp;
          _infoBarSeverity = InfoBarSeverity.error;
        });
        return;
      }

      final raffleName = _nameInputField.controller.text;
      final raffleUrl = _urlInputField.controller.text;
      final mailSubject = _subjectInputField.controller.text;
      final mailPresetSelection = _mailPresetComboBox.controller.value;
      final mailPreset = mailPresetList.firstWhere((element) => element.name == mailPresetSelection);
      await sendMails(_mailInputFieldList, _keyInputFieldList, raffleName, raffleUrl, mailSubject, mailPreset.text);
    }
  }

  void _markUsed() {
    context.read<EntryListCubit>().markUsed();
    setState(() {
      _infoBarText = kTextEntriesMarkedUsed;
      _infoBarSeverity = InfoBarSeverity.info;
    });
  }
}

class WinnerRow extends StatelessWidget {
  const WinnerRow({
    Key? key,
    required this.mailInputField,
    required this.keyInputField,
  }) : super(key: key);

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
