import 'dart:ui';

import 'package:flipart/models/drawing_point.dart';
import 'package:flipart/models/frame.dart';
import 'package:flipart/widgets/draw_painter.dart';
import 'package:flipart/widgets/rounded_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

enum SelectedMode { StrokeWidth, Opacity, Color }

class DrawContainer extends StatefulWidget {
  final Frame frame;
  final Frame previousFrame;
  final double height;
  final double width;
  final ValueChanged<DrawingPoint> onNewPoint;
  final VoidCallback onUndo;

  const DrawContainer({
    Key key,
    @required this.frame,
    this.previousFrame,
    @required this.height,
    @required this.width,
    @required this.onNewPoint,
    @required this.onUndo,
  }) : super(key: key);

  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<DrawContainer> {
  Color _selectedColor = Colors.black;
  double _opacity = 1.0;
  double _strokeWidth = 3.0;

  Color _pickerColor = Colors.black;
  bool _showBottomList = false;

  SelectedMode _selectedMode = SelectedMode.StrokeWidth;
  List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black
  ];

  void onDraw(Offset globalPosition) {
    RenderBox renderBox = context.findRenderObject();
    widget.onNewPoint(DrawingPoint(
      point: renderBox.globalToLocal(globalPosition),
      paint: Paint()
        ..strokeCap = StrokeCap.round
        ..color = _selectedColor.withOpacity(_opacity)
        ..isAntiAlias = true
        ..strokeWidth = _strokeWidth,
    ));
  }

  void onTabSelect(SelectedMode tabMode) {
    setState(() {
      if (_selectedMode == tabMode)
        _showBottomList = !_showBottomList;
      else {
        _showBottomList = true;
      }
      _selectedMode = _showBottomList ? tabMode : null;
    });
  }

  IconButton _buildBtn(IconData icon, SelectedMode mode) {
    return IconButton(
      icon: Icon(
        icon,
        color: (_selectedMode == mode) ? Colors.white : Colors.white,
        size: (_selectedMode == mode) ? 26 : 24,
      ),
      onPressed: () => onTabSelect(mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: widget.width,
          height: widget.height,
          margin: const EdgeInsets.only(top: 10.0),
          child: RoundedCard(
            elevation: 4.0,
            margin: EdgeInsets.zero,
            child: ClipRect(
              child: GestureDetector(
                onPanUpdate: (details) => onDraw(details.globalPosition),
                onPanEnd: (_) => widget.onNewPoint(null),
                child: CustomPaint(
                  size: Size(widget.width, widget.height),
                  foregroundPainter: widget.previousFrame != null
                      ? DrawingPainter(
                          frame: widget.previousFrame,
                          isTransparent: true,
                        )
                      : null,
                  painter: DrawingPainter(frame: widget.frame),
                ),
              ),
            ),
          ),
        ),
        RoundedCard(
          margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
          borderRadius: 15.0,
          backgroundColor: Colors.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBtn(Icons.album, SelectedMode.StrokeWidth),
                  _buildBtn(Icons.opacity, SelectedMode.Opacity),
                  _buildBtn(Icons.color_lens, SelectedMode.Color),
                  IconButton(
                    icon: const Icon(Icons.undo, color: Colors.white),
                    onPressed: widget.frame.points.isNotEmpty
                        ? () {
                            setState(() => _showBottomList = false);
                            widget.onUndo();
                          }
                        : null,
                  ),
                ],
              ),
              if (_showBottomList && _selectedMode == SelectedMode.Color)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: getColorList(),
                  ),
                ),
              if (_showBottomList && _selectedMode != SelectedMode.Color)
                SliderTheme(
                  data: SliderThemeData(
                    valueIndicatorTextStyle: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  child: Slider(
                    value: _selectedMode == SelectedMode.StrokeWidth
                        ? _strokeWidth
                        : _opacity,
                    max: _selectedMode == SelectedMode.StrokeWidth ? 50.0 : 1.0,
                    min: 0.0,
                    label: _selectedMode == SelectedMode.StrokeWidth
                        ? "${_strokeWidth.round()}px"
                        : "${(_opacity * 100).round()}%",
                    divisions: 50,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white38,
                    onChanged: (val) {
                      if (_selectedMode == SelectedMode.StrokeWidth)
                        setState(() => _strokeWidth = val);
                      else
                        setState(() => _opacity = val);
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> getColorList() {
    return [
      for (Color color in _colors) colorCircle(color),
      GestureDetector(
        onTap: () {
          _pickerColor = _selectedColor;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Color picker'),
              contentPadding: const EdgeInsets.only(top: 16.0),
              content: SingleChildScrollView(
                child: ColorPicker(
                  enableAlpha: false,
                  displayThumbColor: true,
                  pickerColor: _pickerColor,
                  onColorChanged: (color) => _pickerColor = color,
                  showLabel: false,
                ),
              ),
              actions: [
                FlatButton(
                  child: const Text("Done"),
                  onPressed: () {
                    setState(() => _selectedColor = _pickerColor);
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        },
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: 36.0,
            width: 36.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: LinearGradient(
                colors: [Colors.red, Colors.green, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Material(
        elevation: 2,
        color: color,
        type: MaterialType.circle,
        child: SizedBox(height: 36, width: 36.0),
      ),
    );
  }
}
