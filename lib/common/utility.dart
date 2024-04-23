class Utility {
  /// Provide a safe way to access a nested map of a JSON object. For example, if
  /// we have a Map (or List) = Map<String, dynamic> [layer1][layer2][layer3]. Access
  /// map[layer1][layer2][layer3] will throw an exception if map[layer1][layer2] is null.
  /// Use this function to return a default value rahter than throw an exception.
  /// 
  /// Usage: safeAccess(nested, ['names', 0, 'songs'], 'Default Value')
  static dynamic safeAccess(dynamic nested, Iterable<dynamic> keys, dynamic defaultTo) {
    dynamic current = nested;
    for (final dynamic key in keys) {
      try {
        current = current[key];
      }
      catch (e) {
        // current is null or indexing operation on current failed
        return defaultTo;
      }
    }

    return current;
  }
}