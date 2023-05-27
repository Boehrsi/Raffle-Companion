import 'package:fluent_ui/fluent_ui.dart';

import '../utils/l10n.dart';

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
            child: const Text(kTextOk),
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
            child: const Text(kTextCancel),
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

  const ErrorDialog({required this.error, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text(kTextError),
      content: Text(error),
      actions: <Widget>[
        Button(
          onPressed: () => Navigator.pop(context),
          child: const Text(kTextOk),
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

  const FormDialog({Key? key, required this.formKey, required this.title, required this.child, required this.actions}) : super(key: key);

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
    Key? key,
    required this.title,
    required this.child,
    required this.actions,
  }) : super(key: key);

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
