import 'package:fluent_ui/fluent_ui.dart';

import '../styles/text.dart';

class LargeLabel extends StatelessWidget {
  final String label;

  const LargeLabel({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 12.0, bottom: 8.0),
      child: Text(
        label,
        style: context.textStyleSubtitle,
      ),
    );
  }
}

class MediumLabel extends StatelessWidget {
  final String label;

  const MediumLabel({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 12.0, bottom: 8.0),
      child: Text(
        label,
        style: context.textStyleBody?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
