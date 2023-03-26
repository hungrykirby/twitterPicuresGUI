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
  Widget build(BuildContext context) {
    List<Widget> images = [];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: _readCsv(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.none) {
              return CircularProgressIndicator();
            
            } else if (snapshot.connectionState == ConnectionState.active) {
              return CircularProgressIndicator();

            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text("fetch error");
              } else {
                _imagePaths = snapshot.data!;
                for(int i = 0; i < _imagePaths.length; i++ ) {
                  // images.add(File(_imagePaths[i]));
                  images.add(
                    Image.file(
                      File(_imagePaths[i]),
                      fit: BoxFit.cover
                    )
                  );
                }
                return Container(
                  height: 400.0,
                  child: CarouselSlider(
                    items: images,
                    
                    options: CarouselOptions(
                      autoPlay: false,
                      initialPage: _imageIndex,
                      enableInfiniteScroll: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _imageIndex = index;
                        });
                      }

                    ),
                  )
                );
              }
            }

            return Center(child: CircularProgressIndicator());

          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
