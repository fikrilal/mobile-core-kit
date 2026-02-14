import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_core_kit/core/design_system/theme/system/motion_durations.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_history_store.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_input_shell.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_keys.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_models.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_panel.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_style.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';

const _defaultHistorySectionLabel = 'Recent';
const _defaultSuggestionSectionLabel = 'Suggestions';
const _defaultClearHistoryLabel = 'Clear';

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
    this.onHistoryCleared,
    this.enableKeyboardNavigation = true,
    this.showClearHistoryAction = true,
    this.historySectionLabel,
    this.suggestionsSectionLabel,
    this.clearHistoryLabel,
    this.panelScrollPhysics,
    this.style = const AppSearchStyle(),
  }) : assert(historyLimit > 0, 'historyLimit must be greater than zero.'),
       assert(
         minQueryLength >= 0,
         'minQueryLength must be greater than or equal to zero.',
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
  final VoidCallback? onHistoryCleared;
  final bool enableKeyboardNavigation;
  final bool showClearHistoryAction;
  final String? historySectionLabel;
  final String? suggestionsSectionLabel;
  final String? clearHistoryLabel;
  final ScrollPhysics? panelScrollPhysics;
  final AppSearchStyle style;

  @override
  State<AppSearchExperience<T>> createState() => _AppSearchExperienceState<T>();
}

