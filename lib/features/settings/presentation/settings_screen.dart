import 'package:epic_blocks/app/application/app_update_controller.dart';
import 'package:epic_blocks/app/application/settings_controller.dart';
import 'package:epic_blocks/core/constants/app_metadata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// App settings screen.
class SettingsScreen extends StatelessWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            SwitchListTile(
              title: const Text('Dark mode'),
              secondary: const Icon(Icons.dark_mode),
              value: settings.darkMode,
              onChanged: settings.setDarkMode,
            ),
            SwitchListTile(
              title: const Text('Vibration'),
              secondary: const Icon(Icons.vibration),
              value: settings.vibrationEnabled,
              onChanged: settings.setVibrationEnabled,
            ),
            SwitchListTile(
              title: const Text('Sound'),
              secondary: const Icon(Icons.volume_up),
              value: settings.soundEnabled,
              onChanged: settings.setSoundEnabled,
            ),
            const Divider(height: 32),
            const _UpdateSection(),
            const SizedBox(height: 16),
            const _PatchNotesSection(),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'EpicBlocks ${AppMetadata.versionLabel} - ${AppMetadata.signature}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateSection extends StatelessWidget {
  const _UpdateSection();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppUpdateController>();
    final state = controller.state;
    final isBusy =
        state == AppUpdateButtonState.checking ||
        state == AppUpdateButtonState.gettingUpdate;
    final canGetUpdate = state == AppUpdateButtonState.updateAvailable;
    final isUpToDate = state == AppUpdateButtonState.upToDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: const ValueKey('update-button'),
          onPressed: isBusy || isUpToDate
              ? null
              : canGetUpdate
              ? controller.getUpdate
              : controller.checkForUpdates,
          icon: Icon(_iconForState(state)),
          label: Text(_labelForState(state)),
        ),
        if (controller.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            controller.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  IconData _iconForState(AppUpdateButtonState state) {
    return switch (state) {
      AppUpdateButtonState.upToDate => Icons.check,
      AppUpdateButtonState.updateAvailable => Icons.system_update_alt,
      AppUpdateButtonState.checking ||
      AppUpdateButtonState.gettingUpdate => Icons.hourglass_empty,
      AppUpdateButtonState.failed => Icons.error_outline,
      AppUpdateButtonState.idle => Icons.system_update,
    };
  }

  String _labelForState(AppUpdateButtonState state) {
    return switch (state) {
      AppUpdateButtonState.upToDate => 'up to date',
      AppUpdateButtonState.updateAvailable => 'get update',
      AppUpdateButtonState.checking => 'Checking...',
      AppUpdateButtonState.gettingUpdate => 'Getting update...',
      AppUpdateButtonState.failed ||
      AppUpdateButtonState.idle => 'Check for updates',
    };
  }
}

class _PatchNotesSection extends StatelessWidget {
  const _PatchNotesSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252A32) : const Color(0xFFFFF3B0),
        border: Border.all(
          color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE2C766),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 180),
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isDark ? Colors.white : const Color(0xFF3D3420),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final note in AppMetadata.patchNotes) ...[
                    Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark ? Colors.white : const Color(0xFF3D3420),
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final change in note.changes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('- $change'),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
