import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landmark_navigation_app/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _navModes = <String, String>{
    'hybrid': 'Hibridni (orijentiri + udaljenost)',
    'landmark': 'Samo orijentiri',
    'classic': 'Klasične upute',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Postavke'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body:
          settings.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Način navigacije',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  for (final entry in _navModes.entries)
                    RadioListTile<String>(
                      title: Text(entry.value),
                      value: entry.key,
                      groupValue: settings.mode,
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(settingsProvider.notifier).setMode(value);
                        }
                      },
                    ),
                ],
              ),
    );
  }
}
