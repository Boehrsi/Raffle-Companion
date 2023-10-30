import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../l10n/locale_keys.g.dart';

Future<bool?> showInfoDialog({required BuildContext context, required String title, required String content}) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return ContentDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          Button(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(LocaleKeys.ok.tr()),
          ),
        ],
      );
    },
  );
}

Future<bool?> showConfirmDialog({required BuildContext context, required String title, required String content, required String positiveText}) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return ContentDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          Button(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(LocaleKeys.cancel.tr()),
          ),
          Button(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(positiveText),
          ),
        ],
      );
    },
  );
}

Future<void> showErrorDialog({required BuildContext context, required String error}) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return ErrorDialog(error: error);
    },
  );
}

class ErrorDialog extends StatelessWidget {
  final String error;

  const ErrorDialog({required this.error, super.key});

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(LocaleKeys.error.tr()),
      content: Text(error),
      actions: <Widget>[
        Button(
          onPressed: () => Navigator.pop(context),
          child: Text(LocaleKeys.ok.tr()),
        ),
      ],
    );
  }
}

class FormDialog extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String title;
  final Widget child;
  final List<Widget> actions;

  const FormDialog({super.key, required this.formKey, required this.title, required this.child, required this.actions});

  @override
  Widget build(BuildContext context) {
    return _SizedDialog(
      title: title,
      actions: actions,
      child: Form(
        key: formKey,
        child: child,
      ),
    );
  }
}

class _SizedDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;

  const _SizedDialog({
    required this.title,
    required this.child,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(title),
      content: child,
      actions: actions,
      constraints: const BoxConstraints(maxWidth: 512),
    );
  }
}
