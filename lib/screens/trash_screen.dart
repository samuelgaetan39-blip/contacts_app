import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:contacts_app/models/contact.dart';
import 'package:contacts_app/providers/contacts_provider.dart';
import 'package:contacts_app/widgets/contact_avatar.dart';
import 'package:contacts_app/widgets/empty_state_widget.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final Set<String> _selected = {};
  bool _selectionMode = false;

  void _toggleSelection(String id) {
    setState(() {
      _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
      _selectionMode = _selected.isNotEmpty;
    });
  }

  void _selectAll(List<Contact> contacts) {
    setState(() {
      _selected.addAll(contacts.map((c) => c.id));
      _selectionMode = true;
    });
  }

  void _clearSelection() {
    setState(() {
      _selected.clear();
      _selectionMode = false;
    });
  }

  Future<void> _deleteSelected(ContactsProvider cp) async {
    final ids = List<String>.from(_selected);
    // ── Point 9 : "placé·e" ───────────────────────────────────────────────
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer définitivement ?'),
        content: Text(
            '${ids.length} contact(s) sera/seront supprimé·e·s définitivement. '
            'Cette action est irréversible.'),
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
    if (confirm == true) {
      for (final id in ids) { await cp.deletePermanently(id); }
      _clearSelection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Contacts supprimé·e·s définitivement')),
        );
      }
    }
  }

  Future<void> _restoreSelected(ContactsProvider cp) async {
    final ids = List<String>.from(_selected);
    for (final id in ids) { await cp.restoreContact(id); }
    _clearSelection();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${ids.length} contact(s) restauré·e·s')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cp      = context.watch<ContactsProvider>();
    final trashed = cp.trashedContacts;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Corbeille'),
        titleTextStyle: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w600, fontSize: 20),
        actions: [
          if (trashed.isNotEmpty && !_selectionMode) ...[
            TextButton(
              onPressed: () => _selectAll(trashed),
              child: const Text('Sélectionner'),
            ),
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Vider la corbeille ?'),
                    content: const Text(
                        'Tous les contacts seront supprimé·e·s définitivement.'),
                    actions: [
                      TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text('Annuler')),
                      TextButton(
                          onPressed: () =>
                              Navigator.pop(context, true),
                          child: const Text('Vider',
                              style:
                                  TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await cp.emptyTrash();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Corbeille vidée')),
                    );
                  }
                }
              },
              child: const Text('Vider',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
          if (_selectionMode)
            TextButton(
                onPressed: _clearSelection,
                child: const Text('Annuler')),
        ],
      ),
      body: trashed.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.delete_outline,
              label: 'Corbeille vide',
              subtitle:
                  'Les contacts supprimé·e·s apparaîtront ici.',
            )
          : Column(
              children: [
                if (_selectionMode)
                  Container(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          '${_selected.length} sélectionné(s)',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.restore_rounded),
                          label: const Text('Restaurer'),
                          onPressed: () => _restoreSelected(cp),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: const Icon(
                              Icons.delete_forever_outlined,
                              color: Colors.red),
                          label: const Text('Supprimer',
                              style: TextStyle(color: Colors.red)),
                          onPressed: () => _deleteSelected(cp),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: trashed.length,
                    itemBuilder: (ctx, i) {
                      final c = trashed[i];
                      return ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_selectionMode)
                              Checkbox(
                                value: _selected.contains(c.id),
                                onChanged: (_) =>
                                    _toggleSelection(c.id),
                              ),
                            ContactAvatar(contact: c, radius: 22),
                          ],
                        ),
                        title: Text(c.fullName),
                        subtitle: c.deletedAt != null
                            ? Text(
                                'Supprimé·e le '
                                '${c.deletedAt!.day.toString().padLeft(2, '0')}/'
                                '${c.deletedAt!.month.toString().padLeft(2, '0')}/'
                                '${c.deletedAt!.year}',
                                style: const TextStyle(fontSize: 12),
                              )
                            : null,
                        onTap: _selectionMode
                            ? () => _toggleSelection(c.id)
                            : null,
                        onLongPress: () => setState(() {
                          _selectionMode = true;
                          _selected.add(c.id);
                        }),
                        trailing: _selectionMode
                            ? null
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Tooltip(
                                    message: 'Restaurer',
                                    child: IconButton(
                                      icon: const Icon(
                                          Icons.restore_rounded),
                                      onPressed: () async {
                                        await cp.restoreContact(c.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Contact restauré·e')),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  Tooltip(
                                    message: 'Supprimer définitivement',
                                    child: IconButton(
                                      icon: const Icon(
                                          Icons.delete_forever_outlined,
                                          color: Colors.red),
                                      onPressed: () async {
                                        final confirm =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text(
                                                'Supprimer définitivement ?'),
                                            content: const Text(
                                                'Cette action est irréversible.'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context,
                                                          false),
                                                  child: const Text(
                                                      'Annuler')),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context,
                                                          true),
                                                  child: const Text(
                                                      'Supprimer',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .red))),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await cp.deletePermanently(
                                              c.id);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}