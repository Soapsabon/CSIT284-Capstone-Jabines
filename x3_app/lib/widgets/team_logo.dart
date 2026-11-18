import 'package:flutter/material.dart';

/// Shows the team's logoUrl if present, otherwise a colored initial badge.
class TeamLogo extends StatelessWidget {
  const TeamLogo({super.key, required this.name, this.url = '', this.size = 44});

  final String name;
  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed.split(' ').last[0].toUpperCase();
    final hue = (trimmed.codeUnits.fold<int>(0, (a, b) => a + b) * 37) % 360;
    final color = HSLColor.fromAHSL(1, hue.toDouble(), 0.65, 0.5).toColor();

    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );

    if (url.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}
