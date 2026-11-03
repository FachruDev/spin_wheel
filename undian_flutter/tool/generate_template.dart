// Membuat ulang file template Excel peserta dari participant_template.dart.
//
//   dart run tool/generate_template.dart
import 'dart:io';

import 'package:undian_flutter/features/participants/import/participant_template.dart';

void main() {
  final file = File('assets/templates/template_peserta.xlsx')..createSync(recursive: true);
  file.writeAsBytesSync(buildParticipantTemplate());
  stdout.writeln('Tersimpan: ${file.path}');
}
