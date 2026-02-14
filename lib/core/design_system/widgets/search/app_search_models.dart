import 'dart:async';

import 'package:flutter/widgets.dart';

typedef AppSearchSuggestionsLoader<T> =
    FutureOr<List<AppSearchSuggestion<T>>> Function(String query);
typedef AppSearchSuggestionSelected<T> =
    void Function(AppSearchSuggestion<T> suggestion);

class AppSearchSuggestion<T> {
  const AppSearchSuggestion({
    required this.label,
    this.value,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final String label;
  final T? value;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
}

enum AppSearchPanelEntryType { history, suggestion }

class AppSearchPanelEntry<T> {
  const AppSearchPanelEntry({
    required this.type,
    required this.label,
    this.subtitle,
    this.suggestion,
  });

  final AppSearchPanelEntryType type;
  final String label;
  final String? subtitle;
  final AppSearchSuggestion<T>? suggestion;

  bool get isHistory => type == AppSearchPanelEntryType.history;

  bool get isSuggestion => type == AppSearchPanelEntryType.suggestion;
}
