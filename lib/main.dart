import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('im.parrot.keyPressed');
  String _currentKey = 'no key has been pressed';
  final TextEditingController textEditingController = TextEditingController();
  static Stream<String> _keyboardStream;
  StreamSubscription<String> _keyboardStreamSubscription;
  String _streamResponse = 'no response';
  bool _change = false;

  static const EventChannel _eventChannel = const EventChannel(
    'im.parrot.keyPressedChannel',
  );


  @override
  void initState() {
    super.initState();
    _listenToKeyStream();
  }

  @override
  void dispose() {
    _keyboardStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getKeyPressed() async {
    String keyPressed;
    try {
      final String result = await platform.invokeMethod('getCurrentKey');
      keyPressed = '$result key pressed.';
    } on PlatformException catch (e) {
      keyPressed = "Failed to get the key: '${e.message}'.";
    }

    setState(() {
      _currentKey = keyPressed;
    });
  }

  static Stream<String> _getKeyboardStream() {
    if ( _keyboardStream == null ) _keyboardStream =
        _eventChannel.receiveBroadcastStream().cast<String>();
    return _keyboardStream;
  }

  void _listenToKeyStream() {
    _keyboardStreamSubscription = _getKeyboardStream().listen(
            (string) {
          setState(() {
            _streamResponse = string;
            _change = !_change;
          });
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: textEditingController,
              ),
            ),
            Text(
              _streamResponse,
            ),
            Text(
              _currentKey,
            ),
            ColoredSomething(change: _change),
            ElevatedButton(
              child: Text('ok'),
              onPressed: _getKeyPressed,
            )
          ],
        ),
      ),
    );
  }
}

class ColoredSomething extends StatefulWidget {
  final bool change;

  const ColoredSomething({Key key, @required this.change}) : super(key: key);

  @override
  _ColoredSomethingState createState() => _ColoredSomethingState();
}

class _ColoredSomethingState extends State<ColoredSomething> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      width: 100.0,
      color: widget.change ? Colors.red : Colors.blue,
    );
  }
}

