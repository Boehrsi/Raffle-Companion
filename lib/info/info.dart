import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/colors.dart';
import '../utils/l10n.dart';
import '../widgets/dialogs.dart';
import '../widgets/layout.dart';
import '../widgets/text.dart';
import 'info_cubit.dart';
import 'info_state.dart';

class Info extends StatefulWidget {
  const Info({Key? key}) : super(key: key);

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
          header: const PageHeader(
            title: Text(kTextInfoTitle),
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
                            const TextSpan(text: '$kTextInfoVersion ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: state.version),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: const <TextSpan>[
                            TextSpan(text: '$kTextDevelopedBy ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: kTextAuthor),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            const TextSpan(text: '$kTextInfoGitHub ', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      const LargeLabel(label: kTextInfoFiles),
                      Button(
                        onPressed: _openFiles,
                        child: const Text(kTextInfoOpenFiles),
                      ),
                      const LargeLabel(label: kTextInfoFeedback),
                      Button(
                        onPressed: _sendFeedback,
                        child: const Text(kTextInfoSendFeedback),
                      ),
                      const LargeLabel(label: kTextInfoLog),
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
        showInfoDialog(context: context, title: kTextErrorTitle, content: kTextErrorNoFileExplorer);
      }
    });
  }

  void _sendFeedback() {
    context.read<InfoCubit>().sendFeedback().then((result) {
      if (!result) {
        showInfoDialog(context: context, title: kTextErrorTitle, content: kTextErrorNoMailApp);
      }
    });
  }

  void _openGitHub() {
    context.read<InfoCubit>().openGithub().then((result) {
      if (!result) {
        showInfoDialog(context: context, title: kTextErrorTitle, content: kTextErrorNoBrowser);
      }
    });
  }
}
