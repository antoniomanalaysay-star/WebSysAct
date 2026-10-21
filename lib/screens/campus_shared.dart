// Shared look & feel for Campus Connect (ported from ManLoginPro style).
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/* ---------------- palette (same values as the PHP :root) ---------------- */
class C {
  static const ink900 = Color(0xFF04100A);
  static const ink800 = Color(0xFF071A10);
  static const ink700 = Color(0xFF0A2415);
  static const ink600 = Color(0xFF0E3020);
  static const ink500 = Color(0xFF143C28);
  static const line = Color(0xFF1D5236);
  static const lineHi = Color(0xFF2B6D48);
  static const leaf = Color(0xFF4CAF50);
  static const lime = Color(0xFFA8E063);
  static const forest = Color(0xFF1F7A43);
  static const gold = Color(0xFFF5C518);
  static const goldHi = Color(0xFFFFE066);
  static const text = Color(0xFFE7F3E9);
  static const muted = Color(0xFF8FAE99);
  static const label = Color(0xFF9CC4A8);
  static const onGradient = Color(0xFF06210F);
}

/// Version-safe alternative to withOpacity / withValues.
Color fade(Color c, double o) => c.withAlpha((o * 255).round());

/* ---------------- fake auth service (no backend needed) ---------------- */
class _User {
  final String username, email, password;
  _User(this.username, this.email, this.password);
}

class AuthService {
  static final Map<String, _User> _users = {
    'demo@campus.edu': _User('Demo Student', 'demo@campus.edu', 'demo1234'),
  };
  static String? currentUsername;

  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final u = _users[email.toLowerCase()];
    if (u == null || u.password != password) return false;
    currentUsername = u.username;
    return true;
  }

  /// Returns an error message, or null on success.
  static Future<String?> register(
      String username, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (_users.containsKey(email.toLowerCase())) {
      return 'That email is already registered.';
    }
    _users[email.toLowerCase()] = _User(username, email, password);
    return null;
  }

  static void logout() => currentUsername = null;
}

/* ---------------- logo: hex shield + grad cap (CustomPainter) ---------------- */
class _MarkPainter extends CustomPainter {
  final bool glow;
  _MarkPainter(this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 120, size.height / 120);

    final outer = Path()
      ..moveTo(60, 4)
      ..lineTo(108, 30)
      ..lineTo(108, 76)
      ..lineTo(60, 116)
      ..lineTo(12, 76)
      ..lineTo(12, 30)
      ..close();
    final inner = Path()
      ..moveTo(60, 15)
      ..lineTo(98, 36)
      ..lineTo(98, 71)
      ..lineTo(60, 104)
      ..lineTo(22, 71)
      ..lineTo(22, 36)
      ..close();

    if (glow) {
      canvas.drawPath(
        outer,
        Paint()
          ..color = fade(C.gold, 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );
    }

    canvas.drawPath(
      outer,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(12, 4),
          const Offset(108, 116),
          const [Color(0xFFFFE56B), Color(0xFFB9E04B), Color(0xFF1F7A43)],
          const [0, 0.42, 1],
        ),
    );
    canvas.drawPath(inner, Paint()..color = const Color(0xFF05130C));

    // graduation cap
    final cap = Path()
      ..moveTo(60, 34)
      ..lineTo(92, 47)
      ..lineTo(60, 60)
      ..lineTo(28, 47)
      ..close();
    canvas.drawPath(
      cap,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 34),
          const Offset(0, 60),
          const [Color(0xFFFFE98A), Color(0xFFF5C518)],
        ),
    );
    final band = Path()
      ..moveTo(39, 52.5)
      ..lineTo(39, 66)
      ..cubicTo(39, 71.2, 48.4, 74.8, 60, 74.8)
      ..cubicTo(71.6, 74.8, 81, 71.2, 81, 66)
      ..lineTo(81, 52.5);
    canvas.drawPath(
      band,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF8FD14F),
    );

    // tassel
    final gold = Paint()..color = const Color(0xFFFFD93D);
    canvas.drawLine(
      const Offset(92, 47),
      const Offset(92, 62),
      Paint()
        ..color = const Color(0xFFFFD93D)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(92, 66), 4, gold);

    // connection nodes
    final nodes = Path()
      ..moveTo(45, 83)
      ..lineTo(60, 92)
      ..lineTo(75, 83);
    canvas.drawPath(
      nodes,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = fade(C.lime, 0.95),
    );
    canvas.drawCircle(const Offset(45, 83), 4.4, Paint()..color = C.gold);
    canvas.drawCircle(const Offset(60, 92), 5, Paint()..color = C.lime);
    canvas.drawCircle(const Offset(75, 83), 4.4, Paint()..color = C.gold);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MarkPainter old) => old.glow != glow;
}

