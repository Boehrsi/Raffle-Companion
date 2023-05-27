import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../settings/settings_cubit.dart';
import '../settings/settings_state.dart';
import '../types/entry.dart';
import '../utils/l10n.dart';
import '../utils/text.dart';
import '../widgets/dialogs.dart';
import '../widgets/input.dart';
import 'entry_list_cubit.dart';

class EntryListChange extends StatefulWidget {
  final Entry? entry;

  const EntryListChange({this.entry, Key? key}) : super(key: key);

  @override
  State<EntryListChange> createState() => _EntryListChangeState();
}

class _EntryListChangeState extends State<EntryListChange> {
  final _formKey = GlobalKey<FormState>();
  final _productInputField = FormTextBox(label: kTextProductRequired, validator: validatorNotEmpty);
  final _tagInputField = FormTextBox(label: kTextTag);
  final _keyInputField = FormTextBox(label: kTextKey);
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
              title: _isEdit() ? kTextEntriesEdit : kTextEntriesAdd,
              actions: [
                Button(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(kTextCancel),
                ),
                Button(
                  onPressed: _changeEntry,
                  child: Text(_isEdit() ? kTextEdit : kTextAdd),
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
                    child: InfoLabel(label: kTextPlatform),
                  ),
                  _platformComboBox,
                ],
              ),
            );
          } else {
            return const ErrorDialog(error: kTextErrorNoPlatform);
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
