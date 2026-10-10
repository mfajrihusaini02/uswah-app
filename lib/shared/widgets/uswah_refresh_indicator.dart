import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Refresh indicator unik khas Uswah: lingkaran masjid dengan arc emas yang
/// terisi mengikuti tarikan, lalu berputar saat me-refresh.
class UswahRefreshIndicator extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const UswahRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  State<UswahRefreshIndicator> createState() => _UswahRefreshIndicatorState();
}

class _UswahRefreshIndicatorState extends State<UswahRefreshIndicator>
    with SingleTickerProviderStateMixin {
  static const double _triggerExtent = 90;
  static const double _maxExtent = 110;

  double _drag = 0;
  bool _refreshing = false;
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  bool _handleNotification(ScrollNotification notification) {
    if (_refreshing) return false;
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification is ScrollUpdateNotification) {
      final pull = -notification.metrics.pixels;
      if (pull > 0) {
        setState(() => _drag = pull.clamp(0, _maxExtent));
      } else if (_drag > 0) {
        setState(() => _drag = 0);
      }
    } else if (notification is ScrollEndNotification) {
      if (_drag >= _triggerExtent) {
        _startRefresh();
      } else if (_drag > 0) {
        setState(() => _drag = 0);
      }
    }
    return false;
  }

  Future<void> _startRefresh() async {
    setState(() {
      _refreshing = true;
      _drag = _triggerExtent;
    });
    _spinController.repeat();
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _spinController.stop();
        setState(() {
          _refreshing = false;
          _drag = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _refreshing
        ? 1.0
        : (_drag / _triggerExtent).clamp(0.0, 1.0);

    return NotificationListener<ScrollNotification>(
      onNotification: _handleNotification,
      child: Stack(
        children: [
          widget.child,
          if (_drag > 0 || _refreshing)
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.only(top: _drag * 0.45),
                  child: _UswahRefreshSpinner(
                    progress: progress,
                    refreshing: _refreshing,
                    spin: _spinController,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UswahRefreshSpinner extends StatelessWidget {
  final double progress;
  final bool refreshing;
  final AnimationController spin;

  const _UswahRefreshSpinner({
    required this.progress,
    required this.refreshing,
    required this.spin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final arcColor = isDark ? AppColors.secondaryBright : AppColors.gold;
    final baseColor = isDark
        ? AppColors.primaryBright.withValues(alpha: 0.35)
        : AppColors.primary.withValues(alpha: 0.18);
    const size = 46.0;

    return AnimatedBuilder(
      animation: spin,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _UswahRefreshArcPainter(
                  progress: progress,
                  rotation: spin.value * 2 * 3.14159,
                  arcColor: arcColor,
                  baseColor: baseColor,
                ),
              ),
            ),
            Icon(Icons.mosque_rounded, size: 20, color: arcColor),
          ],
        );
      },
    );
  }
}

class _UswahRefreshArcPainter extends CustomPainter {
  final double progress;
  final double rotation;
  final Color arcColor;
  final Color baseColor;

  _UswahRefreshArcPainter({
    required this.progress,
    required this.rotation,
    required this.arcColor,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide / 2) - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = baseColor;
    canvas.drawCircle(center, radius, basePaint);

    if (progress <= 0) return;

    final sweep = progress * 2 * 3.14159;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = arcColor
      ..shader = SweepGradient(
        startAngle: -3.14159 / 2 + rotation,
        endAngle: -3.14159 / 2 + rotation + sweep,
        colors: [
          arcColor.withValues(alpha: 0.2),
          arcColor.withValues(alpha: 0.5),
          arcColor,
        ],
        stops: const [0.0, 0.6, 1.0],
        transform: const GradientRotation(0),
      ).createShader(rect);

    canvas.drawArc(rect, -3.14159 / 2 + rotation, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(_UswahRefreshArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rotation != rotation ||
        oldDelegate.arcColor != arcColor ||
        oldDelegate.baseColor != baseColor;
  }
}