class CampusMark extends StatelessWidget {
  final double size;
  final bool glow;
  const CampusMark({super.key, required this.size, this.glow = false});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _MarkPainter(glow)),
      );
}

/// Centered logo with the pulsing radial halo.
class GlowLogo extends StatefulWidget {
  final double size;
  const GlowLogo({super.key, this.size = 112});

  @override
  State<GlowLogo> createState() => _GlowLogoState();
}

class _GlowLogoState extends State<GlowLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4500))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final halo = widget.size * 1.48;
    return SizedBox(
      width: halo,
      height: halo,
      child: Stack(alignment: Alignment.center, children: [
        AnimatedBuilder(
          animation: _c,
          builder: (_, __) => Opacity(
            opacity: 0.75 + 0.25 * _c.value,
            child: Transform.scale(
              scale: 1 + 0.06 * _c.value,
              child: Container(
                width: halo,
                height: halo,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    fade(C.gold, 0.30),
                    fade(C.lime, 0.12),
                    fade(C.lime, 0),
                  ], stops: const [
                    0,
                    0.45,
                    0.72
                  ]),
                ),
              ),
            ),
          ),
        ),
        CampusMark(size: widget.size, glow: true),
      ]),
    );
  }
}

class WordMark extends StatelessWidget {
  const WordMark({super.key});
  @override
  Widget build(BuildContext context) => const Text.rich(
        TextSpan(children: [
          TextSpan(text: 'CAMPUS', style: TextStyle(color: C.lime)),
          TextSpan(text: 'CONNECT', style: TextStyle(color: C.gold)),
        ]),
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        textAlign: TextAlign.center,
      );
}

/* ---------------- gentle drifting animation ---------------- */
class Drift extends StatefulWidget {
  final Duration period;
  final double phase, dx, dy;
  final Widget child;
  const Drift({
    super.key,
    required this.period,
    required this.child,
    this.phase = 0,
    this.dx = 16,
    this.dy = 22,
  });

  @override
  State<Drift> createState() => _DriftState();
}

class _DriftState extends State<Drift> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period)
        ..value = widget.phase % 1.0
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (_, child) {
        final t = _c.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(widget.dx * math.sin(t),
              widget.dy * math.cos(t + widget.phase * 6)),
          child: child,
        );
      },
    );
  }
}

