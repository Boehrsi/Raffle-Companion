import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raffle_companion/styles/text.dart';
import 'package:raffle_companion/tools/tools_cubit.dart';
import 'package:raffle_companion/tools/tools_state.dart';

import '../l10n/locale_keys.g.dart';
import '../utils/text.dart';
import '../widgets/input.dart';
import '../widgets/layout.dart';
import '../widgets/text.dart';

class DateTools extends StatefulWidget {
  const DateTools({super.key});

  @override
  State<DateTools> createState() => _DateToolsState();
}

class _DateToolsState extends State<DateTools> {
  late final FormTextBox dayInputField;
  late final FormTextBox weekInputField;
  late final FormTextBox monthInputField;
  late final FormTextBox hoursInputField;
  late final FormTextBox minutesInputField;

  @override
  void initState() {
    super.initState();
    dayInputField = FormTextBox(
      label: LocaleKeys.day.tr(),
      inputFormatters: numberInputFormatter,
      onChanged: _changeDate,
    );
    weekInputField = FormTextBox(
      label: LocaleKeys.week.tr(),
      inputFormatters: numberInputFormatter,
      onChanged: _changeDate,
    );
    monthInputField = FormTextBox(
      label: LocaleKeys.month.tr(),
      inputFormatters: numberInputFormatter,
      onChanged: _changeDate,
    );
    hoursInputField = FormTextBox(
      label: LocaleKeys.hours.tr(),
      inputFormatters: numberInputFormatter,
      onChanged: _changeDate,
    );
    minutesInputField = FormTextBox(
      label: LocaleKeys.minutes.tr(),
      inputFormatters: numberInputFormatter,
      onChanged: _changeDate,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<ToolsCubit>().loadTools();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToolsCubit, ToolsState>(
      builder: (BuildContext context, ToolsState state) {
        if (state is ToolsSuccess) {
          final text = formatDateTime(state.formattedFuture);
          final timeStamp = state.formattedFuture.millisecondsSinceEpoch
              .toString();
          return ScaffoldPage(
            header: PageHeader(title: Text(LocaleKeys.date.tr())),
            content: SingleChildScrollView(
              child: Center(
                child: ConstraintWidthContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LargeLabel(label: LocaleKeys.toolsDateSetOffset.tr()),
                        InfoLabel(
                          label: LocaleKeys.toolsDateSetOffsetInfo.tr(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              ConstraintWidthInput(
                                maxWidth: 192.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: dayInputField,
                                ),
                              ),
                              ConstraintWidthInput(
                                maxWidth: 192.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: weekInputField,
                                ),
                              ),
                              ConstraintWidthInput(
                                maxWidth: 192.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: monthInputField,
                                ),
                              ),
                            ],
                          ),
                        ),
                        LargeLabel(label: LocaleKeys.toolsDateSetTime.tr()),
                        InfoLabel(label: LocaleKeys.toolsDateSetTimeInfo.tr()),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              ConstraintWidthInput(
                                maxWidth: 192.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: hoursInputField,
                                ),
                              ),
                              ConstraintWidthInput(
                                maxWidth: 192.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: minutesInputField,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 32.0, bottom: 16.0),
                          child: Divider(),
                        ),
                        LargeLabel(label: LocaleKeys.toolsDateResult.tr()),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 120.0,
                                  child: Text(
                                    LocaleKeys.date.tr(),
                                    style: context.textStyleBodyStrong,
                                  ),
                                ),
                                Text(text),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(FluentIcons.copy),
                                    onPressed: () {
                                      copyToClipboard(text);
                                      _showCopyInfo();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 120.0,
                                  child: Text(
                                    LocaleKeys.timestamp.tr(),
                                    style: context.textStyleBodyStrong,
                                  ),
                                ),
                                Text(timeStamp),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(FluentIcons.copy),
                                    onPressed: () {
                                      copyToClipboard(timeStamp);
                                      _showCopyInfo();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
      },
    );
  }

  void _changeDate(String? _) {
    final day = int.tryParse(dayInputField.controller.text);
    final week = int.tryParse(weekInputField.controller.text);
    final month = int.tryParse(monthInputField.controller.text);
    final hours = int.tryParse(hoursInputField.controller.text);
    final minutes = int.tryParse(minutesInputField.controller.text);
    context.read<ToolsCubit>().loadTools(
      day: day,
      week: week,
      month: month,
      hours: hours,
      minutes: minutes,
    );
  }

  Future<void> _showCopyInfo() async {
    await displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: Text(LocaleKeys.copied.tr()),
          content: Text(LocaleKeys.clipboardSuccess.tr()),
          severity: InfoBarSeverity.info,
        );
      },
    );
  }
}
