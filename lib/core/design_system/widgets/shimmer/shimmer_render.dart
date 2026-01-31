part of 'shimmer_component.dart';

@immutable
class _Shimmer extends SingleChildRenderObjectWidget {
  final Animation<double> animation;
  final ShimmerDirection direction;
  final Gradient gradient;

  const _Shimmer({
    super.child,
    required this.animation,
    required this.direction,
    required this.gradient,
  });

  @override
  _ShimmerFilter createRenderObject(BuildContext context) {
    return _ShimmerFilter(animation, direction, gradient);
  }

  @override
  void updateRenderObject(BuildContext context, _ShimmerFilter shimmer) {
    shimmer
      ..animation = animation
      ..gradient = gradient
      ..direction = direction;
  }
}

class _ShimmerFilter extends RenderProxyBox {
  Animation<double> _animation;
  ShimmerDirection _direction;
  Gradient _gradient;

  _ShimmerFilter(this._animation, this._direction, this._gradient);

  @override
  ShaderMaskLayer? get layer => super.layer as ShaderMaskLayer?;

  @override
  bool get alwaysNeedsCompositing => child != null;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _animation.removeListener(markNeedsPaint);
    super.detach();
  }

  set animation(Animation<double> newValue) {
    if (identical(newValue, _animation)) {
      return;
    }
    if (attached) {
      _animation.removeListener(markNeedsPaint);
      newValue.addListener(markNeedsPaint);
    }
    _animation = newValue;
    markNeedsPaint();
  }

  set gradient(Gradient newValue) {
    if (newValue == _gradient) {
      return;
    }
    _gradient = newValue;
    markNeedsPaint();
  }

  set direction(ShimmerDirection newDirection) {
    if (newDirection == _direction) {
      return;
    }
    _direction = newDirection;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      layer = null;
      return;
    }

    assert(needsCompositing);

    final percent = _animation.value;
    final width = child!.size.width;
    final height = child!.size.height;
    Rect rect;
    double dx, dy;

    if (_direction == ShimmerDirection.rtl) {
      dx = _offset(width, -width, percent);
      dy = 0.0;
      rect = Rect.fromLTWH(dx - width, dy, 3 * width, height);
    } else if (_direction == ShimmerDirection.ttb) {
      dx = 0.0;
      dy = _offset(-height, height, percent);
      rect = Rect.fromLTWH(dx, dy - height, width, 3 * height);
    } else if (_direction == ShimmerDirection.btt) {
      dx = 0.0;
      dy = _offset(height, -height, percent);
      rect = Rect.fromLTWH(dx, dy - height, width, 3 * height);
    } else {
      dx = _offset(-width, width, percent);
      dy = 0.0;
      rect = Rect.fromLTWH(dx - width, dy, 3 * width, height);
    }

    layer ??= ShaderMaskLayer();
    layer!
      ..shader = _gradient.createShader(rect)
      ..maskRect = offset & size
      ..blendMode = BlendMode.srcIn;
    context.pushLayer(layer!, super.paint, offset);
  }

  double _offset(double start, double end, double percent) {
    return start + (end - start) * percent;
  }
}
