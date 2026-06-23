import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twilight_foodz_customer/data/app_routes.dart';
import 'package:twilight_foodz_customer/views/pages/generate_otp.dart';
import 'package:twilight_foodz_customer/views/widgets/page_transition.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome>
    with TickerProviderStateMixin {
  // ---- palette ----
  static const _ink = Color(0xFF1B1410);
  static const _inkDeep = Color(0xFF140F0B);
  static const _inkSoft = Color(0xFF2A2018);
  static const _cream = Color(0xFFF7EFE3);
  static const _amber = Color(0xFFE8A33D);
  static const _coral = Color(0xFFE8603C);
  static const _coralDeep = Color(0xFFC9491F);
  static const _sage = Color(0xFF8A9A5B);

  late final AnimationController _glowController;
  late final List<AnimationController> _steamControllers;
  late final List<AnimationController> _garnishControllers;
  static const _steamConfigs = [
    _SteamConfig(
      durationMs: 7000,
      delayMs: 0,
      leftFrac: .45,
      size: 44,
      dx: -12,
    ),
    _SteamConfig(
      durationMs: 6000,
      delayMs: 1400,
      leftFrac: .53,
      size: 32,
      dx: 14,
    ),
    _SteamConfig(
      durationMs: 8000,
      delayMs: 2700,
      leftFrac: .40,
      size: 28,
      dx: -5,
    ),
    _SteamConfig(
      durationMs: 6600,
      delayMs: 3600,
      leftFrac: .57,
      size: 36,
      dx: 9,
    ),
    _SteamConfig(
      durationMs: 7400,
      delayMs: 900,
      leftFrac: .49,
      size: 24,
      dx: 0,
    ),
  ];

  static const _garnishConfigs = [
    _GarnishConfig(
      durationMs: 4600,
      delayMs: 0,
      topFrac: .16,
      leftFrac: .13,
      size: 11,
      color: _sage,
    ),
    _GarnishConfig(
      durationMs: 5400,
      delayMs: 600,
      topFrac: .28,
      rightFrac: .11,
      size: 8,
      color: _amber,
    ),
    _GarnishConfig(
      durationMs: 3900,
      delayMs: 300,
      topFrac: .11,
      rightFrac: .24,
      size: 6,
      color: _cream,
      opacity: .6,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    // Each steam piece loops on its own duration, and only starts repeating
    // after its own delay — mirroring CSS animation-duration + -delay.
    _steamControllers = _steamConfigs.map((cfg) {
      final c = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: cfg.durationMs),
      );
      Future.delayed(Duration(milliseconds: cfg.delayMs), () {
        if (mounted) c.repeat();
      });
      return c;
    }).toList();

    _garnishControllers = _garnishConfigs.map((cfg) {
      final c = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: cfg.durationMs),
      );
      Future.delayed(Duration(milliseconds: cfg.delayMs), () {
        if (mounted) c.repeat(reverse: true);
      });
      return c;
    }).toList();
  }

  @override
  void dispose() {
    _glowController.dispose();
    for (final c in _steamControllers) {
      c.dispose();
    }
    for (final c in _garnishControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ink,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.7),
            radius: 0.2,
            colors: [_inkSoft, _ink, _inkDeep],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          // OrientationBuilder lets us switch between a stacked (portrait)
          // layout and a side-by-side (landscape) layout, since in
          // landscape the screen height is short and the old 56%/44%
          // stacked split left too little room for the content panel.
          child: OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLandscape ? 24 : 28,
                  vertical: 6,
                ),
                child: isLandscape
                    ? Row(
                        children: [
                          Expanded(flex: 45, child: _buildHero()),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 55,
                            child: _buildContent(isLandscape: true),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(flex: 56, child: _buildHero()),
                          Expanded(
                            flex: 44,
                            child: _buildContent(isLandscape: false),
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------- hero / animation zone ----------------

  Widget _buildHero() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 6,
              left: 0,
              child: Text(
                'Twilight',
                textAlign: TextAlign.center,
                style: GoogleFonts.fraunces(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  fontSize: 30,
                  color: _amber,
                  letterSpacing: 1,
                ),
              ),
            ),
            for (int i = 0; i < _garnishConfigs.length; i++)
              _buildGarnish(i, w, h),
            _buildGlow(w, h),
            for (int i = 0; i < _steamConfigs.length; i++) _buildSteam(i, w, h),
            _buildBowlRim(w, h),
            _buildBowl(w, h),
          ],
        );
      },
    );
  }

  Widget _buildGlow(double w, double h) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final t = _glowController.value;
        return Positioned(
          left: w / 2 - 115,
          bottom: h * 0.20 - 5,
          child: Transform.scale(
            scale: 1 + 0.06 * t,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Opacity(
                opacity: 0.35 + 0.20 * t,
                child: Container(
                  width: 230,
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [_coral.withValues(alpha:0.7), _coral.withValues(alpha:0)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBowlRim(double w, double h) {
    return Positioned(
      left: w / 2 - 88,
      bottom: h * 0.20 + 58,
      child: Container(
        width: 176,
        height: 18,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF08A5E), _coral],
          ),
        ),
      ),
    );
  }

  Widget _buildBowl(double w, double h) {
    return Positioned(
      left: w / 2 - 88,
      bottom: h * 0.20,
      child: Container(
        width: 176,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.elliptical(88, 51),
            topRight: Radius.elliptical(88, 51),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_coral, _coralDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.35),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSteam(int i, double w, double h) {
    final cfg = _steamConfigs[i];
    return AnimatedBuilder(
      animation: _steamControllers[i],
      builder: (context, _) {
        final t = _steamControllers[i].value;
        final dy = -195.0 * t;
        final dx = cfg.dx * 2 * t;
        final scale = 0.55 + 0.75 * t;
        // sin(pi*t) is already within [0,1] for t in [0,1] — smooth fade
        // in, peak around the midpoint, fade out, just like the CSS keyframes.
        final opacity = math.sin(math.pi * t) * 0.55;

        return Positioned(
          left: w * cfg.leftFrac - cfg.size / 2,
          bottom: h * 0.20 + 70,
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    width: cfg.size,
                    height: cfg.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _cream.withValues(alpha:0.95),
                          _amber.withValues(alpha:0),
                        ],
                        stops: const [0.0, 0.72],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGarnish(int i, double w, double h) {
    final cfg = _garnishConfigs[i];
    return AnimatedBuilder(
      animation: _garnishControllers[i],
      builder: (context, _) {
        final t = _garnishControllers[i].value;
        return Positioned(
          top: h * cfg.topFrac,
          left: cfg.leftFrac != null ? w * cfg.leftFrac! : null,
          right: cfg.rightFrac != null ? w * cfg.rightFrac! : null,
          child: Transform.translate(
            offset: Offset(0, -14 * t),
            child: Transform.rotate(
              angle: (10 * t) * math.pi / 180,
              child: Container(
                width: cfg.size,
                height: cfg.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cfg.color.withValues(alpha:cfg.opacity),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- content zone ----------------

  Widget _buildContent({required bool isLandscape}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final headlineSize =
            (constraints.maxHeight * (isLandscape ? 0.14 : 0.062))
                .clamp(22.0, 32.0)
                .toDouble();

        // SingleChildScrollView + ConstrainedBox(minHeight) + IntrinsicHeight
        // is the standard Flutter combo for "Spacer pins content to the
        // bottom when there's room, but scrolls instead of overflowing
        // when there isn't" — covers landscape, small screens, and large
        // accessibility text sizes without changing how it looks normally.
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME TO TWILIGHT',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.2,
                        color: _cream.withValues(alpha:.5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Text(
                        "Good food doesn't sleep.",
                        style: GoogleFonts.fraunces(
                          fontSize: headlineSize,
                          fontWeight: FontWeight.w600,
                          height: 1.12,
                          color: _cream,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Text(
                        "Hot meals from kitchens near you, delivered in minutes — whatever hour you're hungry.",
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          height: 1.55,
                          color: _cream.withValues(alpha:.62),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.generateOtp,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _amber,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get started',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: _ink,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _cream.withValues(alpha:.5),
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Log in',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SteamConfig {
  final int durationMs;
  final int delayMs;
  final double leftFrac;
  final double size;
  final double dx;

  const _SteamConfig({
    required this.durationMs,
    required this.delayMs,
    required this.leftFrac,
    required this.size,
    required this.dx,
  });
}

class _GarnishConfig {
  final int durationMs;
  final int delayMs;
  final double topFrac;
  final double? leftFrac;
  final double? rightFrac;
  final double size;
  final Color color;
  final double opacity;

  const _GarnishConfig({
    required this.durationMs,
    required this.delayMs,
    required this.topFrac,
    this.leftFrac,
    this.rightFrac,
    required this.size,
    required this.color,
    this.opacity = 1.0,
  });
}
