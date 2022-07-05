/*
 * Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import 'dart:async';

import 'package:amplify_core/amplify_core.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

class CountCallsLoggerPlugin implements AmplifyLoggerPlugin {
  int _timesCalled = 0;

  CountCallsLoggerPlugin();

  int getTimesCalled() {
    return _timesCalled;
  }

  @override
  void handleLogRecord(LogRecord record) {
    _timesCalled++;
  }
}

class CallbackLoggerPlugin implements AmplifyLoggerPlugin {
  Function callback;

  CallbackLoggerPlugin(this.callback);

  @override
  void handleLogRecord(LogRecord record) {
    callback(record);
  }
}

void callLogger(AmplifyLogger amplifyLogger) {
  amplifyLogger
    ..verbose('Verbose Message')
    ..debug('Debug Message')
    ..info('Info Message')
    ..warn('Warn Message')
    ..error('Error Message');
}

void main() {
  test('LoggerPlugin called with proper LogRecord', () async {
    Completer completer = Completer();
    Map<Level, LogRecord> targetLogRecords = {
      Level.FINER: LogRecord(Level.FINER, 'Verbose Message', 'AWS.Amplify'),
      Level.FINE: LogRecord(Level.FINE, 'Debug Message', 'AWS.Amplify'),
      Level.INFO: LogRecord(Level.INFO, 'Info Message', 'AWS.Amplify'),
      Level.WARNING: LogRecord(Level.WARNING, 'Warn Message', 'AWS.Amplify'),
      Level.SEVERE: LogRecord(Level.SEVERE, 'Error Message', 'AWS.Amplify'),
    };

    var loggerPlugin = CallbackLoggerPlugin((LogRecord record) {
      expect(targetLogRecords.containsKey(record.level), true);
      expect(targetLogRecords[record.level].toString(), record.toString());

      targetLogRecords.remove(record.level);
      if (targetLogRecords.isEmpty) completer.complete();
    });

    var amplifyLogger = AmplifyLogger()
      ..registerPlugin(loggerPlugin)
      ..logLevel = LogLevel.verbose;
    callLogger(amplifyLogger);
    amplifyLogger.unregisterPlugin(loggerPlugin);

    await completer.future;
  });

  test('Unregistered plugin is not called', () async {
    var loggerPlugin = CountCallsLoggerPlugin();
    var amplifyLogger = AmplifyLogger()
      ..registerPlugin(loggerPlugin)
      ..logLevel = LogLevel.verbose;
    callLogger(amplifyLogger);

    expect(loggerPlugin.getTimesCalled(), 5);

    amplifyLogger.unregisterPlugin(loggerPlugin);

    callLogger(amplifyLogger);

    expect(loggerPlugin.getTimesCalled(), 5);
  });

  test('Multiple LoggerPlugins register and unregister properly', () async {
    var loggerPlugin1 = CountCallsLoggerPlugin();
    var loggerPlugin2 = CountCallsLoggerPlugin();
    var amplifyLogger = AmplifyLogger()
      ..registerPlugin(loggerPlugin1)
      ..registerPlugin(loggerPlugin2)
      ..logLevel = LogLevel.verbose;
    callLogger(amplifyLogger);

    expect(loggerPlugin1.getTimesCalled(), 5);
    expect(loggerPlugin2.getTimesCalled(), 5);

    amplifyLogger.unregisterPlugin(loggerPlugin1);
    callLogger(amplifyLogger);
    expect(loggerPlugin1.getTimesCalled(), 5);
    expect(loggerPlugin2.getTimesCalled(), 10);

    amplifyLogger.unregisterPlugin(loggerPlugin2);
    callLogger(amplifyLogger);
    expect(loggerPlugin1.getTimesCalled(), 5);
    expect(loggerPlugin2.getTimesCalled(), 10);
  });

  test('Default logger respects global log level', () async {
    var loggerPlugin = CountCallsLoggerPlugin();

    var amplifyLogger = AmplifyLogger()
      ..registerPlugin(loggerPlugin)
      ..logLevel = LogLevel.warn;
    callLogger(amplifyLogger);

    expect(loggerPlugin.getTimesCalled(), 2);

    amplifyLogger.unregisterPlugin(loggerPlugin);
  });

  test('Category logger respects global log level', () async {
    var loggerPlugin = CountCallsLoggerPlugin();

    var amplifyLogger = AmplifyLogger()..logLevel = LogLevel.warn;

    var categoryLogger = AmplifyLogger.category(Category.analytics)
      ..registerPlugin(loggerPlugin);

    callLogger(amplifyLogger);
    callLogger(categoryLogger);

    expect(loggerPlugin.getTimesCalled(), 2);

    amplifyLogger.unregisterPlugin(loggerPlugin);
  });

  test('Category logger with local logLevel overrides global log level',
      () async {
    var loggerPlugin = CountCallsLoggerPlugin();

    var amplifyLogger = AmplifyLogger()..logLevel = LogLevel.none;

    var categoryLogger = AmplifyLogger.category(Category.analytics)
      ..registerPlugin(loggerPlugin)
      ..logLevel = LogLevel.verbose;

    callLogger(amplifyLogger);
    callLogger(categoryLogger);

    expect(loggerPlugin.getTimesCalled(), 5);

    amplifyLogger.unregisterPlugin(loggerPlugin);
  });

  test('Category logger with local logLevel does not affect other loggers',
      () async {
    var loggerPlugin = CountCallsLoggerPlugin();

    var amplifyLogger = AmplifyLogger()..logLevel = LogLevel.info;

    var categoryLogger = AmplifyLogger.category(Category.analytics)
      ..registerPlugin(loggerPlugin);

    var otherCategoryLogger = AmplifyLogger.category(Category.auth)
      ..logLevel = LogLevel.none;

    callLogger(amplifyLogger);
    callLogger(categoryLogger);

    expect(loggerPlugin.getTimesCalled(), 5);

    amplifyLogger.unregisterPlugin(loggerPlugin);
  });

  test('Logger factory constructors return the same instance', () async {
    var loggerPlugin = CountCallsLoggerPlugin();

    var amplifyLogger = AmplifyLogger()
      ..registerPlugin(loggerPlugin)
      ..logLevel = LogLevel.none;

    callLogger(amplifyLogger);
    expect(loggerPlugin.getTimesCalled(), 0);

    AmplifyLogger().logLevel = LogLevel.verbose;

    callLogger(amplifyLogger);
    expect(loggerPlugin.getTimesCalled(), 5);

    amplifyLogger.unregisterPlugin(loggerPlugin);
  });

  test('Logger category factory constructors return the same instance',
      () async {
    var loggerPlugin = CountCallsLoggerPlugin();

    var amplifyLogger = AmplifyLogger.category(Category.analytics)
      ..registerPlugin(loggerPlugin)
      ..logLevel = LogLevel.none;

    callLogger(amplifyLogger);
    expect(loggerPlugin.getTimesCalled(), 0);

    AmplifyLogger.category(Category.analytics).logLevel = LogLevel.verbose;

    callLogger(amplifyLogger);
    expect(loggerPlugin.getTimesCalled(), 5);

    amplifyLogger.unregisterPlugin(loggerPlugin);
  });
}
