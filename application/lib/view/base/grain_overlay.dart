// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Fine, animated film grain (1 physical pixel per speck, like real film).
///
///   Stack(children: [
///     gradientContainer,
///     const Positioned.fill(child: GrainOverlay()),
///     content,
///   ])
///
/// How it works (cheap on purpose): a small noise tile is generated once and
/// cached. Every tick the tile is shifted to a random spot, so the grain
/// shimmers like film without redrawing thousands of dots. Only the grain
/// layer repaints, never the content under it.
class GrainOverlay extends StatefulWidget {
  /// Share of pixels that carry a speck. 0.30 = airy, 0.55 = dense.
  final double density;

  /// Strength of the brightest speck. 0.12 = subtle, 0.30 = strong.
  final double opacity;

  /// Set false for a still grain.
  final bool animate;

  /// Grain refresh rate. 10-14 looks like film; higher costs more battery.
  final int fps;

  const GrainOverlay({
    super.key,
    this.density = 0.42,
    this.opacity = 0.20,
    this.animate = true,
    this.fps = 50,
  });

  @override
  State<GrainOverlay> createState() => _GrainOverlayState();
}

class _GrainOverlayState extends State<GrainOverlay> {
  static final Map<String, Future<ui.Image>> _cache = {};

  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  Timer? _timer;
  ui.Image? _tile;

  @override
  void initState() {
    super.initState();
    _loadTile();
    if (widget.animate) _startTimer();
  }

  @override
  void didUpdateWidget(covariant GrainOverlay old) {
    super.didUpdateWidget(old);
    if (old.density != widget.density || old.opacity != widget.opacity) {
      _loadTile();
    }
    if (widget.animate && _timer == null) {
      _startTimer();
    } else if (!widget.animate && _timer != null) {
      _stopTimer();
    } else if (widget.animate && old.fps != widget.fps) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    final period = Duration(microseconds: 1000000 ~/ max(1, widget.fps));
    _timer = Timer.periodic(period, (_) => _frame.value++);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _loadTile() {
    final key = '${widget.density}-${widget.opacity}';
    final future = _cache.putIfAbsent(
      key,
      () => _makeTile(widget.density, widget.opacity),
    );
    future.then((img) {
      if (mounted) setState(() => _tile = img);
    });
  }

  /// 128x128 tile of white noise with variable alpha (RGB stays 255 so the
  /// srcIn color filter tints cleanly on every backend).
  static Future<ui.Image> _makeTile(double density, double opacity) {
    const size = 128;
    final rnd = Random(11);
    final bytes = Uint8List(size * size * 4);
    final maxA = (opacity.clamp(0.0, 1.0) * 255).toInt();
    for (var i = 0; i < size * size; i++) {
      final base = i * 4;
      bytes[base] = 255;
      bytes[base + 1] = 255;
      bytes[base + 2] = 255;
      if (rnd.nextDouble() < density) {
        bytes[base + 3] = (maxA * (0.35 + 0.65 * rnd.nextDouble())).toInt();
      }
    }
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      bytes,
      size,
      size,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  @override
  void dispose() {
    _stopTimer();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _GrainPainter(tile: _tile, frame: _frame, dpr: dpr),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final ui.Image? tile;
  final ValueListenable<int> frame;
  final double dpr;

  // Pre-built once, reused every paint. BlendMode stays default (srcOver) —
  // srcIn on a transparent layer would draw nothing.
  final Paint _light = Paint();
  final Paint _dark = Paint();
  final Float64List _m = Float64List(16);

  _GrainPainter({required this.tile, required this.frame, required this.dpr})
      : super(repaint: frame) {
    _light.colorFilter = ColorFilter.mode(Colors.white, BlendMode.srcIn);
    _dark.colorFilter =
        ColorFilter.mode(Colors.black.withOpacity(0.85), BlendMode.srcIn);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = tile;
    if (t == null || size.isEmpty) return;

    final rnd = Random(frame.value * 7919 + 13);
    final rect = Offset.zero & size;

    for (final paint in [_light, _dark]) {
      _m
        ..[0] = 1 / dpr
        ..[1] = 0
        ..[2] = 0
        ..[3] = 0
        ..[4] = 0
        ..[5] = 1 / dpr
        ..[6] = 0
        ..[7] = 0
        ..[8] = 0
        ..[9] = 0
        ..[10] = 1
        ..[11] = 0
        ..[12] = rnd.nextDouble() * 256
        ..[13] = rnd.nextDouble() * 256
        ..[14] = 0
        ..[15] = 1;
      paint.shader =
          ui.ImageShader(t, TileMode.repeated, TileMode.repeated, _m);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) =>
      old.tile != tile || old.dpr != dpr;
}