// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
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
      // run this test with 'flutter test' in the top-level dir.
      final assetBundle =
          await DiskAssetBundle.loadGlob(['curves.json'], from: '../a');

      final m = MState();
      final s = await assetBundle.load('a/curves.json');
      print('s=$s');
      m.cv = jsonDecode(s.toString()).cast<double>();

      expect(m.cv.length, 32 * 4);
    });
  });
}

// Many thanks to @matanlurey: https://github.com/flutter/flutter/issues/12999
/// A simple implementation of [AssetBundle] that reads files from an asset dir.
///
/// This is meant to be similar to the default [rootBundle] for testing.
class DiskAssetBundle extends CachingAssetBundle {
  static const _assetManifestDotJson = 'AssetManifest.json';

  /// Creates a [DiskAssetBundle] by loading [globs] of assets under `assets/`.
  static Future<AssetBundle> loadGlob(
    Iterable<String> globs, {
    String from = 'assets',
  }) async {
    final cache = <String, ByteData>{};
    for (final pattern in globs) {
      await for (final path in Glob(pattern).list(root: from)) {
        if (path is File) {
          final bytes = await path.readAsBytes() as Uint8List;
          cache[path.path] = ByteData.view(bytes.buffer);
        }
      }
    }
    final manifest = <String, List<String>>{};
    cache.forEach((key, _) {
      manifest[key] = [key];
    });

    cache[_assetManifestDotJson] = ByteData.view(
      Uint8List.fromList(jsonEncode(manifest).codeUnits).buffer,
    );

    return DiskAssetBundle._(cache);
  }

  final Map<String, ByteData> _cache;

  DiskAssetBundle._(this._cache);

  @override
  Future<ByteData> load(String key) async {
    return _cache[key];
  }
}
