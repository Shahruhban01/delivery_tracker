import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomRefreshButton extends StatefulWidget {
  final VoidCallback onRefresh;
  final bool isLoading;
  final Color? iconColor;
  final Color? backgroundColor;

  const CustomRefreshButton({
    Key? key,
    required this.onRefresh,
    this.isLoading = false,
    this.iconColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<CustomRefreshButton> createState() => _CustomRefreshButtonState();
}

class _CustomRefreshButtonState extends State<CustomRefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(CustomRefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onRefresh,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: widget.isLoading ? _animation.value * 2 * math.pi : 0,
              child: Icon(
                Icons.refresh,
                color: widget.iconColor ?? const Color(0xFF757575),
                size: 22,
              ),
            );
          },
        ),
      ),
    );
  }
}
