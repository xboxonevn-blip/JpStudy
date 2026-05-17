import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

const vocabContentLoadTimeout = Duration(seconds: 12);

Future<T> withVocabContentTimeout<T>(
  Future<T> future, {
  Ref? ref,
  Duration timeout = vocabContentLoadTimeout,
}) {
  if (ref != null) {
    final completer = Completer<T>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException(null, timeout));
      }
    });
    ref.onDispose(timer.cancel);
    future.then(
      (value) {
        if (completer.isCompleted) {
          return;
        }
        timer.cancel();
        completer.complete(value);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (completer.isCompleted) {
          return;
        }
        timer.cancel();
        completer.completeError(error, stackTrace);
      },
    );
    return completer.future;
  }
  return future.timeout(
    timeout,
    onTimeout: () => throw TimeoutException(null, timeout),
  );
}
