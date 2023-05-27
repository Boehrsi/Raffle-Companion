import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

import '../styles/text.dart';

class ConstraintWidthContainer extends StatelessWidget {
  final Widget child;

  const ConstraintWidthContainer({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1024),
      child: child,
    );
  }
}

class AppBarTitle extends StatelessWidget {
  final String text;

  const AppBarTitle({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          text,
          style: context.titleLargeStyle,
        ),
      ),
    );
  }
}

class AppBarActions extends StatelessWidget {
  const AppBarActions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
