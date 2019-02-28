import 'dart:convert';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(M());

class M extends StatefulWidget {
  @override
  _MState createState() => _MState();
}

class _MState extends State<M> with SingleTickerProviderStateMixin {
  List<double> p;
  List<Color> g;
  AnimationController c;
  int n = 0;
  @override
  void initState() {
    super.initState();
    g = [
      Colors.indigo[900],
      Colors.indigo[700],
      Colors.indigo[600],
      Colors.indigo[400],
    ];
    c = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this)
      ..addListener(() => setState(() {}))
      ..addStatusListener((l) {
        if (l == AnimationStatus.dismissed) b();
      });
    b();
  }

  i() {
    setState(() {
      n++;
      c.reverse();
    });
  }

  b() {
    rootBundle.loadString('a/${n % 10}').then((s) {
      setState(() {
        p = jsonDecode(s).cast<double>();
        c.reset();
        c.forward();
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [0.1, 0.5, 0.7, 0.9],
              colors: g,
            ),
          ),
          child: CustomPaint(
            painter: S(p, c.value),
            child: Container(width: double.infinity, height: double.infinity),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: i,
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class S extends CustomPainter {
  final List<double> p;
  final double t;
  S(this.p, this.t);
  @override
  bool shouldRepaint(S o) {
    return o.p != p || o.t != t;
  }

  void paint(Canvas c, Size s) {
    if (p == null) {
      return;
    }
    Paint a = Paint()
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;
    var f = (i) => Offset(t * 0.98 * s.width * p[i] + (1 - t) * 0.5 * s.width,
        t * 0.98 * s.height * p[i + 1] + (1 - t) * 0.5 * s.height);
    for (int i = 0; i < p.length - 2; i += 2) {
      c.drawLine(f(i), f(i + 2), a);
    }
  }
}
