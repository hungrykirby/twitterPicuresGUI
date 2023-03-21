import 'package:flutter/material.dart';

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

  String csvPath = dotenv.env['CSV_PATH']!;

  String csvData = 'loading';

   List<String> _imagePaths = [];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<List<String>> _readCsv() async {
    final file = File(csvPath);
    final lines = await file.readAsLines();
    // csvData = lines.join('\n');
    // csvData = csvPath;
    List<String> imagePaths = [];
    lines.forEach((element)
    {
      imagePaths.add(element.split(',')[5]);
      // print(element.split(',')[5]);
    });
    return imagePaths;
    // return lines.map((line) => line.split(',')).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: _readCsv(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            _imagePaths = snapshot.data!;
            return ListView.builder(
              itemCount: _imagePaths.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_imagePaths[index]),
                  leading: Image.file(
                    File(_imagePaths[index]),
                    width: 300,
                  ),
                );
              },
            );
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
