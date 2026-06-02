class UnlockedPacksCache {
  UnlockedPacksCache._();

  static final Set<String> _ids = <String>{};

  static bool contains(String id) => _ids.contains(id);

  static void add(String id) => _ids.add(id);

  static void remove(String id) => _ids.remove(id);

  static void clear() => _ids.clear();
}
