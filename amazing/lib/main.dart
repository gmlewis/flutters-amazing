// Flutter's Amazing! by Glenn M. Lewis - https://github.com/gmlewis
// This is my entry for the Flutter Create contest - March, 2019.

import 'dart:convert';
import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const dur = 1000;
const nMaze = 13;

void main() => runApp(Maze());

class Maze extends StatefulWidget {
  @override
  MState createState() => MState();
}

@visibleForTesting
class MState extends State<Maze> with SingleTickerProviderStateMixin {
  List<double> p, cv; // points and curve parameters
  AnimationController c;
  int n;
  Cubic tc, rc; // transition and rotation curves

  @override
  void initState() {
    super.initState();
    n = Random().nextInt(333);
    c = AnimationController(
        duration: const Duration(milliseconds: dur), vsync: this)
      ..addListener(() => setState(() {})) // update paint
      ..addStatusListener((l) {
        if (l == AnimationStatus.completed) {
          setState(() {
            rc = null;
            c.value = 1.0; // force rotation to completion
          });
        }
        if (l == AnimationStatus.dismissed) _bump(); // start new sequence
      });
    rootBundle.loadString('assets/curves.json').then((s) {
      cv = jsonDecode(s).cast<double>();
    });
    _bump();
  }

  @override
  dispose() {
    c.dispose();
    super.dispose();
  }

  @visibleForTesting
  Cubic cf(int j) {
    final k = 4 * (j % 34);
    if (cv == null || k >= cv.length) {
      return null;
    }
    return Cubic(cv[k], cv[k + 1], cv[k + 2], cv[k + 3]);
  }

  // _bump starts the animation process after loading a new maze.
  void _bump() {
    n++;
    rootBundle.loadString('assets/${n % nMaze}.json').then((s) {
      setState(() {
        // s = '[5.0,1.0,1.0,0.0,0.0,1.0,0.0,1.0,0.0,1.0,1.0,1.0,1.0,0.0,1.0,0.0,1.0,0.0,0.0]';
        // s = '[5.0,1.0,0.5,0.0,0.0,1.0,0.0,1.0,0.0,1.0,0.5,1.0,0.5,0.0,0.5,0.0,0.5,0.0,0.0]';
        // s = '[5.0,0.5,1.0,0.0,0.0,0.5,0.0,0.5,0.0,0.5,1.0,0.5,1.0,0.0,1.0,0.0,1.0,0.0,0.0]';
        p = jsonDecode(s).cast<double>();
        tc = cf(n * 11);
        rc = cf(n * 13);
        c.reset();
        c.forward();
      });
    });
  }

  @visibleForTesting
  List<Color> grad(double t) {
    final j = Colors.primaries[n % Colors.primaries.length];
    final lp = (i) => Color.lerp(Colors.grey[i], j[i], t);
    return [lp(400), lp(600), lp(700), lp(900)];
  }

  @visibleForTesting
  Color accent() => Colors.accents[(n * 7) % Colors.accents.length];

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
              colors: grad(c.value),
            ),
          ),
          child: CustomPaint(
            painter: _MazePaint(p, tc?.transform(c.value) ?? c.value, accent(),
                rc?.transform(c.value) ?? 0.0),
            child: Container(width: double.infinity, height: double.infinity),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => c.reverse(),
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class _MazePaint extends CustomPainter {
  final List<double> p;
  final double t, r, _cos, _sin;
  final Color lnColr;
  _MazePaint(this.p, this.t, this.lnColr, this.r)
      : _cos = cos(r * 2 * pi),
        _sin = sin(r * 2 * pi);

  @override
  bool shouldRepaint(_MazePaint o) {
    return o.p != p || o.t != t || o.lnColr != lnColr || o.r != r;
  }

  @override
  void paint(Canvas c, Size s) {
    if (p == null) {
      return;
    }
    final Paint linePaint = Paint()
      ..color = lnColr
      ..strokeCap = StrokeCap.round
      ..strokeWidth = t * p[0];
    final double cx = 0.5 * s.width, cy = 0.5 * s.height;
    final rot = (double x, double y) {
      final double dx = x - cx, dy = y - cy;
      return Offset(cx + dx * _cos - dy * _sin, cy + dy * _cos + dx * _sin);
    };
    final double sx = s.width / p[1], sy = s.height / p[2];
    final double sf = min(sx, sy);
    final double ox = cx - 0.5 * sf * p[1], oy = cy - 0.5 * sf * p[2];
    final f = (int i) => rot(t * (sf * p[i] + ox) + (1 - t) * cx,
        t * (sf * p[i + 1] + oy) + (1 - t) * cy);
    for (int i = 3; i < p.length - 2; i += 4) {
      c.drawLine(f(i), f(i + 2), linePaint);
    }
  }
}
