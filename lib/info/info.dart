import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/locale_keys.g.dart';
import '../utils/colors.dart';
import '../l10n/l10n.dart';
import '../widgets/dialogs.dart';
import '../widgets/layout.dart';
import '../widgets/text.dart';
import 'info_cubit.dart';
import 'info_state.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  final logController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<InfoCubit>().loadInfo();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InfoCubit, InfoState>(listener: (context, state) {
      if (state is InfoSuccess) {
        logController.text = state.log;
      }
    }, builder: (context, state) {
      if (state is InfoSuccess) {
        return ScaffoldPage(
          header: PageHeader(
            title: Text(LocaleKeys.infoTitle.tr()),
          ),
          content: SingleChildScrollView(
            child: Center(
              child: ConstraintWidthContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(text: '${LocaleKeys.infoVersion.tr()} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: state.version),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(text: '${LocaleKeys.developedBy.tr()} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const TextSpan(text: kTextAuthor),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(text: '${LocaleKeys.infoGitHub.tr()} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                              text: kTextGitHubLink,
                              style: TextStyle(
                                color: kPrimary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _openGitHub();
                                },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Divider(
                          style: FluentTheme.of(context).dividerTheme.merge(const DividerThemeData(horizontalMargin: EdgeInsets.zero)),
                        ),
                      ),
                      LargeLabel(label: LocaleKeys.infoFiles.tr()),
                      Button(
                        onPressed: _openFiles,
                        child: Text(LocaleKeys.infoOpenFiles.tr()),
                      ),
                      LargeLabel(label: LocaleKeys.infoFeedback.tr()),
                      Button(
                        onPressed: _sendFeedback,
                        child: Text(LocaleKeys.infoSendFeedback.tr()),
                      ),
                      LargeLabel(label: LocaleKeys.infoLog.tr()),
                      TextFormBox(
                        controller: logController,
                        readOnly: true,
                        minLines: 20,
                        maxLines: 50,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        return const Center(child: ProgressRing());
      }
    });
  }

  void _openFiles() {
    context.read<InfoCubit>().openFiles().then((result) {
      if (!result) {
        showInfoDialog(context: context, title: LocaleKeys.errorTitle.tr(), content: LocaleKeys.errorNoFileExplorer.tr());
      }
    });
  }

  void _sendFeedback() {
    context.read<InfoCubit>().sendFeedback().then((result) {
      if (!result) {
        showInfoDialog(context: context, title: LocaleKeys.errorTitle.tr(), content: LocaleKeys.errorNoMailApp.tr());
      }
    });
  }

  void _openGitHub() {
    context.read<InfoCubit>().openGithub().then((result) {
      if (!result) {
        showInfoDialog(context: context, title: LocaleKeys.errorTitle.tr(), content: LocaleKeys.errorNoBrowser.tr());
      }
    });
  }
}
