import 'dart:convert';
import 'dart:math';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(M());

class M extends StatefulWidget {
  @override
  MState createState() => MState();
}

class MState extends State<M> with SingleTickerProviderStateMixin {
  List<double> p, cv;
  AnimationController c;
  int n;
  Cubic tc, rc;
  @override
  void initState() {
    super.initState();
    n = Random().nextInt(333);
    c = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this)
      ..addListener(() => setState(() {}))
      ..addStatusListener((l) {
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

  inc() {
    setState(() {
      c.reverse();
    });
  }

  Cubic cf(j) {
    final k = 4 * (j % (1 + (cv?.length ?? 0) / 4));
    if (cv == null || k == cv.length) {
      return null;
    }
    return Cubic(cv[k], cv[k + 1], cv[k + 2], cv[k + 3]);
  }

  bump() {
    n++;
    rootBundle.loadString('a/${n % 10}.json').then((s) {
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
            painter: S(p, tc?.transform(c.value) ?? c.value, k(),
                rc?.transform(c.value) ?? c.value),
            child: Container(width: double.infinity, height: double.infinity),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: inc,
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class S extends CustomPainter {
  final List<double> p;
  final double t, r, _c, _s;
  final Color k;
  S(this.p, this.t, this.k, this.r)
      : _c = cos(r * 2 * pi),
        _s = sin(r * 2 * pi);
  @override
  bool shouldRepaint(S o) {
    return o.p != p || o.t != t || o.k != k || o._c != _c || o._s != _s;
  }

  void paint(Canvas c, Size s) {
    if (p == null) {
      return;
    }
    final a = Paint()
      ..color = k
      ..strokeCap = StrokeCap.round
      ..strokeWidth = p[0];
    final double cx = 0.5 * s.width;
    final double cy = 0.5 * s.height;
    final r = (x, y) {
      final dx = x - cx;
      final dy = y - cy;
      return Offset(cx + dx * _c - dy * _s, cy + dy * _c + dx * _s);
    };
    final f = (i) => r(t * s.width * (p[i] + p[1]) + (1 - t) * cx,
        t * s.height * (p[i + 1] + p[2]) + (1 - t) * cy);
    for (int i = 3; i < p.length - 2; i += 4) {
      c.drawLine(f(i), f(i + 2), a);
    }
  }
}
