import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeOutBack)).animate(_logoCtrl);

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(_logoCtrl);

    _rotate = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -0.06, end: 0.06), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.06, end: -0.02), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -0.02, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeInOut));

    _logoCtrl.forward();

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) {
            final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween(begin: 0.98, end: 1.0).animate(curved),
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.primaryContainer.withOpacity(0.9),
              color.primary.withOpacity(0.85),
              color.tertiary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _logoCtrl,
              builder: (context, _) {
                return Opacity(
                  opacity: _fade.value,
                  child: Transform(
                    alignment: Alignment.center,
                    transform:
                        Matrix4.identity()
                          ..scale(_scale.value)
                          ..rotateZ(_rotate.value),
                    child: _LogoMark(color: color),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: _ShimmerBar(controller: _shimmerCtrl),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.color});
  final ColorScheme color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.15),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.onPrimaryContainer.withOpacity(0.06),
                    Colors.white.withOpacity(0.18),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 44,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
            ),
            Positioned(
              bottom: 6,
              right: 14,
              child: Transform.rotate(
                angle: -math.pi / 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        size: 16,
                        color: Colors.white.withOpacity(0.95),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Track',
                        style: TextStyle(
                          letterSpacing: 0.4,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors: [Colors.white, Colors.white.withOpacity(0.85)],
              ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: const Text(
            'Splitwise Tracker',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Opacity(
          opacity: 0.9,
          child: Text(
            'Smart expense tracking',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13.5,
              letterSpacing: 0.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return SizedBox(
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _ShimmerPainter(
                progress: controller.value,
                color: color,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter({required this.progress, required this.color});
  final double progress;
  final ColorScheme color;

  @override
  void paint(Canvas canvas, Size size) {
    final base =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(0.25),
              Colors.transparent,
            ],
            stops: const [0.2, 0.5, 0.8],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final x = (size.width + size.width * 0.6) * progress - size.width * 0.3;
    final rect = Rect.fromLTWH(
      x - size.width * 0.3,
      0,
      size.width * 0.6,
      size.height,
    );
    canvas.drawRect(rect, base);

    final fill = Paint()..color = color.onPrimary.withOpacity(0.08);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(99)),
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
