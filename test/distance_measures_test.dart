// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library nectar.distance_measures.test;

import 'package:test/test.dart';
import 'package:nectar/distance_measures.dart';

main() {
  test('testEqualPoints', () {
    expect(jaccardDistance(
      new Set()..addAll([0, 1, 2]),
      new Set()..addAll([0, 1, 2])), 0);
  });

  test('half', () {
    expect(jaccardDistance(
      new Set()..addAll([0, 1]),
      new Set()..addAll([0, 1, 2, 3])), 0.5);
  });

  test('quarter', () {
    expect(jaccardDistance(
      new Set()..addAll([0]),
      new Set()..addAll([0, 1, 2, 3])), 0.75);
  });

  test('max', () {
    expect(jaccardDistance(
      new Set()..addAll([10]),
      new Set()..addAll([0, 1, 2, 3])), 1);
  });

  test('maxEmpty', () {
    expect(jaccardDistance(
      new Set(),
      new Set()..addAll([0, 1, 2, 3])), 1);
  });

  test('maxBothEmpty', () {
    expect(jaccardDistance(new Set(), new Set()).isNaN, true);
  });


}
