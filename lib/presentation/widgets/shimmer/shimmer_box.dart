import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Shimmer efek base – bisa dipakai di mana saja
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget? child;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.child,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final base  = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFEEEEEE);
    final shine = isDark ? AppColors.darkSurface        : const Color(0xFFF8F8F8);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, shine, base],
              stops: [
                (_anim.value - 0.3).clamp(0.0, 1.0),
                _anim.value.clamp(0.0, 1.0),
                (_anim.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
