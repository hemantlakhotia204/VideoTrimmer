import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_cut/preview_video.dart';
import 'package:video_cut/trimmer_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _progressVisibility = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Trimmer"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: _progressVisibility,
              child: const CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            ),
            ElevatedButton(
              child: const Text("LOAD VIDEO"),

              onPressed: () async {

                setState(() {
                  _progressVisibility = true;
                });

                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.video,
                  allowCompression: false,
                );
                if (result != null) {
                  File file = File(result.files.single.path!);
                  setState(() {
                    _progressVisibility = false;
                  });
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return PreviewVideo(file: file);
                    }),
                  );
                }


              },
            ),
          ],
        ),
      ),
    );
  }
}