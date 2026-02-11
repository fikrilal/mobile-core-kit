import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/design_system/widgets/loading/loading.dart';
import 'package:mobile_core_kit/core/design_system/widgets/state_message/state_message.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';

enum AppCollectionLayout { list, grid }

enum AppCollectionStatus {
  initialLoading,
  refreshLoading,
  success,
  empty,
  failure,
}

typedef AppPaginatedItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

class AppPaginatedCollectionView<T> extends StatefulWidget {
  const AppPaginatedCollectionView({
    super.key,
    required this.status,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.hasMore,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.errorTitle,
    this.errorDescription,
    this.emptyTitle,
    this.emptyDescription,
    this.onRetry,
    this.retryLabel,
    this.padding,
    this.layout = AppCollectionLayout.list,
    this.gridDelegate,
    this.separatorBuilder,
    this.physics,
    this.shrinkWrap = false,
    this.loadMoreThresholdPx = 320,
  }) : assert(
         onRetry == null || retryLabel != null,
         'retryLabel must be provided when onRetry is set.',
       ),
       assert(
         layout == AppCollectionLayout.list || gridDelegate != null,
         'gridDelegate must be provided for grid layout.',
       );

  final AppCollectionStatus status;
  final List<T> items;
  final AppPaginatedItemBuilder<T> itemBuilder;
  final Future<void> Function() onRefresh;
  final bool hasMore;
  final Future<void> Function()? onLoadMore;
  final bool isLoadingMore;
  final String? errorTitle;
  final String? errorDescription;
  final String? emptyTitle;
  final String? emptyDescription;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final EdgeInsetsGeometry? padding;
  final AppCollectionLayout layout;
  final SliverGridDelegate? gridDelegate;
  final IndexedWidgetBuilder? separatorBuilder;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double loadMoreThresholdPx;

  @override
  State<AppPaginatedCollectionView<T>> createState() =>
      _AppPaginatedCollectionViewState<T>();
}

class _AppPaginatedCollectionViewState<T>
    extends State<AppPaginatedCollectionView<T>> {
  final ScrollController _scrollController = ScrollController();

  bool _isLoadMoreInFlight = false;
  bool _isPostFrameLoadCheckScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant AppPaginatedCollectionView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.isLoadingMore && oldWidget.isLoadingMore) {
      _isLoadMoreInFlight = false;
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmptyCollection = widget.items.isEmpty;

    return switch (widget.status) {
      AppCollectionStatus.initialLoading => _buildInitialLoading(context),
      AppCollectionStatus.failure when isEmptyCollection => _buildFailure(
        context,
      ),
      AppCollectionStatus.empty => _buildEmpty(context),
      AppCollectionStatus.success when isEmptyCollection => _buildEmpty(
        context,
      ),
      AppCollectionStatus.refreshLoading when isEmptyCollection => _buildEmpty(
        context,
      ),
      _ => _buildCollection(context),
    };
  }

  Widget _buildInitialLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppDotWave(color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.space12),
          AppText.bodyMedium(
            context.l10n.commonLoading,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFailure(BuildContext context) {
    final retryLabel = widget.retryLabel;
    final onRetry = widget.onRetry;
    final actions = retryLabel == null || onRetry == null
        ? const <Widget>[]
        : <Widget>[
            AppButton.primary(
              text: retryLabel,
              semanticLabel: retryLabel,
              isExpanded: true,
              onPressed: onRetry,
            ),
          ];

    return AppStateMessagePanel(
      title: widget.errorTitle ?? context.l10n.errorsUnexpected,
      description: widget.errorDescription,
      actions: actions,
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return AppEmptyState(
      title: widget.emptyTitle,
      description: widget.emptyDescription,
    );
  }

  Widget _buildCollection(BuildContext context) {
    _scheduleLoadMoreCheck();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: switch (widget.layout) {
        AppCollectionLayout.list => _buildListView(context),
        AppCollectionLayout.grid => _buildGridView(context),
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    final separatorBuilder = widget.separatorBuilder;
    if (separatorBuilder == null) {
      return ListView.builder(
        controller: _scrollController,
        physics: _effectiveScrollPhysics(),
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        itemCount: _effectiveItemCount,
        itemBuilder: _buildCollectionItem,
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: _effectiveScrollPhysics(),
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      itemCount: _effectiveItemCount,
      itemBuilder: _buildCollectionItem,
      separatorBuilder: separatorBuilder,
    );
  }

  Widget _buildGridView(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      physics: _effectiveScrollPhysics(),
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      gridDelegate: widget.gridDelegate!,
      itemCount: _effectiveItemCount,
      itemBuilder: _buildCollectionItem,
    );
  }

  Widget _buildCollectionItem(BuildContext context, int index) {
    final items = widget.items;
    if (index >= items.length) {
      return _buildLoadMoreFooter(context);
    }
    return widget.itemBuilder(context, items[index], index);
  }

  Widget _buildLoadMoreFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
      child: Center(
        child: AppDotWave(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  int get _effectiveItemCount {
    return widget.items.length + (_showsLoadMoreFooter ? 1 : 0);
  }

  bool get _showsLoadMoreFooter {
    return widget.onLoadMore != null && widget.hasMore && widget.isLoadingMore;
  }

  ScrollPhysics _effectiveScrollPhysics() {
    const base = AlwaysScrollableScrollPhysics();
    return widget.physics == null ? base : base.applyTo(widget.physics);
  }

  void _onScroll() {
    _maybeLoadMore();
  }

  void _scheduleLoadMoreCheck() {
    if (_isPostFrameLoadCheckScheduled) return;
    _isPostFrameLoadCheckScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _isPostFrameLoadCheckScheduled = false;
      if (!mounted) return;
      await _maybeLoadMore();
    });
  }

  Future<void> _maybeLoadMore() async {
    final onLoadMore = widget.onLoadMore;
    if (onLoadMore == null) return;
    if (!widget.hasMore) return;
    if (widget.isLoadingMore || _isLoadMoreInFlight) return;
    if (!_scrollController.hasClients) return;

    final remainingExtent = _scrollController.position.extentAfter;
    if (remainingExtent > widget.loadMoreThresholdPx) return;

    _isLoadMoreInFlight = true;
    try {
      await onLoadMore();
    } finally {
      _isLoadMoreInFlight = false;
    }
  }
}
