// Run this test with 'flutter test' in the top-level 'amazing' dir.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glob/glob.dart';

import 'package:amazing/main.dart';

void main() {
  group('Test MState.cf', () {
    test('cv should start uninitialized', () {
      final m = MState();
      expect(m.cv, null);
    });

    test('cf should return null on start', () {
      final m = MState();

      expect(m.cf(0), null);
      expect(m.cf(1), null);
      expect(m.cf(2), null);
      expect(m.cf(3), null);
      expect(m.cf(4), null);
    });

    test('cf should return Cubics with populated cv', () async {
      final m = MState();
      final s = await getAsset('curves.json');
      m.cv = jsonDecode(s).cast<double>();

      expect(m.cv.length, 32 * 4);
      expect(m.cf(0).toString(), Cubic(0.18, 1.0, 0.04, 1.0).toString());
      expect(m.cf(31).toString(), Cubic(0.4, 0.0, 0.2, 1.0).toString());
      expect(m.cf(32), null); // Chance of 2 out of 34 for no transition.
      expect(m.cf(33), null);
      expect(m.cf(34).toString(), Cubic(0.18, 1.0, 0.04, 1.0).toString());
    });
  });

  group('Test MState.grad', () {
    test('grad(t=0) should be grey for all n', () {
      final m = MState();
      final MaterialColor g = Colors.grey;
      final String want = [g[400], g[600], g[700], g[900]].toString();
      for (m.n = 0; m.n < Colors.primaries.length; m.n++) {
        expect(m.grad(0).toString(), want);
      }
    });

    test('grad(t=1) should be the primary color for all n', () {
      final m = MState();
      for (m.n = 0; m.n < Colors.primaries.length; m.n++) {
        final MaterialColor g = Colors.primaries[m.n];
        final String want = [g[400], g[600], g[700], g[900]].toString();
        expect(m.grad(1).toString(), want);
      }
    });
  });

  group('Test MState.accent', () {
    test('accent should be the correct accent color for all n', () {
      final m = MState();
      for (m.n = 0; m.n < Colors.accents.length; m.n++) {
        final i = (m.n * 7) % Colors.accents.length;
        final MaterialAccentColor want = Colors.accents[i];
        expect(m.accent().toString(), want.toString());
      }
    });

    test('all possible accent colors are used', () {
      final m = MState();
      final used = Set<int>();
      for (m.n = 0; m.n < Colors.accents.length; m.n++) {
        final i = (m.n * 7) % Colors.accents.length;
        used.add(i);
      }
      expect(used.length, Colors.accents.length);
    });
  });
}

Future<String> getAsset(String name) async {
  await for (final path in Glob(name).list(root: '../a')) {
    if (path is File) {
      return path.readAsString();
    }
  }
  return Future.value("");
}
