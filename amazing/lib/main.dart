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

class MState extends State<Maze> with SingleTickerProviderStateMixin {
  List<double> p, cv;
  AnimationController c;
  int n;
  Cubic tc, rc;
  @override
  void initState() {
    super.initState();
    n = Random().nextInt(333);
    c = AnimationController(
        duration: const Duration(milliseconds: dur), vsync: this)
      ..addListener(() => setState(() {}))
      ..addStatusListener((l) {
        if (l == AnimationStatus.completed) {
          setState(() {
            rc = null;
            c.value = 1.0;
          });
        }
        if (l == AnimationStatus.dismissed) bump();
      });
    rootBundle.loadString('a/curves.json').then((s) {
      cv = jsonDecode(s).cast<double>();
    });
    bump();
  }

  @override
  dispose() {
    c.dispose();
    super.dispose();
  }

  Cubic cf(j) {
    final k = 4 * (j % 34);
    if (cv == null || k >= cv.length) {
      return null;
    }
    return Cubic(cv[k], cv[k + 1], cv[k + 2], cv[k + 3]);
  }

  bump() {
    n++;
    rootBundle.loadString('a/${n % nMaze}.json').then((s) {
      setState(() {
        p = jsonDecode(s).cast<double>();
        tc = cf(n * 11);
        rc = cf(n * 13);
        c.reset();
        c.forward();
      });
    });
  }

  g() {
    final j = Colors.primaries[n % Colors.primaries.length];
    return [j[400], j[600], j[700], j[900]];
  }

  k() => Colors.accents[(n * 7) % Colors.accents.length];

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
            painter: _S(p, tc?.transform(c.value) ?? c.value, k(),
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

class _S extends CustomPainter {
  final List<double> p;
  final double t, r, _c, _s;
  final Color k;
  _S(this.p, this.t, this.k, this.r)
      : _c = cos(r * 2 * pi),
        _s = sin(r * 2 * pi);
  @override
  bool shouldRepaint(_S o) {
    return o.p != p || o.t != t || o.k != k || o.r != r;
  }

  void paint(Canvas c, Size s) {
    if (p == null) {
      return;
    }
    final a = Paint()
      ..color = k
      ..strokeCap = StrokeCap.round
      ..strokeWidth = p[0];
    final cx = 0.5 * s.width;
    final cy = 0.5 * s.height;
    final rot = (x, y) {
      final dx = x - cx;
      final dy = y - cy;
      return Offset(cx + dx * _c - dy * _s, cy + dy * _c + dx * _s);
    };
    final mx = 1.0 - 2.0 * p[1];
    final my = 1.0 - 2.0 * p[2];
    final sx = s.width / mx;
    final sy = s.height / my;
    final sf = min(sx, sy);
    final ox = (sx > sy) ? (cx / sf) - 0.5 : 0.0;
    final oy = (sy > sx) ? (cy / sf) - 0.5 : 0.0;
    final f = (i) => rot(t * sf * (p[i] + p[1] + ox) + (1 - t) * cx,
        t * sf * (p[i + 1] + p[2] + oy) + (1 - t) * cy);
    for (int i = 3; i < p.length - 2; i += 4) {
      c.drawLine(f(i), f(i + 2), a);
    }
  }
}
