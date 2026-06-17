import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:contacts_app/providers/contacts_provider.dart';
import 'package:contacts_app/providers/settings_provider.dart';
import 'package:contacts_app/screens/home_screen.dart';
import 'package:contacts_app/screens/settings_screen.dart';
import 'package:contacts_app/utils/app_theme.dart';
import 'package:contacts_app/widgets/bottom_nav_bar.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => ContactsProvider()..loadContacts()),
      ],
      child: const ContactsApp(),
    ),
  );
}

class ContactsApp extends StatelessWidget {
  const ContactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      title: 'Contacts',
      debugShowCheckedModeBanner: false,
      theme:     AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<ContactsProvider>();

    // ── Point 12 : écran de chargement initial ────────────────────────────
    // Affiché le temps que SharedPreferences charge les contacts au démarrage.
    if (cp.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.contacts_rounded,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Chargement des contacts…',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    // ── Point 12 : erreur de chargement ───────────────────────────────────
    // Affiché si SharedPreferences retourne une erreur critique.
    if (cp.error != null && cp.activeContacts.isEmpty && !cp.isImporting) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Erreur de chargement',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  cp.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.read<ContactsProvider>().loadContacts(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}