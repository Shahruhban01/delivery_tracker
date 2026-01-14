import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? indicatorColor;

  const CustomPullToRefresh({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.indicatorColor,
  }) : super(key: key);

  @override
  State<CustomPullToRefresh> createState() => _CustomPullToRefreshState();
}

class _CustomPullToRefreshState extends State<CustomPullToRefresh>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  bool _isRefreshing = false;
  final double _maxDragOffset = 100.0;
  final double _refreshTriggerOffset = 80.0;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _animationController.repeat();

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _dragOffset = 0;
        });
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isRefreshing) return;

    setState(() {
      _dragOffset = math.max(0, _dragOffset + details.delta.dy);
      _dragOffset = math.min(_maxDragOffset, _dragOffset);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isRefreshing) return;

    if (_dragOffset >= _refreshTriggerOffset) {
      _handleRefresh();
    } else {
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(
              0,
              _isRefreshing ? 60 : _dragOffset,
              0,
            ),
            child: widget.child,
          ),
          if (_dragOffset > 0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _isRefreshing ? 60 : _dragOffset,
              child: Container(
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _dragOffset > 20 ? 1.0 : 0.0,
                  child: _buildRefreshIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRefreshIndicator() {
    if (_isRefreshing) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animation.value * 2 * math.pi,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.indicatorColor ?? const Color(0xFF2196F3),
                  width: 3,
                ),
              ),
              child: CustomPaint(
                painter: _RefreshIndicatorPainter(
                  color: widget.indicatorColor ?? const Color(0xFF2196F3),
                ),
              ),
            ),
          );
        },
      );
    }

    final progress = (_dragOffset / _refreshTriggerOffset).clamp(0.0, 1.0);
    return Transform.rotate(
      angle: progress * math.pi * 2,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: (widget.indicatorColor ?? const Color(0xFF2196F3))
                .withOpacity(progress),
            width: 3,
          ),
        ),
        child: Icon(
          Icons.arrow_downward,
          size: 16,
          color: (widget.indicatorColor ?? const Color(0xFF2196F3))
              .withOpacity(progress),
        ),
      ),
    );
  }
}

class _RefreshIndicatorPainter extends CustomPainter {
  final Color color;

  _RefreshIndicatorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const sweepAngle = math.pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2 - 2,
      ),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
