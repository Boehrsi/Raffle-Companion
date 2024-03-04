import 'package:fluent_ui/fluent_ui.dart';

class FormTextBox extends StatefulWidget {
  final _controller = TextEditingController();

  final String label;
  final double height;
  final FormFieldValidator<String>? validator;
  final bool multiLine;

  TextEditingController get controller => _controller;

  FormTextBox({super.key, required this.label, this.validator, this.height = 88.0, this.multiLine = false});

  @override
  State<FormTextBox> createState() => _FormTextBoxState();
}

class _FormTextBoxState extends State<FormTextBox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(label: widget.label),
          TextFormBox(
            controller: widget._controller,
            validator: widget.validator,
            minLines: widget.multiLine ? 5 : 1,
            maxLines: widget.multiLine ? 10 : 1,
          ),
        ],
      ),
    );
  }
}

class ComboBoxController extends ValueNotifier<String> {
  final List<String> _items = [];

  ComboBoxController(super.value);

  void setup(String newValue, Iterable<String> newItems) {
    final forceNotify = value == newValue;
    value = newValue;
    _items.clear();
    _items.addAll(newItems);
    if (forceNotify) {
      notifyListeners();
    }
  }
}

class FormComboBox extends StatefulWidget {
  final _controller = ComboBoxController("");

  final ValueChanged<String?>? onChanged;

  ComboBoxController get controller => _controller;

  FormComboBox({this.onChanged, super.key});

  @override
  State<FormComboBox> createState() => _FormComboBoxState();
}

class _FormComboBoxState extends State<FormComboBox> {
  late VoidCallback update;

  @override
  void dispose() {
    widget._controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget._controller;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ValueListenableBuilder(
        valueListenable: widget._controller,
        builder: (context, value, child) {
          return ComboBox<String>(
            isExpanded: true,
            value: value.toString(),
            onChanged: widget.onChanged ?? (String? newValue) => controller.value = newValue!,
            items: controller._items.map<ComboBoxItem<String>>((String value) {
              return ComboBoxItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class ConstraintWidthInput extends StatelessWidget {
  final Widget child;

  const ConstraintWidthInput({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: child,
    );
  }
}
