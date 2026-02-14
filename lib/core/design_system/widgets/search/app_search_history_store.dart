abstract interface class AppSearchHistoryStore {
  Future<List<String>> loadHistory();

  Future<void> saveHistory(List<String> values);
}

class InMemoryAppSearchHistoryStore implements AppSearchHistoryStore {
  InMemoryAppSearchHistoryStore([List<String>? initialValues])
    : _values = List<String>.from(initialValues ?? const <String>[]);

  List<String> _values;

  @override
  Future<List<String>> loadHistory() async {
    return List<String>.from(_values);
  }

  @override
  Future<void> saveHistory(List<String> values) async {
    _values = List<String>.from(values);
  }
}
