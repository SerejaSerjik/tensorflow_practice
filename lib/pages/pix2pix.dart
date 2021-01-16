import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class Pix2PixPage extends StatefulWidget {
  @override
  _Pix2PixPageState createState() => _Pix2PixPageState();
}

class _Pix2PixPageState extends State<Pix2PixPage> {
  List<Offset> _points = <Offset>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Tflite.close();
            Navigator.of(context).pop();
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Edges2Cats",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              RenderBox object = context.findRenderObject();
              Offset _localPosition =
                  object.globalToLocal(details.globalPosition);
              print(_localPosition);
              _points = List.from(_points)..add(_localPosition);
            });
          },
          onPanEnd: (DragEndDetails details) {
            _points.add(null);
          },
          child: CustomPaint(
            painter: EdgesPainter(points: _points),
            size: Size.infinite,
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: Icon(Icons.image),
            onPressed: () {},
            heroTag: null,
          ),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            child: Icon(Icons.clear),
            onPressed: () => _points.clear(),
            heroTag: null,
          ),
        ],
      ),
    );
  }
}

class EdgesPainter extends CustomPainter {
  List<Offset> points;

  EdgesPainter({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(EdgesPainter oldDelegate) => oldDelegate.points != points;
}
