import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/locale_keys.g.dart';
import '../settings/settings_cubit.dart';
import '../settings/settings_state.dart';
import '../types/entry.dart';
import '../utils/text.dart';
import '../widgets/dialogs.dart';
import '../widgets/input.dart';
import 'entry_list_cubit.dart';

class EntryListChange extends StatefulWidget {
  final Entry? entry;

  const EntryListChange({this.entry, super.key});

  @override
  State<EntryListChange> createState() => _EntryListChangeState();
}

class _EntryListChangeState extends State<EntryListChange> {
  final _formKey = GlobalKey<FormState>();
  final _productInputField = FormTextBox(label: LocaleKeys.productRequired.tr(), validator: validatorNotEmpty);
  final _tagInputField = FormTextBox(label: LocaleKeys.tag.tr());
  final _keyInputField = FormTextBox(label: LocaleKeys.key.tr());
  final _platformComboBox = FormComboBox();

  @override
  void initState() {
    super.initState();
    if (_isEdit()) {
      final entry = widget.entry!;
      _platformComboBox.controller.value = entry.platform;
      _productInputField.controller.text = entry.name;
      if (entry.key != null) {
        _keyInputField.controller.text = entry.key!;
      }
      if (entry.tag != null) {
        _tagInputField.controller.text = entry.tag!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state is SettingsSuccess) {
          final platformNameList = state.platformList.map((platform) => platform.name);
          if (platformNameList.isNotEmpty) {
            _platformComboBox.controller.setup(state.settings.defaultPlatform, platformNameList);
            return FormDialog(
              formKey: _formKey,
              title: _isEdit() ? LocaleKeys.entriesEdit.tr() : LocaleKeys.entriesAdd.tr(),
              actions: [
                Button(
                  onPressed: () => Navigator.pop(context),
                  child: Text(LocaleKeys.cancel.tr()),
                ),
                Button(
                  onPressed: _changeEntry,
                  child: Text(LocaleKeys.save.tr()),
                ),
              ],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _productInputField,
                  _tagInputField,
                  _keyInputField,
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: InfoLabel(label: LocaleKeys.platform.tr()),
                  ),
                  _platformComboBox,
                ],
              ),
            );
          } else {
            return ErrorDialog(error: LocaleKeys.errorNoPlatform.tr());
          }
        } else {
          return const Center(child: ProgressRing());
        }
      },
    );
  }

  bool _isEdit() => widget.entry != null;

  void _changeEntry() {
    if (_formKey.currentState!.validate()) {
      var cubit = context.read<EntryListCubit>();
      if (_isEdit()) {
        cubit.edit(widget.entry!, _productInputField.controller.text, _keyInputField.controller.text, _platformComboBox.controller.value,
            _tagInputField.controller.text);
      } else {
        cubit.add(
            _productInputField.controller.text, _keyInputField.controller.text, _platformComboBox.controller.value, _tagInputField.controller.text);
      }
      Navigator.pop(context);
    }
  }
}
