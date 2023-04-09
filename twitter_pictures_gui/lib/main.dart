import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

// CSV
// import 'dart:convert';
// import 'package:csv/csv.dart';
import 'dart:io';

// 環境変数
import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'package:flutter/foundation.dart';
// enable keyboard input
import 'package:flutter/services.dart';

Future<void> main() async {
  await dotenv.load();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twitter images',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'You can choose you image'),
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
  int _counter = 0;
  int _imageIndex = 0;
  double _imageWidth = 0;

  String csvPath = dotenv.env['CSV_PATH']!;

  String csvData = 'loading';

  List<List<String>> _tweet = [];
  List<String> _imagePaths = [];
  final List<Widget> _images = []; // 画像を格納するリスト


  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _incrementImageIndex() {
    setState(() {
      if (_imageIndex < _imagePaths.length - 1) {
        _imageIndex++;
      }
    });
  }

  void _decrementImageIndex() {
    setState(() {
      if (_imageIndex > 0) {
        _imageIndex--;
      }
    });
  }

  Future<List<List<String>>> _readCsv() async {
    final file = File(csvPath);
    final lines = await file.readAsLines();

    List<List<String>> imageData = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      List<String> imageInfo = line.split(',');
      imageData.add(imageInfo);
    };

    return imageData;
  }

  @override
  void initState() {
    super.initState();
    _initImages(); // 画像リストを初期化する
  }

  Future<void> _initImages() async {
    final readCsvData = await _readCsv();
    setState(() {
      _tweet = readCsvData;
      _images.clear();
      for (int i = 0; i < _tweet.length; i++) {
        String ipath = _tweet[i][5];
        _images.add(
          Image.file(
            File(ipath),
            fit: BoxFit.cover,
          ),
        );
      }
    });
  }

  final imageFrameBackgroundColor = const Color.fromARGB(255, 94, 94, 94);
  final imageBorderColor = const Color.fromARGB(255, 40, 179, 102);
  final imageIndexStyle = const TextStyle(fontSize: 20, color: Colors.white);
  final imageFilePathStyle = const TextStyle(fontSize: 12, color: Colors.white);

  DateTime _lastEventTime = DateTime(0); // 最後に処理されたイベントの時刻 キーボード入力が重複するため回避策
  final keyDuration = const Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
           final currentTime = DateTime.now();
            final deltaTime = currentTime.difference(_lastEventTime);
            if (deltaTime > keyDuration) {
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                setState(() {
                  _imageIndex = (_imageIndex - 1) % _images.length;
                });
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                setState(() {
                  _imageIndex = (_imageIndex + 1) % _images.length;
                });
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                setState(() {
                  _imageIndex = 0;
                });
              } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                setState(() {
                  _imageIndex = _images.length - 1;
                });
              }
              _lastEventTime = currentTime;
            }
        },
        child: Container(
          height: 500.0,
          width: 800.0,
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: imageFrameBackgroundColor,
            border: Border.all(color: imageBorderColor, width: 3),
          ),
          child: Column(
            children: [
              CarouselSlider(
                items: _images,
                key: UniqueKey(),
                options: CarouselOptions(
                  autoPlay: false,
                  initialPage: _imageIndex,
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _imageIndex = index;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_imageIndex',
                    style: imageIndexStyle,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _tweet[_imageIndex][5],
                    style: imageFilePathStyle,
                  )
                ],
              )
            ],
          )
        )
      ),
    );
  }
}
