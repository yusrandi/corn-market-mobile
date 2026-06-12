import 'package:flutter/material.dart';

// ─── FadeIn ──────────────────────────────────────────────────────────────────

class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.curve = Curves.easeIn,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _ctrl, curve: widget.curve)
        .drive(Tween(begin: 0.0, end: 1.0));

    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _fade, child: widget.child);
}

// ─── SlideIn ─────────────────────────────────────────────────────────────────

class SlideInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset beginOffset;
  final Curve curve;

  const SlideInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 450),
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0, 0.15),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<SlideInWidget> createState() => _SlideInWidgetState();
}

class _SlideInWidgetState extends State<SlideInWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _slide = CurvedAnimation(parent: _ctrl, curve: widget.curve)
        .drive(Tween(begin: widget.beginOffset, end: Offset.zero));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ─── ScaleIn ─────────────────────────────────────────────────────────────────

class ScaleInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double beginScale;
  final Curve curve;

  const ScaleInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.beginScale = 0.7,
    this.curve = Curves.elasticOut,
  });

  @override
  State<ScaleInWidget> createState() => _ScaleInWidgetState();
}

class _ScaleInWidgetState extends State<ScaleInWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _scale = CurvedAnimation(parent: _ctrl, curve: widget.curve)
        .drive(Tween(begin: widget.beginScale, end: 1.0));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: ScaleTransition(scale: _scale, child: widget.child),
      );
}

// ─── Stagger list ─────────────────────────────────────────────────────────────

/// Wraps a list of children – each child slides in with staggered delay
class StaggerList extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration staggerDelay;
  final Duration initialDelay;
  final Offset beginOffset;

  const StaggerList({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 80),
    this.initialDelay = Duration.zero,
    this.beginOffset = const Offset(0, 0.12),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(children.length, (i) {
        final delay = initialDelay + staggerDelay * i;
        return SlideInWidget(
          delay: delay,
          duration: itemDuration,
          beginOffset: beginOffset,
          child: children[i],
        );
      }),
    );
  }
}

// ─── Tap bounce ──────────────────────────────────────────────────────────────

/// Adds a subtle scale-down on tap – wraps any tappable widget
class TapBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const TapBounce({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.94,
  });

  @override
  State<TapBounce> createState() => _TapBounceState();
}

class _TapBounceState extends State<TapBounce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)
        .drive(Tween(begin: 1.0, end: widget.scale));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) async {
        await _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

// ─── Pulse (untuk badge/highlight) ───────────────────────────────────────────

class PulseWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulseWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)
        .drive(Tween(begin: 1.0, end: 1.08));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: widget.child,
      );
}

// ─── Spinning corn (pull-to-refresh indicator) ───────────────────────────────

class SpinningCorn extends StatefulWidget {
  final double size;
  const SpinningCorn({super.key, this.size = 36});

  @override
  State<SpinningCorn> createState() => _SpinningCornState();
}

class _SpinningCornState extends State<SpinningCorn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.rotate(
          angle: _ctrl.value * 2 * 3.14159,
          child: child,
        ),
        child: Text('🌽', style: TextStyle(fontSize: widget.size)),
      );
}
