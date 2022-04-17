import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:inspection/inspection.dart';

var ipFormatter = new MaskTextInputFormatter(
    mask: '###.###.###.###',
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy
);

bool ipValidator(value) {
  return true;
}