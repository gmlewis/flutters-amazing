import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(M());

class M extends StatelessWidget {
  List<double> p;
  M() {
    rootBundle.loadString('a/0').then((s) {
      p = jsonDecode(s).cast<double>();
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: Text('Amazing')),
        body: Container(
          // margin: EdgeInsets.all(1.0),
          alignment: Alignment.topLeft,
          color: Colors.cyan,
          child: CustomPaint(
            painter: S(p),
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
    print('p.length=${p.length}, size=(${s.width},${s.height})');
    var w = 400.0;
    var h = 680.0;
    for (int i = 0; i < p.length - 2; i += 2) {
      c.drawLine(Offset(w * p[i], h * p[i + 1]),
          Offset(w * p[i + 2], h * p[i + 3]), a);
    }
  }
}
