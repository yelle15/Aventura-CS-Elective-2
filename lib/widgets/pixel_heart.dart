import 'package:flutter/material.dart';

class PixelHeart extends StatelessWidget {
  const PixelHeart({
    super.key,
    this.size = 24,
    this.color = const Color(0xFFE53935),
    this.filled = true,
  });

  final double size;
  final Color color;
  final bool filled;

  static const List<String> _filled = [
    '.XX...XX.',
    'XWXX.XXXX',
    'XXXXXXXXX',
    'XXXXXXXXX',
    '.XXXXXXX.',
    '..XXXXX..',
    '...XXX...',
    '....X....',
  ];

  static const List<String> _outline = [
    '.XX...XX.',
    'X..X.X..X',
    'X...X...X',
    'X.......X',
    '.X.....X.',
    '..X...X..',
    '...X.X...',
    '....X....',
  ];

  @override
  Widget build(BuildContext context) {
    final rows = filled ? _filled : _outline;
    return SizedBox(
      width: size,
      height: size * rows.length / rows.first.length,
      child: CustomPaint(painter: _PixelHeartPainter(rows, color)),
    );
  }
}

class _PixelHeartPainter extends CustomPainter {
  _PixelHeartPainter(this.rows, this.color);

  final List<String> rows;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / rows.first.length;
    final fill = Paint()
      ..color = color
      ..isAntiAlias = false;
    final shine = Paint()
      ..color = Color.lerp(color, Colors.white, 0.7)!
      ..isAntiAlias = false;

    for (var y = 0; y < rows.length; y++) {
      for (var x = 0; x < rows[y].length; x++) {
        final pixel = rows[y][x];
        if (pixel == '.') continue;
        final rect = Rect.fromLTWH(x * cell, y * cell, cell + 0.5, cell + 0.5);
        canvas.drawRect(rect, pixel == 'W' ? shine : fill);
      }
    }
  }

  @override
  bool shouldRepaint(_PixelHeartPainter old) =>
      old.color != color || !identical(old.rows, rows);
}
