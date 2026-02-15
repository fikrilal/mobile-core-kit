import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/core/design_system/widgets/collection/collection.dart';
import 'package:mobile_core_kit/core/design_system/widgets/loading/loading.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SizedBox(height: 320, child: child)),
    );
  }

  AppPaginatedCollectionView<int> buildWidget({
    required AppCollectionStatus status,
    required List<int> items,
    required Future<void> Function() onRefresh,
    bool hasMore = false,
    Future<void> Function()? onLoadMore,
    bool isLoadingMore = false,
    VoidCallback? onRetry,
    String? retryLabel,
  }) {
    return AppPaginatedCollectionView<int>(
      status: status,
      items: items,
      itemBuilder: (context, item, index) => SizedBox(
        height: 64,
        child: Text('item-$item', textDirection: TextDirection.ltr),
      ),
      onRefresh: onRefresh,
      hasMore: hasMore,
      onLoadMore: onLoadMore,
      isLoadingMore: isLoadingMore,
      onRetry: onRetry,
      retryLabel: retryLabel,
      errorTitle: 'Load failed',
      emptyTitle: 'No content',
    );
  }

  testWidgets('renders loading for initialLoading', (tester) async {
    await tester.pumpWidget(
      wrap(
        buildWidget(
          status: AppCollectionStatus.initialLoading,
          items: const <int>[],
          onRefresh: () async {},
        ),
      ),
    );

    expect(find.text('Loading'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('renders empty state', (tester) async {
    await tester.pumpWidget(
      wrap(
        buildWidget(
          status: AppCollectionStatus.empty,
          items: const <int>[],
          onRefresh: () async {},
        ),
      ),
    );

    expect(find.text('No content'), findsOneWidget);
  });

  testWidgets('renders failure state and retry action', (tester) async {
    var retryCalls = 0;

    await tester.pumpWidget(
      wrap(
        buildWidget(
          status: AppCollectionStatus.failure,
          items: const <int>[],
          onRefresh: () async {},
          onRetry: () => retryCalls++,
          retryLabel: 'Retry',
        ),
      ),
    );

    expect(find.text('Load failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(retryCalls, 1);
  });

  testWidgets('renders list items in success state', (tester) async {
    await tester.pumpWidget(
      wrap(
        buildWidget(
          status: AppCollectionStatus.success,
          items: const <int>[1, 2, 3],
          onRefresh: () async {},
        ),
      ),
    );

    expect(find.text('item-1'), findsOneWidget);
    expect(find.text('item-2'), findsOneWidget);
    expect(find.text('item-3'), findsOneWidget);
  });

  testWidgets('pull-to-refresh calls onRefresh', (tester) async {
    var refreshCalls = 0;

    await tester.pumpWidget(
      wrap(
        buildWidget(
          status: AppCollectionStatus.success,
          items: const <int>[1, 2, 3],
          onRefresh: () async {
            refreshCalls++;
          },
        ),
      ),
    );

    await tester.fling(find.byType(Scrollable), const Offset(0, 400), 1000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(refreshCalls, 1);
  });

  testWidgets('load-more trigger is guarded while a request is in-flight', (
    tester,
  ) async {
    final completer = Completer<void>();
    var loadMoreCalls = 0;

    await tester.pumpWidget(
      wrap(
        buildWidget(
          status: AppCollectionStatus.success,
          items: List<int>.generate(30, (index) => index),
          hasMore: true,
          onRefresh: () async {},
          onLoadMore: () {
            loadMoreCalls++;
            return completer.future;
          },
        ),
      ),
    );

    await tester.drag(find.byType(Scrollable), const Offset(0, -1800));
    await tester.pump();

    await tester.drag(find.byType(Scrollable), const Offset(0, -1200));
    await tester.pump();

    expect(loadMoreCalls, 1);

    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('does not trigger load-more when hasMore is false', (
    tester,
  ) async {
    var loadMoreCalls = 0;

    await tester.pumpWidget(
      wrap(
        buildWidget(
          status: AppCollectionStatus.success,
          items: List<int>.generate(20, (index) => index),
          hasMore: false,
          onRefresh: () async {},
          onLoadMore: () async {
            loadMoreCalls++;
          },
        ),
      ),
    );

    await tester.drag(find.byType(Scrollable), const Offset(0, -1800));
    await tester.pump(const Duration(milliseconds: 200));

    expect(loadMoreCalls, 0);
  });

  testWidgets('does not trigger load-more when isLoadingMore is true', (
    tester,
  ) async {
    var loadMoreCalls = 0;

    await tester.pumpWidget(
      wrap(
        buildWidget(
          status: AppCollectionStatus.success,
          items: List<int>.generate(20, (index) => index),
          hasMore: true,
          isLoadingMore: true,
          onRefresh: () async {},
          onLoadMore: () async {
            loadMoreCalls++;
          },
        ),
      ),
    );

    await tester.drag(find.byType(Scrollable), const Offset(0, -1800));
    await tester.pump(const Duration(milliseconds: 200));

    expect(loadMoreCalls, 0);
  });

  testWidgets('renders load-more footer while loading more', (tester) async {
    await tester.pumpWidget(
      wrap(
        buildWidget(
          status: AppCollectionStatus.success,
          items: const <int>[1],
          hasMore: true,
          isLoadingMore: true,
          onRefresh: () async {},
          onLoadMore: () async {},
        ),
      ),
    );

    expect(find.byType(AppDotWave), findsOneWidget);
  });

  testWidgets('grid layout requires gridDelegate', (tester) async {
    expect(
      () => AppPaginatedCollectionView<int>(
        status: AppCollectionStatus.success,
        items: const <int>[1, 2],
        itemBuilder: (context, item, index) =>
            Text('$item', textDirection: TextDirection.ltr),
        onRefresh: () async {},
        hasMore: false,
        layout: AppCollectionLayout.grid,
      ),
      throwsAssertionError,
    );
  });
}
