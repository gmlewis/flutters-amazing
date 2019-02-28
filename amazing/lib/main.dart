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
  Animation<double> a;
  AnimationController c;
  @override
  void initState() {
    super.initState();
    c = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    a = Tween<double>().animate(c)
      ..addListener(() {
        setState(() {});
      });
    rootBundle.loadString('a/0').then((s) {
      setState(() {
        p = jsonDecode(s).cast<double>();
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
          color: Colors.cyan,
          child: CustomPaint(
            painter: S(p, c.value),
            child: Container(width: double.infinity, height: double.infinity),
          ),
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