/* ---------------- left artwork panel ---------------- */
class _ScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, s.height),
          const [Color(0xFF04100A), Color(0xFF07200F), Color(0xFF0E3A1F)],
          const [0, 0.42, 1],
        ),
    );
    final sx = s.width / 800, sy = s.height / 900;
    void hill(List<double> v, Color col) {
      final p = Path()
        ..moveTo(0, v[0] * sy)
        ..quadraticBezierTo(v[1] * sx, v[2] * sy, v[3] * sx, v[4] * sy)
        ..quadraticBezierTo(v[5] * sx, v[6] * sy, 800 * sx, v[7] * sy)
        ..lineTo(800 * sx, 900 * sy)
        ..lineTo(0, 900 * sy)
        ..close();
      canvas.drawPath(p, Paint()..color = col);
    }

    hill([520, 200, 460, 400, 500, 600, 540, 480],
        fade(const Color(0xFF1D5C36), 0.85));
    hill([610, 220, 570, 420, 600, 620, 630, 580], const Color(0xFF144228));
    hill([700, 240, 670, 460, 690, 680, 710, 675], const Color(0xFF0C2C1B));

    final g = Paint()..color = fade(C.gold, 0.75);
    for (final p in const [
      Offset(120, 120),
      Offset(340, 150),
      Offset(650, 60),
      Offset(720, 230)
    ]) {
      canvas.drawCircle(Offset(p.dx * sx, p.dy * sy), 2, g);
    }
    final l = Paint()..color = fade(C.lime, 0.7);
    for (final p in const [
      Offset(220, 80),
      Offset(500, 90),
      Offset(60, 220),
      Offset(420, 60),
      Offset(770, 140)
    ]) {
      canvas.drawCircle(Offset(p.dx * sx, p.dy * sy), 1.5, l);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _FloaterSpec {
  final IconData? icon; // null => logo
  final bool gold;
  final double size, top, left, opacity;
  final int seconds;
  final double phase;
  final bool compactVisible;
  const _FloaterSpec(this.icon, this.gold, this.size, this.top, this.left,
      this.opacity, this.seconds, this.phase, this.compactVisible);
}

const _floaters = <_FloaterSpec>[
  _FloaterSpec(null, false, 86, .16, .11, .68, 16, 0.0, true),
  _FloaterSpec(Icons.groups_outlined, false, 46, .44, .30, .45, 21, .2, true),
  _FloaterSpec(
      Icons.calendar_month_outlined, true, 54, .30, .66, .48, 19, .4, true),
  _FloaterSpec(
      Icons.chat_bubble_outline, false, 38, .63, .19, .36, 26, .5, false),
  _FloaterSpec(null, false, 62, .56, .73, .46, 24, .35, false),
  _FloaterSpec(Icons.school_outlined, false, 42, .09, .45, .40, 22, .1, true),
  _FloaterSpec(null, false, 46, .74, .47, .30, 30, .5, false),
  _FloaterSpec(Icons.hub_outlined, true, 40, .22, .84, .34, 28, .21, false),
];

class ArtPanel extends StatelessWidget {
  final bool compact;
  final String headline, highlight, body;
  const ArtPanel({
    super.key,
    required this.compact,
    required this.headline,
    required this.highlight,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth, h = c.maxHeight;
        final moon = compact ? 120.0 : 220.0;
        return Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _ScenePainter())),

          // logo as glowing "sun"
          Positioned(
            top: h * 0.08,
            right: w * (compact ? 0.08 : 0.13),
            child: Drift(
              period: const Duration(seconds: 20),
              dx: 12,
              dy: 16,
              child: SizedBox(
                width: moon * 1.4,
                height: moon * 1.4,
                child: Stack(alignment: Alignment.center, children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        fade(C.gold, 0.20),
                        fade(C.lime, 0.10),
                        fade(C.lime, 0),
                      ], stops: const [
                        0,
                        0.45,
                        0.72
                      ]),
                    ),
                  ),
                  Opacity(
                      opacity: 0.5, child: CampusMark(size: moon, glow: true)),
                ]),
              ),
            ),
          ),

          // floating tiles & logos
          for (final f in _floaters)
            if (!compact || f.compactVisible)
              Positioned(
                left: w * f.left,
                top: h * f.top,
                child: Drift(
                  period: Duration(seconds: f.seconds),
                  phase: f.phase,
                  child: Opacity(
                    opacity: f.opacity,
                    child: f.icon == null
                        ? CampusMark(size: compact ? f.size * .7 : f.size)
                        : Container(
                            width: f.size,
                            height: f.size,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: fade(f.gold ? C.gold : C.leaf, 0.12),
                              border: Border.all(
                                  color: fade(
                                      f.gold ? C.goldHi : C.lime,
                                      f.gold ? 0.30 : 0.26)),
                            ),
                            child: Icon(f.icon,
                                size: f.size * .55,
                                color: f.gold
                                    ? const Color(0xFFFFE9A3)
                                    : const Color(0xFFD6F2C4)),
                          ),
                  ),
                ),
              ),

          Positioned(
            left: compact ? 28 : 48,
            right: compact ? 28 : 48,
            bottom: compact ? 22 : 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '$headline '),
                    TextSpan(
                        text: highlight, style: const TextStyle(color: C.gold)),
                    const TextSpan(text: '.'),
                  ]),
                  style: TextStyle(
                      fontSize: compact ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(body,
                    style: TextStyle(
                        fontSize: compact ? 13 : 15,
                        color: const Color(0xFFC6DFCD))),
              ],
            ),
          ),
        ]);
      }),
    );
  }
}

