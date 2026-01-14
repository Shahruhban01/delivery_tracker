import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomDropUp extends StatefulWidget {
  final VoidCallback onRunsheetTap;
  final VoidCallback onPickupTap;

  const CustomDropUp({
    Key? key,
    required this.onRunsheetTap,
    required this.onPickupTap,
  }) : super(key: key);

  @override
  State<CustomDropUp> createState() => _CustomDropUpState();
}

class _CustomDropUpState extends State<CustomDropUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _close,
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Stack(
          children: [
            Positioned(
              right: 16,
              bottom: 80,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildOption(
                              'Runsheet',
                              Icons.local_shipping,
                              const Color(0xFF2196F3),
                              () {
                                _close();
                                widget.onRunsheetTap();
                              },
                            ),
                            Container(
                              height: 1,
                              color: const Color(0xFFE0E0E0),
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            _buildOption(
                              'Pickup Sheet',
                              Icons.assignment_return,
                              const Color(0xFFFF9800),
                              () {
                                _close();
                                widget.onPickupTap();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
