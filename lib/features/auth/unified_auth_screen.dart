import 'package:flutter/material.dart';
import '../../shared/di/services.dart';
import '../../shared/services/auth_api.dart';
import '../../shared/widgets/brand.dart';

class UnifiedAuthScreen extends StatefulWidget {
  const UnifiedAuthScreen({super.key, this.auth});
  final AuthApi? auth;
  @override
  State<UnifiedAuthScreen> createState() => _UnifiedAuthScreenState();
}

class _UnifiedAuthScreenState extends State<UnifiedAuthScreen> {
  bool loading = false;
  String? error;
  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await (widget.auth ?? Services.auth).login();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'No pudimos iniciar sesión. Inténtalo nuevamente.',
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 1000;
    final story = Container(
      padding: EdgeInsets.all(compact ? 28 : 44),
      decoration: BoxDecoration(
        color: const Color(0xFF183F31),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const RacBrand(inverse: true),
          const SizedBox(height: 38),
          Text(
            'Los mejores planes\nse comparten.',
            style: TextStyle(
              fontSize: compact ? 36 : 48,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.8,
              height: 1.08,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Una caminata, un café o algo nuevo.\nEncuentra con quién disfrutarlo.',
            style: TextStyle(
              color: Color(0xFFCEE0D3),
              height: 1.6,
              fontSize: 16,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 24),
            const Center(child: ActivityArtwork()),
          ],
          const SizedBox(height: 24),
          const Text(
            'RENT-A-COMPA · BUENA COMPAÑÍA',
            style: TextStyle(
              color: Color(0xFFC5E8AD),
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
    final access = Padding(
      padding: EdgeInsets.all(compact ? 8 : 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Icon(Icons.waving_hand_outlined, color: colors.primary, size: 32),
          const SizedBox(height: 20),
          Text(
            'Tu próximo plan\nempieza aquí.',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Conoce compas, encuentra intereses en común y organiza tiempo para compartir.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 28),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: Icon(Icons.movie_outlined, size: 18),
                label: Text('Cine'),
              ),
              Chip(
                avatar: Icon(Icons.directions_run, size: 18),
                label: Text('Running'),
              ),
              Chip(
                avatar: Icon(Icons.mic_none, size: 18),
                label: Text('Karaoke'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: loading ? null : login,
              icon: Icon(
                loading ? Icons.hourglass_top : Icons.arrow_forward_rounded,
              ),
              label: Text(
                loading
                    ? 'Abriendo inicio de sesión…'
                    : 'Ingresar o crear cuenta',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Acceso seguro. Al ingresar, volverás automáticamente a RAC.',
                  style: TextStyle(fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(error!, style: TextStyle(color: colors.error)),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(compact ? 20 : 40),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: compact ? 560 : 1120),
              child: compact
                  ? Column(
                      children: [story, const SizedBox(height: 12), access],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: story),
                        const SizedBox(width: 24),
                        Expanded(child: access),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
