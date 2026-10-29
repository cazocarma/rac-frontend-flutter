import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../shared/services/theme.dart';
import '../../../shared/widgets/design.dart';
import '../../../shared/widgets/brand.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
    body: SingleChildScrollView(
      child: PageContent(
        width: 720,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageIntro(
              eyebrow: AppLocalizations.of(context)!.settingsPreferences,
              title: AppLocalizations.of(context)!.settingsHeading,
              description: AppLocalizations.of(context)!.settingsDescription,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.palette_outlined),
                      title: Text(
                        AppLocalizations.of(context)!.settingsAppearance,
                      ),
                    ),
                    for (final mode in ThemeMode.values)
                      ListTile(
                        leading: Icon(
                          appTheme.mode == mode
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                        ),
                        title: Text(switch (mode) {
                          ThemeMode.system => AppLocalizations.of(
                            context,
                          )!.settingsSystem,
                          ThemeMode.light => AppLocalizations.of(
                            context,
                          )!.settingsLight,
                          ThemeMode.dark => AppLocalizations.of(
                            context,
                          )!.settingsDark,
                        }),
                        onTap: () => appTheme.setMode(mode),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: const Icon(Icons.description_outlined),
                title: Text(AppLocalizations.of(context)!.settingsDocuments),
                subtitle: Text(
                  AppLocalizations.of(context)!.settingsDocumentsHelp,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed('/documents'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: const Icon(Icons.handyman_outlined),
                title: Text(AppLocalizations.of(context)!.commonConstruction),
                subtitle: Text(AppLocalizations.of(context)!.settingsPending),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
