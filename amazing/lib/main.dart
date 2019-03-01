import 'dart:convert';
import 'dart:math';
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
  AnimationController c;
  int n;
  @override
  void initState() {
    super.initState();
    n = Random().nextInt(333);
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
      c.reverse();
    });
  }

  b() {
    n++;
    rootBundle.loadString('a/${n % 10}').then((s) {
      setState(() {
        p = jsonDecode(s).cast<double>();
        c.reset();
        c.forward();
      });
    });
  }

  g() {
    var j = Colors.primaries[n % Colors.primaries.length];
    return [j[400], j[600], j[700], j[900]];
  }

  k() => Colors.accents[(n * 3) % Colors.accents.length];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: Text("Flutter's Amazing!")),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [0.1, 0.5, 0.7, 0.9],
              colors: g(),
            ),
          ),
          child: CustomPaint(
            painter: S(p, c.value, k()),
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
  final Color k;
  S(this.p, this.t, this.k);
  @override
  bool shouldRepaint(S o) {
    return o.p != p || o.t != t || o.k != k;
  }

  void paint(Canvas c, Size s) {
    if (p == null) {
      return;
    }
    Paint a = Paint()
      ..color = k
      ..strokeCap = StrokeCap.round
      ..strokeWidth = p[0];
    var f = (i) => Offset(t * s.width * (p[i] + p[1]) + (1 - t) * 0.5 * s.width,
        t * s.height * (p[i + 1] + p[2]) + (1 - t) * 0.5 * s.height);
    for (int i = 3; i < p.length - 2; i += 4) {
      c.drawLine(f(i), f(i + 2), a);
    }
  }
}
