// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library nectar.distance_measures;

double jaccardDistance(Set a, Set b) {
  return 1 - _jaccardSimilarityCoefficent(a, b);
}

/// Precise by slow implementation of Jaccard Similarilty Coefficent
/// https://en.wikipedia.org/wiki/Jaccard_index
double _jaccardSimilarityCoefficent(Set a, Set b) {
  int unionLength = a.union(b).length;
  int intersectLength = a.intersection(b).length;

  return intersectLength / unionLength;
}
