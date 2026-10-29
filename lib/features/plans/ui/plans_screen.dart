import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/design.dart';
import '../../../shared/widgets/brand.dart';
import '../../../shared/widgets/weekly_allowance.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.plansTitle)),
      body: SingleChildScrollView(
        child: PageContent(
          width: 960,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageIntro(
                eyebrow: t.plansEyebrow,
                title: t.plansHeading,
                description: t.plansDescription,
              ),
              const WeeklyAllowance(),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final free = _plan(context, false);
                  final paid = _plan(context, true);
                  return constraints.maxWidth >= 700
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: free),
                            const SizedBox(width: 20),
                            Expanded(child: paid),
                          ],
                        )
                      : Column(
                          children: [free, const SizedBox(height: 20), paid],
                        );
                },
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.plansPending,
                      style: const TextStyle(height: 1.6, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _plan(BuildContext context, bool paid) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                paid ? Icons.auto_awesome_outlined : Icons.wb_sunny_outlined,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              paid ? t.plansPaidTitle : t.plansFreeTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              paid ? t.commonConstruction : '\$0',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              paid ? t.plansPreparing : t.plansWeekly,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Divider(height: 36),
            if (!paid) ...[
              _feature(context, t.plansRequests),
              _feature(context, t.plansConfirm),
              _feature(context, t.plansProfile),
              const SizedBox(height: 12),
              Text(
                t.plansWeekRules,
                style: const TextStyle(fontSize: 12, height: 1.6),
              ),
            ] else ...[
              _feature(context, t.plansAcceptMore),
              _feature(context, t.plansControl),
              const SizedBox(height: 12),
              Text(
                t.plansPaymentDetails,
                style: const TextStyle(fontSize: 12, height: 1.6),
              ),
              const SizedBox(height: 20),
              Chip(
                avatar: const Icon(Icons.handyman_outlined, size: 16),
                label: Text(t.plansPaymentsConstruction),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _feature(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 19,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5)),
        ),
      ],
    ),
  );
}
