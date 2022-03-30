import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_cut/element_painter.dart';
import 'package:video_cut/models/data_model.dart';
import 'package:video_cut/models/element_model.dart';
import 'package:video_cut/models/properties_model.dart';
import 'package:video_trimmer/video_trimmer.dart';

class PreviewVideo extends StatefulWidget {
  final File file;

  const PreviewVideo({Key? key, required this.file}) : super(key: key);

  @override
  State<PreviewVideo> createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<PreviewVideo>
    with TickerProviderStateMixin {
  final Trimmer _trimmer = Trimmer();

  bool _isPlaying = false;

  double _startValue = 0.0;
  double _endValue = 0.0;

  List<List<Offset>> points = [];

  Map<String, dynamic> json = {
    "elements": [
      {
        "key": "line",
        "properties": {
          "startFrame": 2.4,
          "endFrame": 7.5,
          "startCoor": [213.0, 700.0],
          "endCoor": [756.0, 453.0]
        }
      },
      {
        "key": "ellipse",
        "properties": {
          "startFrame": 1.0,
          "endFrame": 12.0,
          "centerCoor": [213, 235],
          "radius": 50
        }
      }
    ]
  };

  late DataModel dataModel;
  List<int> milliseconds = [];

  late Animation<Offset> lineAnimation;
  late Animation<double> rotAnimation;

  List<AnimationController> controllers = [];

  Offset? _lineFraction;
  double? _rotFraction;

  @override
  void initState() {
    super.initState();

    dataModel = DataModel.fromJson(json);

    List<ElementModel> elementModels = dataModel.elements;

    for (int i = 0; i < elementModels.length; i++) {
      PropertiesModel propertiesModel = elementModels[i].properties;
      milliseconds.add(
          ((propertiesModel.endFrame - propertiesModel.startFrame) * 1000)
              .toInt());

      controllers.add(AnimationController(
          vsync: this, duration: Duration(milliseconds: milliseconds[i])));

      switch (elementModels[i].key) {
        case 'line':
          points.add([
            Offset(
                propertiesModel.startCoor![0], propertiesModel.startCoor![1]),
            Offset(propertiesModel.endCoor![0], propertiesModel.endCoor![1])
          ]);

          lineAnimation = Tween(begin: points[i].first, end: points[i].last)
              .animate(controllers[i])
            ..addListener(() {
              if (_isPlaying) {
                setState(() {
                  _lineFraction = lineAnimation.value;
                });
              }
            })
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                controllers[i].stop();
              }
            });
          break;
        case 'ellipse':
          rotAnimation = Tween(begin: 0.0, end: math.pi * 2).animate(
              CurvedAnimation(parent: controllers[i], curve: Curves.linear))
            ..addListener(() {
              if (_isPlaying) {
                setState(() {
                  _rotFraction = rotAnimation.value;
                });
              }
            })
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                controllers[i].reset();
                controllers[i].forward();
              }
            });

          break;
      }
    }

    _loadVideo();
  }

  ///Can be used in onPlay and onStop
//   if (_animationController.isAnimating) {
//   _animationController.stop();
//   } else {
//   _animationController.reset();
//   _animationController.forward();
//   }
// }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  @override
  void dispose() {
    for (var element in controllers) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPlaying) {
      for (int i = 0; i < dataModel.elements.length; i++) {
        Future.delayed(
            Duration(
                milliseconds:
                    (dataModel.elements[i].properties.startFrame * 1000)
                        .toInt()), () {
          controllers[i].forward();
        });
      }
    } else {
      for (var element in controllers) {
        element.stop();
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                children: [
                  VideoViewer(
                    trimmer: _trimmer,
                  ),
                  Stack(
                    children: drawings(),
                  )
                ],
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
    );
  }

  List<Widget> drawings() {
    List<Widget> drawings = [];

    for (int i = 0; i < dataModel.elements.length; i++) {
      switch (dataModel.elements[i].key) {
        case 'line':
          drawings.add(CustomPaint(
            size: Size.infinite,
            painter: ElementPainter(
                lineFraction: _lineFraction,
                points: points[i],
                key: dataModel.elements[i].key),
          ));
          break;
        case 'ellipse':
          // drawings.add(RotationTransition(
          //   turns: rotAnimation,
          //   child: CustomPaint(
          //     size: Size.infinite,
          //     painter: ElementPainter(
          //       rotFraction: rotAnimation.value,
          //       key: dataModel.elements[i].key,
          //       radius: dataModel.elements[i].properties.radius,
          //       center: Offset(dataModel.elements[i].properties.centerCoor![0],
          //           dataModel.elements[i].properties.centerCoor![1]),
          //     ),
          //   ),
          // ));
          drawings.add(AnimatedBuilder(
              animation: rotAnimation,
              child: CustomPaint(
                size: Size.infinite,
                painter: ElementPainter(
                  // lineFraction: _lineFraction!,
                  // points: points[i],
                  key: dataModel.elements[i].key,
                  radius: dataModel.elements[i].properties.radius,
                  center: Offset(
                      dataModel.elements[i].properties.centerCoor![0],
                      dataModel.elements[i].properties.centerCoor![1]),
                ),
              ),
              builder: (context, child)  {
                RenderObject? object =  context.findRenderObject();
                // RenderBox box = object!.

                return Transform.rotate(
                  angle: rotAnimation.value,
                  child: child,
                  origin: Offset(
                    dataModel.elements[i].properties.centerCoor![0],
                    dataModel.elements[i].properties.centerCoor![1]
                  ),
                );
              }));
          break;
        default:
          drawings.add(const SizedBox());
      }
    }

    return drawings;
  }
}
