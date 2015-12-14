// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library nectar.clusterers;

import 'dart:math';

/// K Medoids has a higher computational cost than k-means but returns actual
/// items, and can work with non-euclidan distance measures
/// Partitioning Around Medoids, Kaufmann & Rousseeuw 1987 is the original
/// The implementation here is similar to the one outlined in:
/// https://en.wikipedia.org/wiki/K-medoids
class KMedoids {
  List<DataItem> _data;
  List<Cluster> clusters = [];

  KMedoids(this._data, [int clusterCount]) {
    if (clusterCount == null) {
      clusterCount = sqrt(_data.length/2).ceil();
    }
    _init(clusterCount);
  }

  _init(int clusterCount) {
    _data.shuffle();

    // Assign the clusters
    for (int i = 0; i < clusterCount; i++) {
      clusters.add(new Cluster(_data[i], [_data[i]]));
    }

    // Assign the rest of the data points with minimum distance
    for (int i = clusterCount; i < _data.length; i++) {
      _findNearestCluster(_data[i]).dataItems.add(_data[i]);
    }
  }

  Cluster _findNearestCluster(DataItem item) {
    List<double> distances = clusters.map(
      (c) => c.medoid.computeDistanceTo(item)).toList();

    int minI = -1;
    double minSeen = double.MAX_FINITE;

    for (int i = 0; i < distances.length; i++) {
      if (distances[i] < minSeen) {
        minSeen = distances[i];
        minI = i;
      }
    }
    return clusters[minI];
  }

  bool step() {
    double startingCost = cost;
    for (Cluster c1 in clusters) {
      for (Cluster c2 in clusters) {
        for (DataItem d in c2.dataItems.toList()) {
          if (c1.medoid == d || c2.medoid == d) continue;

        	double beforeSwap = cost;
          DataItem exchanged = _swap(c1, c2, d);
        	double afterSwap = cost;

          if (afterSwap > beforeSwap) {
            // If the swap made things worse, undo
            _swap(c1, c2, exchanged);
          }
        }
      }
    }

    // Wipe the clusters
    List<DataItem> medoids = [];

    for (Cluster c in clusters) {
      c.dataItems.clear();
      c.dataItems.add(c.medoid);
      medoids.add(c.medoid);
    }

    for (DataItem di in _data) {
      if (medoids.contains(di)) continue;
      _findNearestCluster(di).dataItems.add(di);
    }

    double finalCost = cost;

    if (finalCost < startingCost) return true; // Improvement
    if (finalCost - startingCost > 0.000001) throw "Things got worse!";
    return false; // No change, we're done here
  }

  /// Swap the passed data item in cluster 2 to medoid of c1
  /// Returning the item that was displaced
  DataItem _swap(Cluster c1, Cluster c2, DataItem d2) {
    if (c2.medoid == d2) throw "Can't swap out a mediod";

    DataItem d1 = c1.medoid;

    c1.medoid = d2;
    c1.dataItems.remove(d1);
    c1.dataItems.add(d2);

    c2.dataItems.remove(d2);
    c2.dataItems.add(d1);

    return d1;
  }

  bool isMedoid(DataItem d) => clusters.any((c) => c.medoid == d);

  // TODO: This is expensive, we should probably be caching the x->y cost
  // computations
  double get cost => clusters.fold(0.0, (d, c) => d + c.cost);
}

class DataItem {
  final dynamic data;
  final dynamic distanceMeasure;

  const DataItem(this.data, this.distanceMeasure);

  double computeDistanceTo(dynamic other) => distanceMeasure(this, other);

  String toString() {
    return data.toString();
  }
}

class Cluster {
  DataItem medoid;
  List<DataItem> dataItems;

  Cluster(this.medoid, this.dataItems);

  double get cost {
    double costAcc = 0.0;
    for (DataItem item in dataItems) {
      costAcc += item.computeDistanceTo(medoid);
    }
    return costAcc;
  }

  String toString() {
    StringBuffer sb = new StringBuffer();
    sb.write("Medoid: $medoid\n");
    sb.write("Data: $dataItems\n");

    return sb.toString();
  }

}
