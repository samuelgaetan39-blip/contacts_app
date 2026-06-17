import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:contacts_app/models/contact.dart';
import 'package:contacts_app/providers/contacts_provider.dart';
import 'package:contacts_app/providers/settings_provider.dart';
import 'package:contacts_app/screens/add_edit_contact_screen.dart';
import 'package:contacts_app/screens/contact_detail_screen.dart';
import 'package:contacts_app/screens/trash_screen.dart';
import 'package:contacts_app/widgets/contact_avatar.dart';
import 'package:contacts_app/widgets/contact_list_item.dart';
import 'package:contacts_app/widgets/empty_state_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
        () => setState(() => _query = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Point 1 : partage de contacts ─────────────────────────────────────────
  void _shareContacts(List<Contact> contacts) {
    if (contacts.isEmpty) return;
    final buffer = StringBuffer();
    for (final c in contacts) {
      buffer.writeln('=== ${c.fullName} ===');
      for (final p in c.phoneNumbers) {
        buffer.writeln('${p.displayLabel}: ${p.value}');
      }
      for (final e in c.emails) {
        buffer.writeln('${e.displayLabel}: ${e.value}');
      }
      buffer.writeln();
    }
    Share.share(buffer.toString().trim(),
        subject: contacts.length == 1 ? contacts.first.fullName : 'Contacts');
  }

  Future<void> _deleteSelected(
      ContactsProvider cp, List<Contact> selected) async {
    for (final c in selected) {
      await cp.moveToTrash(c.id);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${selected.length} contact(s) déplacé(s) vers la corbeille'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () async {
            for (final c in selected) {
              await cp.restoreContact(c.id);
            }
          },
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext ctx, ContactsProvider cp) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Partager des contacts'),
              onTap: () {
                Navigator.pop(ctx);
                _showShareSelectionSheet(cp);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Supprimer des contacts',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteSelectionMode(cp);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined),
              title: const Text('Corbeille'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TrashScreen()));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showShareSelectionSheet(ContactsProvider cp) async {
    final selected = await showModalBottomSheet<List<Contact>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) =>
          _ContactSelectionSheet(contacts: cp.activeContacts, actionLabel: 'Partager'),
    );
    if (selected != null && selected.isNotEmpty) {
      _shareContacts(selected);
    }
  }

  void _showDeleteSelectionMode(ContactsProvider cp) async {
    final selected = await showModalBottomSheet<List<Contact>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) =>
          _ContactSelectionSheet(contacts: cp.activeContacts, actionLabel: 'Supprimer'),
    );
    if (selected != null && selected.isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Supprimer les contacts'),
          content: Text(
              'Supprimer ${selected.length} contact(s) ? '
              'Ils seront placé·e·s dans la corbeille.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer',
                    style: TextStyle(color: Colors.red))),
          ],
        ),
      );
      if (confirm == true) await _deleteSelected(cp, selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cp       = context.watch<ContactsProvider>();
    final settings = context.watch<SettingsProvider>();
    final scheme   = Theme.of(context).colorScheme;
    final bgColor  = Theme.of(context).scaffoldBackgroundColor;

    final isSearching = _query.isNotEmpty;
    final displayed   = isSearching
        ? cp.search(_query)
        : cp.sortedContacts(settings);
    final total = cp.activeContacts.length;

    return Scaffold(
      backgroundColor: bgColor,
      // ── Point 4 : AppBar fixe, arrière-plan opaque, bouton à 3 points
      //             au même niveau que le titre ─────────────────────────────
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Contacts',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              '$total ${total > 1 ? 'contacts' : 'contact'}',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Plus d\'options',
            child: IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () => _showMoreMenu(context, cp),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Barre de recherche fixe ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un contact…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: _searchController.clear,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // ── Liste défilable ──────────────────────────────────────────────
          Expanded(
            child: displayed.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.person_off_outlined,
                    label: isSearching ? 'Aucun résultat' : 'Aucun contact',
                    subtitle: isSearching
                        ? 'Essayez un autre terme de recherche.'
                        : 'Appuyez sur + pour ajouter votre premier contact.',
                  )
                : isSearching
                    ? ListView.builder(
                        itemCount: displayed.length,
                        itemBuilder: (ctx, i) {
                          final c = displayed[i];
                          return ContactListItem(
                            contact: c,
                            onTap: () => _openDetail(c),
                          );
                        },
                      )
                    : _AlphaGroupedList(
                        grouped: cp.groupedContacts(settings),
                        onTap: _openDetail,
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Ajouter un contact',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditContactScreen()),
        ),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _openDetail(Contact c) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContactDetailScreen(contactId: c.id)),
    );
  }
}

// ─── Liste groupée alphabétiquement ──────────────────────────────────────────
class _AlphaGroupedList extends StatelessWidget {
  final Map<String, List<Contact>> grouped;
  final ValueChanged<Contact> onTap;

  const _AlphaGroupedList({required this.grouped, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final keys = grouped.keys.toList()..sort();
    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (ctx, idx) {
        final key      = keys[idx];
        final contacts = grouped[key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                key,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const Divider(height: 1),
            ...contacts.map(
              (c) => ContactListItem(contact: c, onTap: () => onTap(c)),
            ),
          ],
        );
      },
    );
  }
}

// ─── Feuille de sélection générique ──────────────────────────────────────────
class _ContactSelectionSheet extends StatefulWidget {
  final List<Contact> contacts;
  final String        actionLabel;

  const _ContactSelectionSheet({
    required this.contacts,
    required this.actionLabel,
  });

  @override
  State<_ContactSelectionSheet> createState() =>
      _ContactSelectionSheetState();
}

class _ContactSelectionSheetState extends State<_ContactSelectionSheet> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final isDelete = widget.actionLabel == 'Supprimer';
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Sélectionner des contacts',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    if (_selected.length == widget.contacts.length) {
                      _selected.clear();
                    } else {
                      _selected.addAll(widget.contacts.map((c) => c.id));
                    }
                  }),
                  child: Text(
                    _selected.length == widget.contacts.length
                        ? 'Tout désélectionner'
                        : 'Tout sélectionner',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: widget.contacts.length,
              itemBuilder: (ctx, i) {
                final c = widget.contacts[i];
                return CheckboxListTile(
                  value: _selected.contains(c.id),
                  onChanged: (v) => setState(() {
                    v == true ? _selected.add(c.id) : _selected.remove(c.id);
                  }),
                  secondary: ContactAvatar(contact: c, radius: 20),
                  title: Text(c.fullName),
                  subtitle: Text(c.primaryPhone),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDelete ? Colors.red : null,
                        foregroundColor:
                            isDelete ? Colors.white : null,
                      ),
                      onPressed: _selected.isEmpty
                          ? null
                          : () => Navigator.pop(
                                context,
                                widget.contacts
                                    .where((c) => _selected.contains(c.id))
                                    .toList(),
                              ),
                      child: Text(
                          '${widget.actionLabel} (${_selected.length})'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}