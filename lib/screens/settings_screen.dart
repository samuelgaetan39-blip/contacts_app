import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:contacts_app/models/contact.dart';
import 'package:contacts_app/providers/contacts_provider.dart';
import 'package:contacts_app/providers/settings_provider.dart';
import 'package:contacts_app/screens/add_edit_contact_screen.dart';
import 'package:contacts_app/utils/constants.dart';
import 'package:contacts_app/widgets/section_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final cp       = context.watch<ContactsProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Paramètres',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Apparence et affichage ────────────────────────────────────
          SectionCard(
            title: 'Apparence et affichage',
            children: [
              SwitchListTile(
                title: const Text('Mode sombre'),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: settings.darkMode,
                onChanged: settings.setDarkMode,
              ),
              ListTile(
                leading: const Icon(Icons.sort_rounded),
                title: const Text('Tri des contacts'),
                subtitle: Text(
                  '${settings.sortCriteria.label} · '
                  '${settings.sortOrder == SortOrder.ascending ? 'Croissant' : 'Décroissant'}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showSortDialog(context, settings),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Données ───────────────────────────────────────────────────
          SectionCard(
            title: 'Données',
            children: [
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('Mon profil'),
                subtitle: const Text('Vos informations personnelles'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddEditContactScreen()),
                ),
              ),
              ListTile(
                leading: cp.isImporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_download_outlined),
                title: const Text('Importer des contacts'),
                subtitle: const Text('Synchroniser depuis randomuser.me'),
                onTap: cp.isImporting
                    ? null
                    : () async {
                        final count =
                            await cp.importFromRandomUser(count: 10);
                        if (!context.mounted) return;
                        if (count > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '$count contact(s) importé·e·s avec succès')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  cp.error ??
                                      'Erreur lors de l\'importation. '
                                      'Vérifiez votre connexion Internet.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
              ),
              ListTile(
                leading: const Icon(Icons.storage_outlined),
                title: const Text('Stockage par défaut'),
                subtitle:
                    const Text('Emplacement des nouveaux contacts'),
                trailing: DropdownButton<StorageLocation>(
                  value: settings.defaultStorage,
                  underline: const SizedBox(),
                  onChanged: (v) {
                    if (v != null) settings.setDefaultStorage(v);
                  },
                  items: StorageLocation.values
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.label),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── À propos ──────────────────────────────────────────────────
          SectionCard(
            title: 'À propos',
            children: [
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // ── Point 7 : même logo que l'icône de lancement ────
                  child: const Icon(Icons.contacts_rounded,
                      color: Colors.white, size: 26),
                ),
                title: Text(AppConstants.appName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Version ${AppConstants.appVersion}'),
              ),
              ListTile(
                leading: const Icon(Icons.code_rounded),
                title: const Text('Développeur'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppConstants.developer),
                    Text(
                      'Code : ${AppConstants.devCode}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('Institution'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppConstants.institution,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    Text(
                      AppConstants.university,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showSortDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tri des contacts'),
        content: StatefulBuilder(
          builder: (ctx, setS) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Critère de tri',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              ...SortCriteria.values.map((c) =>
                  RadioListTile<SortCriteria>(
                    title: Text(c.label),
                    value: c,
                    groupValue: settings.sortCriteria,
                    onChanged: (v) {
                      settings.setSortCriteria(v!);
                      setS(() {});
                    },
                    dense: true,
                  )),
              const Divider(),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Ordre',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              RadioListTile<SortOrder>(
                title: const Text('Croissant (A → Z)'),
                value: SortOrder.ascending,
                groupValue: settings.sortOrder,
                onChanged: (v) {
                  settings.setSortOrder(v!);
                  setS(() {});
                },
                dense: true,
              ),
              RadioListTile<SortOrder>(
                title: const Text('Décroissant (Z → A)'),
                value: SortOrder.descending,
                groupValue: settings.sortOrder,
                onChanged: (v) {
                  settings.setSortOrder(v!);
                  setS(() {});
                },
                dense: true,
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }
}