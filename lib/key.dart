import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

class KeyboardListener {
  static Stream<String> _keyboardStream;
  static const EventChannel _eventChannel = const EventChannel(
    'im.parrot.keyPressedChannel',
  );

  static Stream<String> _getKeyboardStream() {
    if ( _keyboardStream == null ) _keyboardStream =
        _eventChannel.receiveBroadcastStream().cast<String>();
    return _keyboardStream;
  }

  StreamSubscription subscribeToKeyStream({@required Function(String) keyAction}) {
    return _getKeyboardStream().listen(keyAction);
  }
}