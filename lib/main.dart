import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamController<dynamic>? _maskStreamController;
  Stream<dynamic>? _maskStream;

  @override
  void initState() {
    super.initState();
    _maskStreamController = StreamController();
    _maskStream = _maskStreamController!.stream.asBroadcastStream();
    startApplyMask();
  }

  @override
  void dispose() {
    super.dispose();
    _maskStreamController?.close();
  }

  Future startApplyMask() async {
    ImageMasking.applyMask('images/origin.png', 'images/mask.jpeg')
        .then((value) {
      if (kDebugMode) {
        print(value.toString());
      }
      _maskStreamController!.add(value);
    }).catchError((error) {
      print(error?.toString());
      _maskStreamController!.addError(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("利用遮罩实现抠图"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'images/origin.png',
              fit: BoxFit.contain,
              width: 200,
              height: 200,
            ),
            Image.asset(
              'images/mask.jpeg',
              fit: BoxFit.contain,
              width: 200,
              height: 200,
            ),
            StreamBuilder(
                stream: _maskStream,
                builder: (context, snapshot) {
                  Widget widget;
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                      if (snapshot.hasError) {
                        widget = const Text("请重试！");
                      } else {
                        widget = Image.file(File(snapshot.data.toString()),
                            fit: BoxFit.contain, width: 200, height: 200);
                      }
                      break;
                    case ConnectionState.waiting:
                      widget = const CircularProgressIndicator(
                        strokeWidth: 2.0,
                        backgroundColor: Colors.transparent,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      );
                      break;
                    default:
                      widget = Container();
                      break;
                  }
                  return widget;
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          startApplyMask();
        },
        tooltip: 'applyMask',
        child: const Icon(Icons.masks_outlined),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ImageMasking {
  static const MethodChannel maskChannel =
      MethodChannel('interview_demo/mask_channel');

  static Future<String> applyMask(
      String originalImagePath, String maskImagePath) async {
    final String result = await maskChannel.invokeMethod('applyMaskToImage', {
      'originalImagePath': originalImagePath,
      'maskImagePath': maskImagePath
    });
    return result;
  }
}
