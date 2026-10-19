import 'package:flutter/material.dart';

class RacBrand extends StatelessWidget {
  const RacBrand({super.key, this.inverse = false});
  final bool inverse;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: inverse
              ? const Color(0xFFC5E8AD)
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.people_alt_rounded,
          size: 23,
          color: inverse
              ? const Color(0xFF183F31)
              : Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      const SizedBox(width: 10),
      Text(
        'RAC',
        style: TextStyle(
          fontSize: 24,
          letterSpacing: -1,
          fontWeight: FontWeight.w900,
          color: inverse ? Colors.white : null,
        ),
      ),
    ],
  );
}

/// Decorative activity tiles use no invented profiles, ratings or availability.
class ActivityArtwork extends StatelessWidget {
  const ActivityArtwork({super.key});
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: 244,
      width: 285,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 12,
            left: 10,
            child: Transform.rotate(
              angle: -.10,
              child: _tile(
                Icons.local_cafe_outlined,
                'Un café y una charla',
                const Color(0xFFF0CCA9),
                225,
              ),
            ),
          ),
          Positioned(
            top: 88,
            right: 0,
            child: Transform.rotate(
              angle: .07,
              child: _tile(
                Icons.directions_run_rounded,
                'Kilómetros en compañía',
                const Color(0xFFC5E8AD),
                240,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 12,
            child: Transform.rotate(
              angle: -.04,
              child: _tile(
                Icons.movie_outlined,
                'Una buena película',
                const Color(0xFFE8E5F5),
                230,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  Widget _tile(IconData icon, String text, Color color, double width) =>
      Container(
        width: width,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF183F31), size: 27),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF183F31),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
}

class PageIntro extends StatelessWidget {
  const PageIntro({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
  });
  final String eyebrow, title, description;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        description,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
      ),
      const SizedBox(height: 26),
    ],
  );
}