/* ---------------- two-pane shell used by login & signup ---------------- */
class AuthShell extends StatelessWidget {
  final String title, subtitle;
  final String headline, highlight, caption;
  final Widget child;
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.headline,
    required this.highlight,
    required this.caption,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.ink900,
      body: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth > 820;
        final art = ArtPanel(
            compact: !wide,
            headline: headline,
            highlight: highlight,
            body: caption);
        final form = Container(
          decoration: BoxDecoration(
            color: C.ink800,
            border: Border(
              left: wide ? const BorderSide(color: C.line) : BorderSide.none,
              top: wide ? BorderSide.none : const BorderSide(color: C.line),
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: wide ? 64 : 28, vertical: wide ? 48 : 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: GlowLogo(size: wide ? 112 : 88)),
                    const SizedBox(height: 8),
                    const WordMark(),
                    const SizedBox(height: 22),
                    Text(title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF3FAF3))),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: C.muted)),
                    const SizedBox(height: 22),
                    child,
                  ],
                ),
              ),
            ),
          ),
        );

        if (wide) {
          return Row(children: [
            Expanded(flex: 58, child: art),
            Expanded(flex: 42, child: form),
          ]);
        }
        return Column(children: [
          SizedBox(height: 220, child: art),
          Expanded(child: form),
        ]);
      }),
    );
  }
}

/* ---------------- inputs / buttons / banners ---------------- */
InputDecoration campusDecoration({String? hint, Widget? suffix, Widget? prefix}) {
  OutlineInputBorder b(Color col, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: col, width: w),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF5D7A68)),
    filled: true,
    fillColor: C.ink700,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    suffixIcon: suffix,
    prefixIcon: prefix,
    border: b(C.line),
    enabledBorder: b(C.line),
    disabledBorder: b(fade(C.line, 0.5)),
    focusedBorder: b(C.lime, 1.5),
    errorBorder: b(C.gold),
    focusedErrorBorder: b(C.goldHi, 1.5),
    errorStyle: const TextStyle(color: Color(0xFFFFC86B), fontSize: 12),
  );
}

class CampusField extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final String? hint;
  final bool obscure, enabled, readOnly;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final Widget? suffix;

  const CampusField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.obscure = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.onTap,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(label!,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: C.label,
                    letterSpacing: 0.4)),
          ),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: obscure ? 1 : maxLines,
          maxLength: maxLength,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          onChanged: onChanged,
          onTap: onTap,
          cursorColor: C.lime,
          style: const TextStyle(color: C.text, fontSize: 14),
          decoration: campusDecoration(hint: hint, suffix: suffix),
        ),
      ],
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading, expand;
  final IconData? icon;
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2.2, color: C.onGradient),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: C.onGradient),
          const SizedBox(width: 8),
        ],
        Text(label,
            style: const TextStyle(
                color: C.onGradient,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.6)),
      ],
    );
    return Opacity(
      opacity: enabled || loading ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [C.gold, C.lime, C.forest],
              stops: [0, 0.55, 1],
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 22),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class OutlineAction extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  const OutlineAction(
      {super.key, required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.arrow_forward, size: 18),
        label: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 0.4)),
        style: OutlinedButton.styleFrom(
          foregroundColor: C.lime,
          side: const BorderSide(color: C.lineHi),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
}

enum NoticeKind { error, success, info }

class Notice extends StatelessWidget {
  final NoticeKind kind;
  final String? title;
  final String message;
  final List<Widget> actions;
  final Widget? extra;
  const Notice({
    super.key,
    required this.kind,
    required this.message,
    this.title,
    this.actions = const [],
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    late final Color bg, fg, accent;
    late final IconData icon;
    switch (kind) {
      case NoticeKind.error:
        bg = const Color(0xFF3A2410);
        fg = const Color(0xFFFFC86B);
        accent = C.gold;
        icon = Icons.error_outline;
        break;
      case NoticeKind.success:
        bg = const Color(0xFF123A22);
        fg = const Color(0xFF9CE8B0);
        accent = C.leaf;
        icon = Icons.check_circle_outline;
        break;
      case NoticeKind.info:
        bg = C.ink600;
        fg = C.text;
        accent = C.lime;
        icon = Icons.info_outline;
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: bg,
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(width: 3, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(icon, size: 18, color: fg),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(title!,
                                      style: TextStyle(
                                          color: fg,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ),
                              Text(message,
                                  style: TextStyle(
                                      color: fg, fontSize: 13, height: 1.35)),
                            ],
                          ),
                        ),
                      ]),
                      if (extra != null) ...[const SizedBox(height: 10), extra!],
                      if (actions.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(spacing: 10, runSpacing: 8, children: actions),
                      ],
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}