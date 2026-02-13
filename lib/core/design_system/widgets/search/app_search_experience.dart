import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/system/motion_durations.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/radii.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';

typedef AppSearchSuggestionsLoader<T> =
    FutureOr<List<AppSearchSuggestion<T>>> Function(String query);
typedef AppSearchSuggestionSelected<T> =
    void Function(AppSearchSuggestion<T> suggestion);

const appSearchExperienceBarKey = Key('app_search_experience_bar');
const appSearchExperienceClearButtonKey = Key('app_search_experience_clear');

Key appSearchExperienceHistoryItemKey(String value) {
  return Key('app_search_experience_history_$value');
}

Key appSearchExperienceSuggestionItemKey(String label) {
  return Key('app_search_experience_suggestion_$label');
}

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

class AppSearchExperience<T> extends StatefulWidget {
  const AppSearchExperience({
    super.key,
    this.controller,
    this.focusNode,
    this.initialQuery,
    this.placeholder,
    this.enabled = true,
    this.autofocus = false,
    this.debounceDuration = MotionDurations.long,
    this.minQueryLength = 1,
    this.isLoading = false,
    this.enableHistory = true,
    this.historyLimit = 10,
    this.historyStore,
    this.noResultsText,
    this.suggestionsLoader,
    this.onQueryChanged,
    this.onQuerySubmitted,
    this.onSuggestionSelected,
    this.onCleared,
  }) : assert(historyLimit > 0, 'historyLimit must be greater than zero.'),
       assert(
         minQueryLength >= 0,
         'minQueryLength must be greater than or equal to zero.',
       ),
       assert(
         debounceDuration >= Duration.zero,
         'debounceDuration must be non-negative.',
       );

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialQuery;
  final String? placeholder;
  final bool enabled;
  final bool autofocus;
  final Duration debounceDuration;
  final int minQueryLength;
  final bool isLoading;
  final bool enableHistory;
  final int historyLimit;
  final AppSearchHistoryStore? historyStore;
  final String? noResultsText;
  final AppSearchSuggestionsLoader<T>? suggestionsLoader;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<String>? onQuerySubmitted;
  final AppSearchSuggestionSelected<T>? onSuggestionSelected;
  final VoidCallback? onCleared;

  @override
  State<AppSearchExperience<T>> createState() => _AppSearchExperienceState<T>();
}