class _AppSearchExperienceState<T> extends State<AppSearchExperience<T>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late final ScrollController _panelScrollController;

  Timer? _debounceTimer;
  int _requestId = 0;
  bool _suppressNextTextChange = false;
  bool _isLoadingSuggestions = false;

  int _highlightedIndex = -1;
  List<AppSearchSuggestion<T>> _suggestions = <AppSearchSuggestion<T>>[];
  List<String> _history = const <String>[];

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialQuery);
    _focusNode = widget.focusNode ?? FocusNode();
    _panelScrollController = ScrollController();
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
    _panelScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _normalizedQuery;
    final showPanel = _focusNode.hasFocus && _hasPanelContent;
    final palette = resolveAppSearchPalette(
      context,
      enabled: widget.enabled,
      focused: _focusNode.hasFocus,
    );

    return TapRegion(
      onTapOutside: (_) {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      child: Focus(
        onKeyEvent: _handleKeyEvent,
        child: Column(
          key: appSearchExperienceContainerKey,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSearchInputShell(
              textFieldKey: appSearchExperienceBarKey,
              controller: _controller,
              focusNode: _focusNode,
              style: widget.style,
              palette: palette,
              placeholder: widget.placeholder ?? context.l10n.fieldSearchHint,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              showLoading: widget.isLoading || _isLoadingSuggestions,
              showClearButton: query.isNotEmpty,
              onSubmitted: _onSubmitted,
              onClearPressed: _onClearPressed,
            ),
            if (showPanel) ...[
              const SizedBox(height: AppSpacing.space8),
              AppSearchPanel<T>(
                style: widget.style,
                palette: palette,
                query: query,
                history: _historyWhenVisible,
                suggestions: _suggestionsWhenVisible,
                loadingText: context.l10n.commonLoading,
                historySectionLabel: _historyLabel,
                suggestionsSectionLabel: _suggestionsLabel,
                clearHistoryLabel: _clearHistoryLabel,
                isLoading: _isLoadingSuggestions && _canLoadSuggestions(query),
                showClearHistoryAction: widget.showClearHistoryAction,
                highlightedIndex: _highlightedIndex,
                noResultsText: _noResultsTextWhenVisible,
                scrollController: _panelScrollController,
                scrollPhysics: widget.panelScrollPhysics,
                onHistorySelected: _onHistorySelected,
                onSuggestionSelected: _onSuggestionSelected,
                onClearHistory:
                    widget.showClearHistoryAction &&
                        _historyWhenVisible.isNotEmpty
                    ? _clearHistory
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enableKeyboardNavigation || !_focusNode.hasFocus) {
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (!_hasInteractivePanelEntries) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _focusNode.unfocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _moveHighlight(1);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _moveHighlight(-1);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _focusNode.unfocus();
      return KeyEventResult.handled;
    }

    final isEnter =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (isEnter && _highlightedIndex >= 0) {
      _submitHighlightedEntry();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _moveHighlight(int delta) {
    final total = _interactiveEntryCount;
    if (total <= 0) return;

    final current = _highlightedIndex;
    final next = current < 0
        ? (delta > 0 ? 0 : total - 1)
        : (current + delta + total) % total;

    if (!mounted) return;
    setState(() {
      _highlightedIndex = next;
    });
    _ensureHighlightVisible(next);
  }

  void _ensureHighlightVisible(int index) {
    if (!_panelScrollController.hasClients) return;
    final position = _panelScrollController.position;
    if (!position.hasViewportDimension) return;

    final rowExtent = widget.style.itemVerticalPadding * 2 + AppSpacing.space20;
    final rowStart = index * rowExtent;
    final rowEnd = rowStart + rowExtent;
    final viewportStart = position.pixels;
    final viewportEnd = viewportStart + position.viewportDimension;

    var target = viewportStart;
    if (rowEnd > viewportEnd) {
      target = rowEnd - position.viewportDimension + AppSpacing.space12;
    } else if (rowStart < viewportStart) {
      target = rowStart - AppSpacing.space12;
    }

    final clamped = target.clamp(0.0, position.maxScrollExtent);
    if ((clamped - viewportStart).abs() < AppSpacing.space1) {
      return;
    }

    _panelScrollController.animateTo(
      clamped,
      duration: MotionDurations.short,
      curve: Curves.easeOutCubic,
    );
  }

  void _submitHighlightedEntry() {
    if (_highlightedIndex < 0) return;

    final history = _historyWhenVisible;
    if (_highlightedIndex < history.length) {
      _onHistorySelected(history[_highlightedIndex]);
      return;
    }

    final suggestionIndex = _highlightedIndex - history.length;
    final suggestions = _suggestionsWhenVisible;
    if (suggestionIndex < 0 || suggestionIndex >= suggestions.length) {
      return;
    }

    _onSuggestionSelected(suggestions[suggestionIndex]);
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() {
      if (!_focusNode.hasFocus) {
        _highlightedIndex = -1;
      }
    });
    if (_focusNode.hasFocus) {
      _scheduleDebouncedQuery(_normalizedQuery);
    }
  }

  void _onTextChanged() {
    if (_suppressNextTextChange) {
      _suppressNextTextChange = false;
      if (mounted) {
        setState(() {
          _highlightedIndex = -1;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _highlightedIndex = -1;
      });
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
          _highlightedIndex = -1;
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
        _highlightedIndex = -1;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _isLoadingSuggestions = false;
        _suggestions = <AppSearchSuggestion<T>>[];
        _highlightedIndex = -1;
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

  void _clearHistory() {
    if (_history.isEmpty) {
      return;
    }

    setState(() {
      _history = const <String>[];
      _highlightedIndex = -1;
    });

    final store = widget.historyStore;
    if (store != null) {
      unawaited(store.saveHistory(const <String>[]));
    }

    widget.onHistoryCleared?.call();
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

  bool get _hasInteractivePanelEntries => _interactiveEntryCount > 0;

  int get _interactiveEntryCount {
    return _historyWhenVisible.length + _suggestionsWhenVisible.length;
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

  String get _historyLabel {
    final value = widget.historySectionLabel?.trim();
    if (value == null || value.isEmpty) {
      return _defaultHistorySectionLabel;
    }
    return value;
  }

  String get _suggestionsLabel {
    final value = widget.suggestionsSectionLabel?.trim();
    if (value == null || value.isEmpty) {
      return _defaultSuggestionSectionLabel;
    }
    return value;
  }

  String get _clearHistoryLabel {
    final value = widget.clearHistoryLabel?.trim();
    if (value == null || value.isEmpty) {
      return _defaultClearHistoryLabel;
    }
    return value;
  }
}
