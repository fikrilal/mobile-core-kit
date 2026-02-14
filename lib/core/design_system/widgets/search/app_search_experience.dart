import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/system/motion_durations.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_input_shell.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_keys.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/app_search_style.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';

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
    this.isLoading = false,
    this.onQueryChanged,
    this.onQuerySubmitted,
    this.onCleared,
    this.style = const AppSearchStyle(),
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialQuery;
  final String? placeholder;
  final bool enabled;
  final bool autofocus;
  final Duration debounceDuration;
  final bool isLoading;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<String>? onQuerySubmitted;
  final VoidCallback? onCleared;
  final AppSearchStyle style;

  @override
  State<AppSearchExperience<T>> createState() => _AppSearchExperienceState<T>();
}

class _AppSearchExperienceState<T> extends State<AppSearchExperience<T>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  Timer? _debounceTimer;
  bool _suppressNextTextChange = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialQuery);
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
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
    final palette = resolveAppSearchPalette(
      context,
      enabled: widget.enabled,
      focused: _focusNode.hasFocus,
    );

    return TapRegion(
      key: appSearchExperienceContainerKey,
      onTapOutside: (_) {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      child: AppSearchInputShell(
        textFieldKey: appSearchExperienceBarKey,
        controller: _controller,
        focusNode: _focusNode,
        style: widget.style,
        palette: palette,
        placeholder: widget.placeholder ?? context.l10n.fieldSearchHint,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        showLoading: widget.isLoading,
        showClearButton: _normalizedQuery.isNotEmpty,
        onSubmitted: _onSubmitted,
        onClearPressed: _onClearPressed,
      ),
    );
  }

  void _onTextChanged() {
    if (_suppressNextTextChange) {
      _suppressNextTextChange = false;
      return;
    }
    _scheduleDebouncedQuery(_normalizedQuery);
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _scheduleDebouncedQuery(String query) {
    _debounceTimer?.cancel();
    if (widget.debounceDuration == Duration.zero) {
      _applyQuery(query);
      return;
    }
    _debounceTimer = Timer(widget.debounceDuration, () {
      _applyQuery(query);
    });
  }

  void _applyQuery(String query) {
    widget.onQueryChanged?.call(query);
  }

  void _onSubmitted(String rawQuery) {
    widget.onQuerySubmitted?.call(rawQuery.trim());
  }

  void _onClearPressed() {
    if (_controller.text.isEmpty) {
      return;
    }
    _debounceTimer?.cancel();
    _suppressNextTextChange = true;
    _controller.clear();
    widget.onCleared?.call();
    _applyQuery('');
  }

  String get _normalizedQuery => _controller.text.trim();
}
