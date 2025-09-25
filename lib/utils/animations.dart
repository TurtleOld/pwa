import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ModernAnimations {
  // Standard animation durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration verySlow = Duration(milliseconds: 500);

  // Standard animation curves
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;

  // Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }

  // Scale animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeOut,
    double begin = 0.8,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }

  // Slide in animation
  static Widget slideIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeOut,
    Offset begin = const Offset(0, 0.3),
    Offset end = Offset.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            value.dx * MediaQuery.of(context).size.width,
            value.dy * MediaQuery.of(context).size.height,
          ),
          child: child,
        );
      },
      child: child,
    );
  }

  // Combined fade and scale animation
  static Widget fadeScaleIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeOut,
    double fadeBegin = 0.0,
    double fadeEnd = 1.0,
    double scaleBegin = 0.8,
    double scaleEnd = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final fadeValue = fadeBegin + (fadeEnd - fadeBegin) * value;
        final scaleValue = scaleBegin + (scaleEnd - scaleBegin) * value;

        return Opacity(
          opacity: fadeValue,
          child: Transform.scale(scale: scaleValue, child: child),
        );
      },
      child: child,
    );
  }

  // Staggered animation for lists
  static Widget staggeredList({
    required List<Widget> children,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Duration itemDuration = normal,
    Curve curve = easeOut,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return TweenAnimationBuilder<double>(
          duration: itemDuration + (staggerDelay * index),
          curve: curve,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }

  // Hover animation for interactive elements
  static Widget hoverScale({
    required Widget child,
    double scale = 1.05,
    Duration duration = fast,
    Curve curve = easeOut,
  }) {
    return MouseRegion(
      child: AnimatedScale(
        scale: 1.0,
        duration: duration,
        curve: curve,
        child: child,
      ),
    );
  }

  // Pulse animation for attention-grabbing elements
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: minScale, end: maxScale),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      onEnd: () {
        // This would need to be handled by a parent widget or state management
      },
      child: child,
    );
  }

  // Shake animation for error states
  static Widget shake({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double intensity = 10.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final shake = intensity * (0.5 - (value - 0.5).abs()) * 2;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: child,
    );
  }
}

// Custom page route with modern transitions
class ModernPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;
  final Curve curve;

  ModernPageRoute({
    required this.child,
    this.duration = ModernAnimations.normal,
    this.curve = ModernAnimations.easeOut,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(
             opacity: animation,
             child: SlideTransition(
               position: Tween<Offset>(
                 begin: const Offset(0.0, 0.1),
                 end: Offset.zero,
               ).animate(CurvedAnimation(parent: animation, curve: curve)),
               child: child,
             ),
           );
         },
       );
}

// Loading animation widget
class ModernLoadingIndicator extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;

  const ModernLoadingIndicator({
    super.key,
    this.color,
    this.size = 24.0,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<ModernLoadingIndicator> createState() => _ModernLoadingIndicatorState();
}

class _ModernLoadingIndicatorState extends State<ModernLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14159,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  (widget.color ?? AppColors.primary).withOpacity(0.3),
                  widget.color ?? AppColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Success checkmark animation
class SuccessCheckmark extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const SuccessCheckmark({
    super.key,
    this.size = 24.0,
    this.color = AppColors.success,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<SuccessCheckmark> createState() => _SuccessCheckmarkState();
}

class _SuccessCheckmarkState extends State<SuccessCheckmark>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
            child: CustomPaint(
              painter: CheckmarkPainter(
                progress: _checkAnimation.value,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final checkmarkPath = Path();

    // Draw checkmark
    checkmarkPath.moveTo(size.width * 0.2, size.height * 0.5);
    checkmarkPath.lineTo(size.width * 0.45, size.height * 0.7);
    checkmarkPath.lineTo(size.width * 0.8, size.height * 0.3);

    final pathMetrics = checkmarkPath.computeMetrics();
    for (final pathMetric in pathMetrics) {
      final extractPath = pathMetric.extractPath(
        0.0,
        pathMetric.length * progress,
      );
      path.addPath(extractPath, Offset.zero);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
