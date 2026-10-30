import '../../l10n/generated/app_localizations.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/account_standing.dart';

/// Informational only: write endpoints always authorize again on the server.
/// Failure preserves navigation and protective tools instead of logging out.
class StandingNotice extends StatefulWidget {
  const StandingNotice({super.key, required this.load});
  final Future<AccountStanding> Function() load;
  @override
  State<StandingNotice> createState() => _StandingNoticeState();
}

class _StandingNoticeState extends State<StandingNotice>
    with WidgetsBindingObserver {
  Timer? _timer;
  AccountStanding? _standing;
  bool _failed = false;
  bool _loading = false;
  bool _foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_foreground && (ModalRoute.of(context)?.isCurrent ?? true)) {
        _refresh();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) _refresh();
  }

  Future<void> _refresh() async {
    if (_loading) return;
    _loading = true;
    try {
      final value = await widget.load();
      if (mounted) {
        setState(() {
          _standing = value;
          _failed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _standing = null;
          _failed = true;
        });
      }
    } finally {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_failed && !(_standing?.hasRestrictions ?? false)) {
      return const SizedBox.shrink();
    }
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final suspended = ['suspended', 'banned'].contains(_standing?.status);
    return Material(
      color: colors.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Semantics(
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, color: colors.onErrorContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _failed
                            ? t.standingLoadFailed
                            : suspended
                            ? t.standingSuspended
                            : t.standingRestricted,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.onErrorContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _failed
                            ? t.standingUnavailableHelp
                            : t.standingRestrictedHelp,
                        style: TextStyle(color: colors.onErrorContainer),
                      ),
                      if (_failed)
                        TextButton(
                          onPressed: _refresh,
                          child: Text(t.standingRetry),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
