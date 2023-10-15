extension MapExtension<K, V> on Map<K, V> {
  Map<V, K> get inverse => map((k, v) => MapEntry(v, k));
}
