import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimmerView extends StatefulWidget {
  final File file;

  const TrimmerView({Key? key, required this.file}) : super(key: key);

  @override
  State<TrimmerView> createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();

  bool _isPlaying = false;
  bool _progressVisibility = false;

  double _startValue = 0.0;
  double _endValue = 0.0;

  double _startTime = -1;

  bool _drawingOpen = false;
  List<Offset> points = [];

  List<PointStoreModel> store = [];




  Future<String?> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String? _value;

    await _trimmer.saveTrimmedVideo(
        storageDir: StorageDir.externalStorageDirectory,
        startValue: _startValue,
        endValue: _endValue,
        onSave: (String? outputPath) {
          debugPrint(outputPath);
          setState(() {
            _progressVisibility = false;
            _value = outputPath;
          });
        });

    return _value;
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Visibility(
              visible: _progressVisibility,
              child: const LinearProgressIndicator(
                backgroundColor: Colors.red,
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                child: AbsorbPointer(
                  absorbing: !(_isPlaying && _drawingOpen),
                  child: Listener(
                    onPointerMove: (details) {
                      // RenderBox renderBox = context.findRenderObject();
                      Offset cursorLocation = details.localPosition;

                      if (_startTime < 0) {
                        _trimmer.videoPlayerController?.position.then((value) {
                          debugPrint(value?.inSeconds.toString());
                          if (value != null) {
                            setState(() {
                              _startTime =
                                  double.parse(value.inSeconds.toString());
                            });
                          }
                        });
                      }

                      setState(() {
                        points = List.of(points)..add(cursorLocation);
                      });
                    },
                    child: Stack(
                      children: [
                        VideoViewer(trimmer: _trimmer),
                        CustomPaint(
                            size: Size.infinite, painter: MyPainter(points))
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: TrimEditor(
                trimmer: _trimmer,
                viewerHeight: 50.0,
                viewerWidth: MediaQuery.of(context).size.width,
                maxVideoLength: const Duration(seconds: 30 * 60),
                onChangeStart: (value) {
                  _startValue = value;
                },
                onChangeEnd: (value) {
                  _endValue = value;
                },
                onChangePlaybackState: (value) {
                  if (!value) {
                    setState(() {
                      if (_drawingOpen) {
                        _drawingOpen = !_drawingOpen;
                      }
                    });
                  }
                  setState(() {
                    _isPlaying = value;
                  });
                },
              ),
            ),
            TextButton(
              child: _isPlaying
                  ? const Icon(
                      Icons.pause,
                      size: 80.0,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.play_arrow,
                      size: 80.0,
                      color: Colors.white,
                    ),
              onPressed: () async {
                bool playbackState = await _trimmer.videPlaybackControl(
                  startValue: _startValue,
                  endValue: _endValue,
                );
                setState(() {
                  _isPlaying = playbackState;
                });
              },
            )
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 15.0),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: FloatingActionButton(
                child: const Icon(Icons.clear),
                heroTag: "btn1",
                onPressed: () {
                  setState(() {
                    points = [];
                  });
                }),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: FloatingActionButton(
                heroTag: "btn2",
                child: Icon(!_drawingOpen ? Icons.draw : Icons.done),
                onPressed: () {
                  // _trimmer.videoPlayerController.
                  if (_isPlaying) {
                    setState(() {
                      _drawingOpen = !_drawingOpen;
                    });

                    if (!_drawingOpen) {
                      _trimmer.videoPlayerController!.position.then((endTime) {
                        if (endTime != null) {
                          store.add(PointStoreModel(
                              points: points,
                              startTime: _startTime,
                              endTime:
                                  double.parse(endTime.inSeconds.toString())));
                          setState(() {
                            points = [];
                            _startTime = -1;
                          });
                        }
                      });
                    }
                  }
                }),
          ),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  MyPainter(this.points);

  List<Offset> points;
  Paint paintBrush = Paint()
    ..color = Colors.blue
    ..strokeWidth = 5
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paintBrush);
    }
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) {
    return points != oldDelegate.points;
  }
}

class PointStoreModel {
  final List<Offset> points;
  final double startTime;
  final double endTime;

  PointStoreModel(
      {required this.points, required this.startTime, required this.endTime});
}
