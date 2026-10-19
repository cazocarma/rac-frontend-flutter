import 'package:flutter/material.dart';

ThemeData racTheme(Brightness brightness) {
  final light = brightness == Brightness.light;
  final colors =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF176B58),
        brightness: brightness,
      ).copyWith(
        primary: light ? const Color(0xFF176B58) : const Color(0xFF91D5BC),
        onPrimary: light ? Colors.white : const Color(0xFF103D32),
        surface: light ? Colors.white : const Color(0xFF192822),
        primaryContainer: light
            ? const Color(0xFFE0EFE7)
            : const Color(0xFF244D3F),
        onPrimaryContainer: light
            ? const Color(0xFF174D3D)
            : const Color(0xFFC4EDDA),
        outlineVariant: light
            ? const Color(0xFFE1E7E1)
            : const Color(0xFF35473D),
      );
  final base = ThemeData(useMaterial3: true, colorScheme: colors);
  return base.copyWith(
    scaffoldBackgroundColor: light
        ? const Color(0xFFF6F7F2)
        : const Color(0xFF101C17),
    textTheme: base.textTheme.apply(
      bodyColor: light ? const Color(0xFF243E33) : const Color(0xFFE1EBE4),
      displayColor: light ? const Color(0xFF183F31) : const Color(0xFFE1EBE4),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: light
          ? const Color(0xFFF6F7F2)
          : const Color(0xFF101C17),
      foregroundColor: colors.onSurface,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: colors.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerTheme: DividerThemeData(color: colors.outlineVariant, thickness: 1),
    cardTheme: CardThemeData(
      elevation: 0,
      color: colors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colors.outlineVariant),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      side: BorderSide(color: colors.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: light ? Colors.white : colors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        side: BorderSide(color: colors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surface,
      indicatorColor: colors.primaryContainer,
      height: 76,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.inverseSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

String money(num value) {
  final raw = value.toStringAsFixed(0);
  return '\$${raw.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}

String dateLabel(DateTime date) => '${date.day}/${date.month}/${date.year}';
String clockLabel(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

class PageContent extends StatelessWidget {
  const PageContent({super.key, required this.child, this.width = 1100});
  final Widget child;
  final double width;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 600 ? 16 : 32,
        ),
        child: child,
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.explore_outlined,
    this.action,
  });
  final String title, message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: .6),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              icon,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(message, textAlign: TextAlign.center),
          ),
          if (action != null)
            Padding(padding: const EdgeInsets.only(top: 24), child: action!),
        ],
      ),
    ),
  );
}

class ConstructionScreen extends StatelessWidget {
  const ConstructionScreen({
    super.key,
    required this.title,
    this.message =
        'Estamos preparando esta sección. Pronto podrás usarla desde aquí.',
  });
  final String title, message;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: EmptyState(
      title: 'En construcción',
      message: message,
      icon: Icons.handyman_outlined,
      action: OutlinedButton(
        onPressed: () => Navigator.of(context).maybePop(),
        child: const Text('Volver'),
      ),
    ),
  );
}
