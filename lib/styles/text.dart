import 'package:flutter/material.dart';

extension TextStyles on BuildContext {
  TextStyle? get titleLargeStyle => Theme.of(this).textTheme.titleLarge;

  TextStyle? get captionStyle => Theme.of(this).textTheme.bodyMedium?.copyWith(color: Theme.of(this).textTheme.bodySmall?.color);
}
