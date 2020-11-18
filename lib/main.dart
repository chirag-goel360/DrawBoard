import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(
  DrawApp(),
);

class DrawApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Drawer(),
    );
  }
}

class Drawer extends StatefulWidget {
  @override
  _DrawerState createState() => _DrawerState();
}

class _DrawerState extends State<Drawer> {
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;
  List<DrawingPoints> points = List();
  bool showBottomList = false;
  double opacity = 1.0;
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [
    Colors.purple,
    Colors.indigo,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red,
    Colors.black,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8),
        child: Container(
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.blue.shade300,
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.brush_sharp,
                        ),
                        onPressed:() {
                          setState(() {
                            if(selectedMode == SelectedMode.StrokeWidth)
                              showBottomList = !showBottomList;
                            selectedMode = SelectedMode.StrokeWidth;
                          });
                        }
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.opacity,
                        ),
                        onPressed:() {
                          setState(() {
                            if(selectedMode == SelectedMode.Opacity)
                              showBottomList = !showBottomList;
                            selectedMode = SelectedMode.Opacity;
                          });
                        }
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.color_lens_outlined,
                        ),
                        onPressed:() {
                          setState(() {
                            if(selectedMode == SelectedMode.Color)
                              showBottomList = !showBottomList;
                            selectedMode = SelectedMode.Color;
                          });
                        }
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                        ),
                        onPressed:() {
                          setState(() {
                            showBottomList = false;
                            points.clear();
                          });
                        }
                    ),
                  ],
                ),
                Visibility(
                  child:(selectedMode == SelectedMode.Color) ?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: getColorList(),
                  ) :
                  Slider(
                    value:(selectedMode == SelectedMode.StrokeWidth) ? strokeWidth : opacity,
                    max:(selectedMode == SelectedMode.StrokeWidth) ? 50.0 : 1.0,
                    min: 0.0,
                    onChanged:(val) {
                      setState(() {
                        if(selectedMode == SelectedMode.StrokeWidth)
                          strokeWidth = val;
                        else
                          opacity = val;
                      });
                    },
                  ),
                  visible: showBottomList,
                ),
              ],
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onPanUpdate:(details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject();
            points.add(
              DrawingPoints(
                  points: renderBox.globalToLocal(
                    details.globalPosition,
                  ),
                  paint: Paint()
                    ..strokeCap = strokeCap
                    ..isAntiAlias = true
                    ..color = selectedColor.withOpacity(opacity)
                    ..strokeWidth = strokeWidth
              ),
            );
          });
        },
        onPanStart:(details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject();
            points.add(
              DrawingPoints(
                  points: renderBox.globalToLocal(
                    details.globalPosition,
                  ),
                  paint: Paint()
                    ..strokeCap = strokeCap
                    ..isAntiAlias = true
                    ..color = selectedColor.withOpacity(opacity)
                    ..strokeWidth = strokeWidth
              ),
            );
          });
        },
        onPanEnd:(details) {
          setState(() {
            points.add(null);
          });
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: DrawCreater(
            pointsList: points,
          ),
        ),
      ),
    );
  }

  getColorList() {
    List<Widget> listWidget = List();
    for(Color color in colors) {
      listWidget.add(
        colorCircle(color),
      );
    }
    Widget colorPicker = GestureDetector(
      onTap:() {
        showDialog(
          context: context,
          child: AlertDialog(
            title: Text(
              'Pick a color',
            ),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged:(color) {
                  pickerColor = color;
                },
                showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Save',
                ),
                onPressed:() {
                  setState(() {
                    selectedColor = pickerColor;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
      child: ClipOval(
        child: Container(
          padding: EdgeInsets.only(
            bottom: 16.0,
          ),
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red,
                Colors.green,
                Colors.blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
    listWidget.add(colorPicker);
    return listWidget;
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap:() {
        setState(() {
          selectedColor = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: EdgeInsets.only(
            bottom: 16.0,
          ),
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }
}

class DrawCreater extends CustomPainter {
  DrawCreater({this.pointsList});
  List<DrawingPoints> pointsList;
  List<Offset> offsetPoints = List();

  @override
  void paint(Canvas canvas, Size size) {
    for(int i=0; i < pointsList.length-1; i++) {
      if(pointsList[i] != null && pointsList[i+1] != null) {
        canvas.drawLine(
          pointsList[i].points,
          pointsList[i+1].points,
          pointsList[i].paint,
        );
      }
      else if(pointsList[i] != null && pointsList[i+1] == null) {
        offsetPoints.clear();
        offsetPoints.add(
          pointsList[i].points,
        );
        offsetPoints.add(
          Offset(
            pointsList[i].points.dx+0.1,
            pointsList[i].points.dy + 0.1,
          ),
        );
        canvas.drawPoints(
          PointMode.points,
          offsetPoints,
          pointsList[i].paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DrawCreater oldDelegate) => true;
}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({this.points, this.paint});
}

enum SelectedMode {
  StrokeWidth,
  Opacity,
  Color,
}