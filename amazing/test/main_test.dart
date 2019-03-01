// Run this test with 'flutter test' in the top-level 'amazing' dir.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glob/glob.dart';

import 'package:amazing/main.dart';

void main() {
  group('Test _MState.cf', () {
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
      expect(m.cf(32), null);
      expect(m.cf(33).toString(), Cubic(0.18, 1.0, 0.04, 1.0).toString());
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
