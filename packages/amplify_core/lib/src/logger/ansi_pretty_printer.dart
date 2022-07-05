// Copyright 2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:amplify_core/amplify_core.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:logging/logging.dart';

class AnsiPrettyPrinter implements AmplifyLoggerPlugin {
  final AnsiPen _pen = AnsiPen();

  AnsiPrettyPrinter() {
    ansiColorDisabled = false;
  }

  @override
  void handleLogRecord(LogRecord record) {
    final buffer = StringBuffer();

    // Log Level
    buffer.write(_printLevel(record.level));

    // Log Namespace
    buffer.write(' ');

    final namespace =
        record.loggerName == 'Amplify' ? '' : record.loggerName.split('.')[1];
    if (namespace.isNotEmpty) {
      buffer.write(_formatLogNamespace(namespace));
    }

    // Log Message
    buffer.write(' ');
    buffer.write(record.message);

    safePrint(buffer.toString());
  }

  String _formatLogNamespace(String? namespace) {
    String result = (_pen
      ..white(bold: true)
      ..gray(level: .2, bg: true))(' $namespace ');
    _pen.reset();
    return result;
  }

  String _printLevel(Level level) {
    String result;
    if (level <= Level.FINER) {
      result = (_pen
            ..white(bold: true)
            ..gray(level: .8, bg: true))(' V ')
          .toString();
    } else if (level <= Level.FINE) {
      result = (_pen
        ..white(bold: true)
        ..gray(level: .6, bg: true))(' D ');
    } else if (level <= Level.INFO) {
      result = (_pen
        ..white(bold: true)
        ..blue(bg: true))(' I ');
    } else if (level <= Level.WARNING) {
      result = (_pen
        ..white(bold: true)
        ..yellow(bg: true))(' W ');
    } else {
      result = (_pen
        ..white(bold: true)
        ..red(bg: true))(' E ');
    }
    _pen.reset();
    return result;
  }
}
