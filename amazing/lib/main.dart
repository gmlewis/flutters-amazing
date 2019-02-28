import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(M());

class M extends StatefulWidget {
  @override
  _MState createState() => _MState();
}

class _MState extends State<M> {
  List<double> p;
  @override
  void initState() {
    super.initState();
    rootBundle.loadString('a/0').then((s) {
      setState(() {
        p = jsonDecode(s).cast<double>();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: Text('Amazing')),
        body: Container(
          alignment: Alignment.topLeft,
          color: Colors.cyan,
          child: CustomPaint(
            painter: S(p),
            child: Container(width: double.infinity, height: double.infinity),
          ),
        ),
      ),
    );
  }
}

class S extends CustomPainter {
  final List<double> p;
  S(this.p);
  @override
  bool shouldRepaint(S o) {
    return o.p != p;
  }

  void paint(Canvas c, Size s) {
    if (p == null) {
      return;
    }
    Paint a = Paint()
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;
    var w = 0.98 * s.width;
    var h = 0.98 * s.height;
    for (int i = 0; i < p.length - 2; i += 2) {
      c.drawLine(Offset(w * p[i], h * p[i + 1]),
          Offset(w * p[i + 2], h * p[i + 3]), a);
    }
  }
}
