T sum<T extends num>(Iterable<T> list) {
  final isTInt = T == int;
  return list.fold((isTInt? 0 : 0.0) as T,
      (previousValue, element) => previousValue + element as T);
}

