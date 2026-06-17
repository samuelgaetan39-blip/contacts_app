import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:contacts_app/models/contact.dart';
import 'package:contacts_app/providers/contacts_provider.dart';
import 'package:contacts_app/screens/add_edit_contact_screen.dart';
import 'package:contacts_app/utils/permission_helper.dart';
import 'package:contacts_app/widgets/contact_avatar.dart';

class ContactDetailScreen extends StatelessWidget {
  final String contactId;
  const ContactDetailScreen({super.key, required this.contactId});

  Contact? _findContact(ContactsProvider cp) {
    try {
      return cp.activeContacts.firstWhere((c) => c.id == contactId);
    } catch (_) {
      return null;
    }
  }

  // ── Point 1 : partage réel (point 10 : pas de permission spéciale requise)
  void _shareContact(Contact contact) {
    final buffer = StringBuffer('=== ${contact.fullName} ===\n');
    for (final p in contact.phoneNumbers) {
      buffer.writeln('${p.displayLabel}: ${p.value}');
    }
    for (final e in contact.emails) {
      buffer.writeln('${e.displayLabel}: ${e.value}');
    }
    if (contact.addresses.isNotEmpty) {
      for (final a in contact.addresses.where((a) => !a.isEmpty)) {
        buffer.writeln('${a.displayLabel}: ${a.fullAddress}');
      }
    }
    Share.share(buffer.toString().trim(), subject: contact.fullName);
  }

  // ── Point 6 : appel téléphonique réel ─────────────────────────────────────
  Future<void> _makeCall(BuildContext context, String phone) async {
    final granted = await PermissionHelper.requestPhone(context);
    if (!granted) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de lancer l\'appel')),
      );
    }
  }

  // ── Point 6 : envoi de SMS réel ───────────────────────────────────────────
  Future<void> _sendSms(BuildContext context, String phone) async {
    final granted = await PermissionHelper.requestSms(context);
    if (!granted) return;
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir l\'application SMS')),
      );
    }
  }

  // ── Point 6 : envoi d'e-mail réel ─────────────────────────────────────────
  Future<void> _sendEmail(BuildContext context, String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Aucune application de messagerie configurée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cp      = context.watch<ContactsProvider>();
    final contact = _findContact(cp);

    // ── Point 12 : contact introuvable ────────────────────────────────────
    if (contact == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_outlined,
                  size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Contact introuvable',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 230,
            backgroundColor:
                Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Tooltip(
                message: 'Partager ce contact',
                child: IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _shareContact(contact),
                ),
              ),
              Tooltip(
                message: 'Modifier',
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditContactScreen(existingContact: contact),
                    ),
                  ),
                ),
              ),
              // ── Point 12 : menu Supprimer toujours visible en premier plan
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (v) async {
                  if (v == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Supprimer ce contact ?'),
                        // ── Point 9 : "placé·e" ────────────────────────
                        content: Text(
                            '${contact.fullName} sera placé·e dans la corbeille.'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Annuler')),
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text('Supprimer',
                                  style:
                                      TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await cp.moveToTrash(contact.id);
                      if (context.mounted) Navigator.pop(context);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Contact déplacé·e vers la corbeille')),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Supprimer',
                          style: TextStyle(color: Colors.red)),
                    ]),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ContactAvatar(contact: contact, radius: 52),
                    const SizedBox(height: 10),
                    Text(
                      contact.fullName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // ── Emplacement de stockage discret ────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        contact.storageLocation.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          // ── Boutons d'action rapide ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.phone_rounded,
                    label: 'Appeler',
                    onTap: contact.primaryPhone.isNotEmpty
                        ? () => _makeCall(context, contact.primaryPhone)
                        : null,
                  ),
                  _ActionButton(
                    icon: Icons.message_rounded,
                    label: 'Message',
                    onTap: contact.primaryPhone.isNotEmpty
                        ? () => _sendSms(context, contact.primaryPhone)
                        : null,
                  ),
                  _ActionButton(
                    icon: Icons.email_rounded,
                    label: 'E-mail',
                    onTap: contact.primaryEmail.isNotEmpty
                        ? () => _sendEmail(context, contact.primaryEmail)
                        : null,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: Divider()),

          // ── Informations du contact ──────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (contact.phoneNumbers.isNotEmpty)
                  _InfoSection(
                    icon: Icons.phone_outlined,
                    items: contact.phoneNumbers
                        .map((p) => _InfoItem(p.displayLabel, p.value))
                        .toList(),
                  ),
                if (contact.emails.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoSection(
                    icon: Icons.email_outlined,
                    items: contact.emails
                        .map((e) => _InfoItem(e.displayLabel, e.value))
                        .toList(),
                  ),
                ],
                if (contact.addresses.any((a) => !a.isEmpty)) ...[
                  const SizedBox(height: 12),
                  _InfoSection(
                    icon: Icons.location_on_outlined,
                    items: contact.addresses
                        .where((a) => !a.isEmpty)
                        .map((a) => _InfoItem(a.displayLabel, a.fullAddress))
                        .toList(),
                  ),
                ],
                if (contact.importantDates.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoSection(
                    icon: Icons.cake_outlined,
                    items: contact.importantDates
                        .map((d) => _InfoItem(
                              d.displayLabel,
                              '${d.date.day.toString().padLeft(2, '0')}/'
                              '${d.date.month.toString().padLeft(2, '0')}/'
                              '${d.date.year}',
                            ))
                        .toList(),
                  ),
                ],
                if (contact.websites.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoSection(
                    icon: Icons.language_outlined,
                    items: contact.websites
                        .map((w) => _InfoItem(w.displayLabel, w.url))
                        .toList(),
                  ),
                ],
                if (contact.relations.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoSection(
                    icon: Icons.people_outline_rounded,
                    items: contact.relations
                        .map((r) => _InfoItem(r.displayLabel, r.name))
                        .toList(),
                  ),
                ],
                if (contact.messagingAccounts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoSection(
                    icon: Icons.chat_outlined,
                    items: contact.messagingAccounts
                        .map((m) => _InfoItem(m.displayLabel, m.handle))
                        .toList(),
                  ),
                ],
                if (contact.groups.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoSection(
                    icon: Icons.group_outlined,
                    items: contact.groups
                        .map((g) => _InfoItem('Groupe', g))
                        .toList(),
                  ),
                ],
                if (contact.ringtone?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  _InfoSection(
                    icon: Icons.music_note_outlined,
                    items: [_InfoItem('Sonnerie', contact.ringtone!)],
                  ),
                ],
                if (contact.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  _InfoSection(
                    icon: Icons.notes_outlined,
                    items: [_InfoItem('Notes', contact.notes!)],
                  ),
                ],
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bouton d'action rapide ───────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final disabled = onTap == null;
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: disabled
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: disabled ? Colors.grey : primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: disabled ? Colors.grey : primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section d'information ────────────────────────────────────────────────────
class _InfoItem {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);
}

class _InfoSection extends StatelessWidget {
  final IconData    icon;
  final List<_InfoItem> items;

  const _InfoSection({required this.icon, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ListTile(
              leading: i == 0 ? Icon(icon) : const SizedBox(width: 24),
              title: Text(items[i].value),
              subtitle: Text(
                items[i].label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: const Tooltip(
                message: 'Copier',
                child: Icon(Icons.copy_outlined, size: 18),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: items[i].value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copié dans le presse-papiers')),
                );
              },
            ),
            if (i < items.length - 1) const Divider(indent: 56, height: 1),
          ],
        ],
      ),
    );
  }
}