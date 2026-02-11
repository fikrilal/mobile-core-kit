import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/design_system/widgets/loading/loading.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';

enum AppAsyncStatus { initial, loading, success, empty, failure }

typedef AppAsyncFailureBuilder<TFailure> =
    Widget Function(BuildContext context, TFailure? failure);

class AppAsyncStateView<TFailure> extends StatelessWidget {
  const AppAsyncStateView({
    super.key,
    required this.status,
    required this.successBuilder,
    this.initialBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.failureBuilder,
    this.failure,
    this.onRetry,
    this.retryLabel,
    this.treatInitialAsLoading = true,
  }) : assert(
         onRetry == null || retryLabel != null,
         'retryLabel must be provided when onRetry is set.',
       );

  final AppAsyncStatus status;
  final WidgetBuilder successBuilder;
  final WidgetBuilder? initialBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final AppAsyncFailureBuilder<TFailure>? failureBuilder;
  final TFailure? failure;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final bool treatInitialAsLoading;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      AppAsyncStatus.initial => _buildInitial(context),
      AppAsyncStatus.loading => _buildLoading(context),
      AppAsyncStatus.success => successBuilder(context),
      AppAsyncStatus.empty => _buildEmpty(context),
      AppAsyncStatus.failure => _buildFailure(context),
    };
  }

  Widget _buildInitial(BuildContext context) {
    if (treatInitialAsLoading) {
      return _buildLoading(context);
    }
    final builder = initialBuilder;
    return builder == null ? const SizedBox.shrink() : builder(context);
  }

  Widget _buildLoading(BuildContext context) {
    final builder = loadingBuilder;
    return builder == null ? const _DefaultLoadingView() : builder(context);
  }

  Widget _buildEmpty(BuildContext context) {
    final builder = emptyBuilder;
    return builder == null ? const SizedBox.shrink() : builder(context);
  }

  Widget _buildFailure(BuildContext context) {
    final builder = failureBuilder;
    if (builder != null) {
      return builder(context, failure);
    }
    return _DefaultFailureView(onRetry: onRetry, retryLabel: retryLabel);
  }
}

class _DefaultLoadingView extends StatelessWidget {
  const _DefaultLoadingView();

  @override
  Widget build(BuildContext context) {
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
}

class _DefaultFailureView extends StatelessWidget {
  const _DefaultFailureView({this.onRetry, this.retryLabel});

  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.bodyMedium(
            context.l10n.errorsUnexpected,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null && retryLabel != null) ...[
            const SizedBox(height: AppSpacing.space16),
            AppButton.primary(
              text: retryLabel!,
              isExpanded: true,
              semanticLabel: retryLabel!,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
