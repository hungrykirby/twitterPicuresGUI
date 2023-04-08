import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

// CSV
// import 'dart:convert';
// import 'package:csv/csv.dart';
import 'dart:io';

// 環境変数
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  Future<List<String>> _readCsv() async {
    final file = File(csvPath);
    final lines = await file.readAsLines();

    List<String> imagePaths = [];
    lines.forEach((element)
    {
      imagePaths.add(element.split(',')[5]);
    });

    return imagePaths;
    // return lines.map((line) => line.split(',')).toList();
  }

  @override
  void initState() {
    super.initState();
    _initImages(); // 画像リストを初期化する
  }

  Future<void> _initImages() async {
    final paths = await _readCsv();
    setState(() {
      _imagePaths = paths;
      _images.clear();
      for (int i = 0; i < _imagePaths.length; i++) {
        _images.add(
          Image.file(
            File(_imagePaths[i]),
            fit: BoxFit.cover,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        height: 500.0,
        width: 1000.0,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 94, 94, 94),
          border: Border.all(color: Color.fromARGB(255, 40, 179, 102), width: 3),
        ),
        child: CarouselSlider(
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
      ),
    );
  }
}