class _AppSearchExperienceState<T> extends State<AppSearchExperience<T>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _debounceTimer;
  int _requestId = 0;
  bool _suppressNextTextChange = false;
  bool _isLoadingSuggestions = false;

  List<AppSearchSuggestion<T>> _suggestions = <AppSearchSuggestion<T>>[];
  List<String> _history = const <String>[];

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialQuery);
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    unawaited(_loadHistory());
  }

  @override
  void didUpdateWidget(covariant AppSearchExperience<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller =
          widget.controller ??
          TextEditingController(
            text: widget.initialQuery ?? oldWidget.initialQuery ?? '',
          );
      _controller.addListener(_onTextChanged);
    }

    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
    }

    if (oldWidget.historyStore != widget.historyStore ||
        oldWidget.enableHistory != widget.enableHistory ||
        oldWidget.historyLimit != widget.historyLimit) {
      unawaited(_loadHistory());
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _normalizedQuery;
    final showPanel = _focusNode.hasFocus && _hasPanelContent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchBar(
          key: appSearchExperienceBarKey,
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          hintText: widget.placeholder ?? context.l10n.fieldSearchHint,
          onChanged: (_) {},
          onSubmitted: _onSubmitted,
          leading: const Icon(Icons.search),
          trailing: _buildTrailing(query),
          textInputAction: TextInputAction.search,
          autoFocus: widget.autofocus,
        ),
        if (showPanel) ...[
          const SizedBox(height: AppSpacing.space8),
          _SearchPanel(
            loadingText: context.l10n.commonLoading,
            isLoading: _isLoadingSuggestions && _canLoadSuggestions(query),
            history: _historyWhenVisible,
            suggestions: _suggestionsWhenVisible,
            noResultsText: _noResultsTextWhenVisible,
            onHistorySelected: _onHistorySelected,
            onSuggestionSelected: _onSuggestionSelected,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildTrailing(String query) {
    final trailing = <Widget>[];
    if (widget.isLoading || _isLoadingSuggestions) {
      trailing.add(
        const SizedBox.square(
          dimension: AppSpacing.space16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (query.isNotEmpty) {
      trailing.add(
        IconButton(
          key: appSearchExperienceClearButtonKey,
          tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
          onPressed: widget.enabled ? _onClearPressed : null,
          icon: const Icon(Icons.close),
        ),
      );
    }
    return trailing;
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() {});
    if (_focusNode.hasFocus) {
      _scheduleDebouncedQuery(_normalizedQuery);
    }
  }

  void _onTextChanged() {
    if (_suppressNextTextChange) {
      _suppressNextTextChange = false;
      if (mounted) {
        setState(() {});
      }
      return;
    }

    if (mounted) {
      setState(() {});
    }
    _scheduleDebouncedQuery(_normalizedQuery);
  }

  void _scheduleDebouncedQuery(String query) {
    _debounceTimer?.cancel();
    if (widget.debounceDuration == Duration.zero) {
      unawaited(_applyQuery(query));
      return;
    }
    _debounceTimer = Timer(widget.debounceDuration, () {
      unawaited(_applyQuery(query));
    });
  }

  Future<void> _applyQuery(String query) async {
    widget.onQueryChanged?.call(query);
    await _loadSuggestions(query);
  }

  Future<void> _loadSuggestions(String query) async {
    final loader = widget.suggestionsLoader;
    if (loader == null || !_canLoadSuggestions(query)) {
      if (!mounted) return;
      if (_isLoadingSuggestions || _suggestions.isNotEmpty) {
        setState(() {
          _isLoadingSuggestions = false;
          _suggestions = <AppSearchSuggestion<T>>[];
        });
      }
      return;
    }

    final requestId = ++_requestId;
    if (mounted) {
      setState(() {
        _isLoadingSuggestions = true;
      });
    }

    try {
      final result = await Future<List<AppSearchSuggestion<T>>>.value(
        loader(query),
      );
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _suggestions = result;
        _isLoadingSuggestions = false;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _isLoadingSuggestions = false;
        _suggestions = <AppSearchSuggestion<T>>[];
      });
    }
  }

  Future<void> _loadHistory() async {
    if (!widget.enableHistory) {
      if (!mounted) return;
      setState(() {
        _history = const <String>[];
      });
      return;
    }

    final store = widget.historyStore;
    if (store == null) {
      return;
    }

    try {
      final values = await store.loadHistory();
      if (!mounted) return;
      setState(() {
        _history = _normalizeHistory(values);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _history = const <String>[];
      });
    }
  }

  void _onSubmitted(String rawQuery) {
    final query = rawQuery.trim();
    _commitHistory(query);
    widget.onQuerySubmitted?.call(query);
  }

  void _onClearPressed() {
    if (_controller.text.isEmpty) {
      return;
    }
    _debounceTimer?.cancel();
    _suppressNextTextChange = true;
    _controller.clear();
    widget.onCleared?.call();
    unawaited(_applyQuery(''));
  }

  void _onHistorySelected(String query) {
    _setQueryAndSubmit(query);
  }

  void _onSuggestionSelected(AppSearchSuggestion<T> suggestion) {
    _setQueryAndSubmit(suggestion.label.trim());
    widget.onSuggestionSelected?.call(suggestion);
  }

  void _setQueryAndSubmit(String query) {
    _suppressNextTextChange = true;
    _controller.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _commitHistory(query);
    widget.onQuerySubmitted?.call(query);
    _focusNode.unfocus();
  }

  void _commitHistory(String query) {
    final normalized = query.trim();
    if (!widget.enableHistory || normalized.isEmpty) {
      return;
    }

    final next = List<String>.from(_history)
      ..removeWhere((item) => item.toLowerCase() == normalized.toLowerCase())
      ..insert(0, normalized);
    final limited = _normalizeHistory(next);
    if (mounted) {
      setState(() {
        _history = limited;
      });
    } else {
      _history = limited;
    }

    final store = widget.historyStore;
    if (store != null) {
      unawaited(store.saveHistory(limited));
    }
  }

  List<String> _normalizeHistory(List<String> values) {
    final seen = <String>{};
    final normalized = <String>[];
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      final key = trimmed.toLowerCase();
      if (!seen.add(key)) continue;
      normalized.add(trimmed);
      if (normalized.length >= widget.historyLimit) break;
    }
    return normalized;
  }

  String get _normalizedQuery => _controller.text.trim();

  bool _canLoadSuggestions(String query) {
    return query.length >= widget.minQueryLength;
  }

  bool get _hasPanelContent {
    return (_isLoadingSuggestions && _canLoadSuggestions(_normalizedQuery)) ||
        _historyWhenVisible.isNotEmpty ||
        _suggestionsWhenVisible.isNotEmpty ||
        _noResultsTextWhenVisible != null;
  }

  List<String> get _historyWhenVisible {
    if (_normalizedQuery.isNotEmpty || !widget.enableHistory) {
      return const <String>[];
    }
    return _history;
  }

  List<AppSearchSuggestion<T>> get _suggestionsWhenVisible {
    if (!_canLoadSuggestions(_normalizedQuery)) {
      return <AppSearchSuggestion<T>>[];
    }
    return _suggestions;
  }

  String? get _noResultsTextWhenVisible {
    if (_isLoadingSuggestions || _normalizedQuery.isEmpty) {
      return null;
    }
    if (!_canLoadSuggestions(_normalizedQuery)) {
      return null;
    }
    if (_suggestions.isNotEmpty) {
      return null;
    }

    final noResults = widget.noResultsText;
    if (noResults == null) return null;
    final trimmed = noResults.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }
}

class _SearchPanel<T> extends StatelessWidget {
  const _SearchPanel({
    required this.loadingText,
    required this.isLoading,
    required this.history,
    required this.suggestions,
    required this.noResultsText,
    required this.onHistorySelected,
    required this.onSuggestionSelected,
  });

  final String loadingText;
  final bool isLoading;
  final List<String> history;
  final List<AppSearchSuggestion<T>> suggestions;
  final String? noResultsText;
  final ValueChanged<String> onHistorySelected;
  final ValueChanged<AppSearchSuggestion<T>> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final noResultsLabel = noResultsText;

    final children = <Widget>[
      if (isLoading)
        Padding(
          padding: const EdgeInsets.all(AppSpacing.space12),
          child: Row(
            children: [
              const SizedBox.square(
                dimension: AppSpacing.space16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppSpacing.space8),
              Expanded(child: AppText.bodyMedium(loadingText)),
            ],
          ),
        ),
      ...history.map(
        (item) => ListTile(
          key: appSearchExperienceHistoryItemKey(item),
          leading: const Icon(Icons.history),
          title: AppText.bodyMedium(item),
          onTap: () => onHistorySelected(item),
        ),
      ),
      ...suggestions.map(
        (suggestion) => ListTile(
          key: appSearchExperienceSuggestionItemKey(suggestion.label),
          leading: suggestion.leading,
          trailing: suggestion.trailing,
          title: AppText.bodyMedium(suggestion.label),
          subtitle: suggestion.subtitle == null
              ? null
              : AppText.bodySmall(suggestion.subtitle!),
          onTap: () => onSuggestionSelected(suggestion),
        ),
      ),
      if (noResultsLabel != null)
        Padding(
          padding: const EdgeInsets.all(AppSpacing.space12),
          child: AppText.bodyMedium(
            noResultsLabel,
            textAlign: TextAlign.center,
          ),
        ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.radius12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 320),
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: children,
        ),
      ),
    );
  }
}
