import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:contacts_app/models/address.dart';
import 'package:contacts_app/models/contact.dart';
import 'package:contacts_app/models/email_address.dart';
import 'package:contacts_app/models/important_date.dart';
import 'package:contacts_app/models/messaging_account.dart';
import 'package:contacts_app/models/phone_number.dart';
import 'package:contacts_app/models/relation.dart';
import 'package:contacts_app/models/website.dart';
import 'package:contacts_app/providers/contacts_provider.dart';
import 'package:contacts_app/providers/settings_provider.dart';
import 'package:contacts_app/utils/constants.dart';
import 'package:contacts_app/utils/permission_helper.dart';
import 'package:contacts_app/utils/phone_formatter.dart';

class AddEditContactScreen extends StatefulWidget {
  final Contact? existingContact;
  const AddEditContactScreen({super.key, this.existingContact});

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker  = ImagePicker();

  // Contrôleurs
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _prefixCtrl;
  late TextEditingController _suffixCtrl;
  late TextEditingController _notesCtrl;

  // Contrôleurs dynamiques pour les listes
  final List<TextEditingController> _phoneCtrl    = [];
  final List<TextEditingController> _emailCtrl    = [];
  final List<TextEditingController> _websiteCtrl  = [];
  final List<TextEditingController> _relationCtrl = [];
  final List<TextEditingController> _msgCtrl      = [];
  final List<List<TextEditingController>> _addrCtrl = [];

  // Modèles
  final List<PhoneNumber>      _phones    = [];
  final List<EmailAddress>     _emails    = [];
  final List<String>           _groups    = [];
  final List<Address>          _addresses = [];
  final List<ImportantDate>    _dates     = [];
  final List<Website>          _websites  = [];
  final List<Relation>         _relations = [];
  final List<MessagingAccount> _messaging = [];

  String?         _imagePath;
  StorageLocation _storage  = StorageLocation.phone;
  String?         _ringtone;
  bool            _showMore = false;

  bool get _isEditing => widget.existingContact != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existingContact;
    _firstNameCtrl = TextEditingController(text: c?.firstName ?? '');
    _lastNameCtrl  = TextEditingController(text: c?.lastName  ?? '');
    _prefixCtrl    = TextEditingController(text: c?.honorificPrefix ?? '');
    _suffixCtrl    = TextEditingController(text: c?.honorificSuffix ?? '');
    _notesCtrl     = TextEditingController(text: c?.notes ?? '');
    _imagePath     = c?.imagePath;
    _storage       = c?.storageLocation ??
        context.read<SettingsProvider>().defaultStorage;
    _ringtone      = c?.ringtone;

    if (c != null) {
      for (final p in c.phoneNumbers) {
        _phones.add(PhoneNumber(value: p.value, type: p.type, customLabel: p.customLabel));
        _phoneCtrl.add(TextEditingController(text: p.value));
      }
      for (final e in c.emails) {
        _emails.add(EmailAddress(value: e.value, type: e.type, customLabel: e.customLabel));
        _emailCtrl.add(TextEditingController(text: e.value));
      }
      _groups.addAll(c.groups);
      for (final a in c.addresses) {
        _addresses.add(Address(
            street: a.street, city: a.city, state: a.state,
            postalCode: a.postalCode, country: a.country, type: a.type));
        _addrCtrl.add(_makeAddrCtrl(a));
      }
      _dates.addAll(c.importantDates);
      for (final w in c.websites) {
        _websites.add(Website(url: w.url, type: w.type));
        _websiteCtrl.add(TextEditingController(text: w.url));
      }
      for (final r in c.relations) {
        _relations.add(Relation(name: r.name, type: r.type));
        _relationCtrl.add(TextEditingController(text: r.name));
      }
      for (final m in c.messagingAccounts) {
        _messaging.add(MessagingAccount(handle: m.handle, platform: m.platform));
        _msgCtrl.add(TextEditingController(text: m.handle));
      }
    } else {
      _phones.add(PhoneNumber(value: '', type: PhoneType.mobile));
      _phoneCtrl.add(TextEditingController());
    }
  }

  List<TextEditingController> _makeAddrCtrl(Address a) => [
        TextEditingController(text: a.street),
        TextEditingController(text: a.city),
        TextEditingController(text: a.state),
        TextEditingController(text: a.postalCode),
        TextEditingController(text: a.country),
      ];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _prefixCtrl.dispose();
    _suffixCtrl.dispose();
    _notesCtrl.dispose();
    for (final c in _phoneCtrl)    { c.dispose(); }
    for (final c in _emailCtrl)    { c.dispose(); }
    for (final c in _websiteCtrl)  { c.dispose(); }
    for (final c in _relationCtrl) { c.dispose(); }
    for (final c in _msgCtrl)      { c.dispose(); }
    for (final row in _addrCtrl)   { for (final c in row) { c.dispose(); } }
    super.dispose();
  }

  // ── Point 10 : permission galerie / caméra avant ouverture ────────────────
  void _pickImage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galerie'),
              onTap: () async {
                Navigator.pop(context);
                final granted =
                    await PermissionHelper.requestPhotos(context);
                if (!granted) return;
                final x = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 600,
                  maxHeight: 600,
                  imageQuality: 85,
                );
                if (x != null && mounted) {
                  setState(() => _imagePath = x.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Caméra'),
              onTap: () async {
                Navigator.pop(context);
                final granted =
                    await PermissionHelper.requestCamera(context);
                if (!granted) return;
                final x = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 600,
                  maxHeight: 600,
                  imageQuality: 85,
                );
                if (x != null && mounted) {
                  setState(() => _imagePath = x.path);
                }
              },
            ),
            if (_imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Supprimer la photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imagePath = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_firstNameCtrl.text.trim().isEmpty &&
        _lastNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Veuillez entrer au moins un prénom ou un nom de famille')),
      );
      return;
    }

    final cp = context.read<ContactsProvider>();
    final phones = _phones.where((p) => p.value.isNotEmpty).toList();
    final emails = _emails.where((e) => e.value.isNotEmpty).toList();

    if (_isEditing) {
      final existing = widget.existingContact!;
      if (_firstNameCtrl.text.trim().isNotEmpty) {
        existing.firstName = _firstNameCtrl.text.trim();
      }
      existing.lastName        = _lastNameCtrl.text.trim();
      existing.imagePath       = _imagePath;
      existing.storageLocation = _storage;
      existing.honorificPrefix = _prefixCtrl.text.trim().isNotEmpty
          ? _prefixCtrl.text.trim()
          : null;
      existing.honorificSuffix = _suffixCtrl.text.trim().isNotEmpty
          ? _suffixCtrl.text.trim()
          : null;
      existing.notes    = _notesCtrl.text.trim().isNotEmpty
          ? _notesCtrl.text.trim()
          : null;
      existing.ringtone = _ringtone;

      while (existing.phoneNumbers.isNotEmpty) existing.removePhoneNumber(0);
      for (final p in phones)    { existing.addPhoneNumber(p); }
      while (existing.emails.isNotEmpty) existing.removeEmail(0);
      for (final e in emails)    { existing.addEmail(e); }
      while (existing.groups.isNotEmpty) existing.removeGroup(existing.groups.first);
      for (final g in _groups)   { existing.addGroup(g); }
      while (existing.addresses.isNotEmpty) existing.removeAddress(0);
      for (final a in _addresses) { existing.addAddress(a); }
      while (existing.importantDates.isNotEmpty) existing.removeImportantDate(0);
      for (final d in _dates)    { existing.addImportantDate(d); }
      while (existing.websites.isNotEmpty) existing.removeWebsite(0);
      for (final w in _websites) { existing.addWebsite(w); }
      while (existing.relations.isNotEmpty) existing.removeRelation(0);
      for (final r in _relations) { existing.addRelation(r); }
      while (existing.messagingAccounts.isNotEmpty) existing.removeMessagingAccount(0);
      for (final m in _messaging) { existing.addMessagingAccount(m); }

      await cp.updateContact(existing);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact mis à jour')));
        Navigator.pop(context);
      }
    } else {
      final fn = _firstNameCtrl.text.trim().isNotEmpty
          ? _firstNameCtrl.text.trim()
          : _lastNameCtrl.text.trim();
      await cp.addContact(
        firstName:         fn,
        lastName:          _lastNameCtrl.text.trim(),
        imagePath:         _imagePath,
        storageLocation:   _storage,
        phoneNumbers:      phones,
        emails:            emails,
        groups:            _groups,
        addresses:         _addresses,
        importantDates:    _dates,
        websites:          _websites,
        relations:         _relations,
        messagingAccounts: _messaging,
        ringtone:          _ringtone,
        notes:             _notesCtrl.text.trim().isNotEmpty
            ? _notesCtrl.text.trim()
            : null,
        honorificPrefix:   _prefixCtrl.text.trim().isNotEmpty
            ? _prefixCtrl.text.trim()
            : null,
        honorificSuffix:   _suffixCtrl.text.trim().isNotEmpty
            ? _suffixCtrl.text.trim()
            : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact enregistré')));
        Navigator.pop(context);
      }
    }
  }

  void _confirmDiscard() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Annuler les modifications ?'),
        content: const Text(
            'Toutes les modifications non enregistrées seront perdues.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuer')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Annuler',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _confirmDiscard,
        ),
        title: Text(_isEditing ? 'Modification de contact' : 'Nouveau contact'),
        titleTextStyle: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w600),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      // ── Point 8 : boutons fixes en bas, formulaire défilable ──────────────
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Photo ──────────────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              backgroundImage: _imagePath != null
                                  ? (_imagePath!.startsWith('http')
                                      ? NetworkImage(_imagePath!)
                                          as ImageProvider
                                      : FileImage(File(_imagePath!)))
                                  : null,
                              child: _imagePath == null
                                  ? const Icon(Icons.person_add_outlined,
                                      size: 40)
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajouter une photo',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Emplacement de stockage ────────────────────────
                    _buildDropdownField<StorageLocation>(
                      label: 'Emplacement de stockage',
                      value: _storage,
                      items: StorageLocation.values,
                      labelOf: (v) => v.label,
                      onChanged: (v) =>
                          setState(() => _storage = v!),
                    ),

                    const SizedBox(height: 16),

                    // ── Noms ───────────────────────────────────────────
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(children: [
                          TextFormField(
                            controller: _firstNameCtrl,
                            decoration: const InputDecoration(
                                hintText: 'Prénom·s'),
                            textCapitalization:
                                TextCapitalization.words,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _lastNameCtrl,
                            decoration: const InputDecoration(
                                hintText: 'Nom de famille'),
                            textCapitalization:
                                TextCapitalization.words,
                          ),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildPhoneSection(),
                    const SizedBox(height: 16),
                    _buildEmailSection(),
                    const SizedBox(height: 16),
                    _buildGroupSection(),
                    const SizedBox(height: 16),

                    // ── Plus / Moins de champs ─────────────────────────
                    Center(
                      child: TextButton.icon(
                        icon: Icon(_showMore
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded),
                        label: Text(
                            _showMore ? 'Moins de champs' : 'Plus de champs'),
                        onPressed: () =>
                            setState(() => _showMore = !_showMore),
                      ),
                    ),

                    if (_showMore) ...[
                      const SizedBox(height: 8),
                      _buildAddressSection(),
                      const SizedBox(height: 16),
                      _buildDateSection(),
                      const SizedBox(height: 16),
                      _buildWebsiteSection(),
                      const SizedBox(height: 16),
                      _buildRelationSection(),
                      const SizedBox(height: 16),
                      _buildMessagingSection(),
                      const SizedBox(height: 16),
                      _buildDropdownField<String>(
                        label: 'Sonnerie',
                        value: _ringtone ??
                            AppConstants.ringtones.first,
                        items: AppConstants.ringtones,
                        labelOf: (v) => v,
                        onChanged: (v) =>
                            setState(() => _ringtone = v),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _notesCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Notes…',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(children: [
                            TextField(
                              controller: _prefixCtrl,
                              decoration: const InputDecoration(
                                  hintText:
                                      'Titre prénominal (ex. Dr.)'),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _suffixCtrl,
                              decoration: const InputDecoration(
                                  hintText:
                                      'Titre post-nominal (ex. PhD)'),
                            ),
                          ]),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // ── Point 8 : boutons toujours visibles en bas ────────────────
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _confirmDiscard,
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Enregistrer'),
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

  // ─── Sections dynamiques ──────────────────────────────────────────────────

  Widget _buildPhoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.phone_outlined, 'Numéros de téléphone'),
        const SizedBox(height: 8),
        ...List.generate(_phones.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Point 3 : hauteur réduite du type ─────────────────
                Row(children: [
                  _typeDropdown<PhoneType>(
                    value: _phones[i].type,
                    items: PhoneType.values,
                    labelOf: (v) => v.label,
                    onChanged: (v) =>
                        setState(() => _phones[i].type = v!),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 18),
                      onPressed: () => setState(() {
                        _phoneCtrl[i].dispose();
                        _phoneCtrl.removeAt(i);
                        _phones.removeAt(i);
                      }),
                    ),
                  ),
                ]),
                const SizedBox(height: 2),
                // ── Point 2 : formatage automatique des numéros ────────
                TextField(
                  controller: _phoneCtrl[i],
                  keyboardType: TextInputType.phone,
                  inputFormatters: [PhoneInputFormatter()],
                  decoration: const InputDecoration(hintText: 'Numéro'),
                  onChanged: (v) => _phones[i].value = v,
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Ajouter un numéro'),
          onPressed: () => setState(() {
            _phones.add(PhoneNumber(value: '', type: PhoneType.mobile));
            _phoneCtrl.add(TextEditingController());
          }),
        ),
      ],
    );
  }

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.email_outlined, 'E-mails'),
        const SizedBox(height: 8),
        ...List.generate(_emails.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _typeDropdown<EmailType>(
                    value: _emails[i].type,
                    items: EmailType.values,
                    labelOf: (v) => v.label,
                    onChanged: (v) =>
                        setState(() => _emails[i].type = v!),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 18),
                      onPressed: () => setState(() {
                        _emailCtrl[i].dispose();
                        _emailCtrl.removeAt(i);
                        _emails.removeAt(i);
                      }),
                    ),
                  ),
                ]),
                const SizedBox(height: 2),
                TextField(
                  controller: _emailCtrl[i],
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(hintText: 'Adresse e-mail'),
                  onChanged: (v) {
                    try { _emails[i].value = v; } catch (_) {}
                  },
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Ajouter un e-mail'),
          onPressed: () => setState(() {
            _emails.add(EmailAddress(
                value: '', type: EmailType.personal));
            _emailCtrl.add(TextEditingController());
          }),
        ),
      ],
    );
  }

  Widget _buildGroupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.group_outlined, 'Groupes'),
        const SizedBox(height: 8),
        ..._groups.asMap().entries.map((entry) {
          final i = entry.key;
          final g = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Expanded(
                child: _typeDropdown<String>(
                  value: AppConstants.defaultGroups.contains(g)
                      ? g
                      : AppConstants.defaultGroups.first,
                  items: AppConstants.defaultGroups,
                  labelOf: (v) => v,
                  onChanged: (v) =>
                      setState(() => _groups[i] = v!),
                ),
              ),
              SizedBox(
                height: 32,
                width: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 18),
                  onPressed: () => setState(() => _groups.removeAt(i)),
                ),
              ),
            ]),
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Ajouter à un groupe'),
          onPressed: () =>
              setState(() => _groups.add(AppConstants.defaultGroups.first)),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.location_on_outlined, 'Adresses'),
        const SizedBox(height: 8),
        ...List.generate(_addresses.length, (i) {
          final ctls = _addrCtrl[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                Row(children: [
                  _typeDropdown<AddressType>(
                    value: _addresses[i].type,
                    items: AddressType.values,
                    labelOf: (v) => v.label,
                    onChanged: (v) =>
                        setState(() => _addresses[i].type = v!),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 32, width: 32,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 18),
                      onPressed: () => setState(() {
                        for (final c in _addrCtrl[i]) { c.dispose(); }
                        _addrCtrl.removeAt(i);
                        _addresses.removeAt(i);
                      }),
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                _addrField(ctls[0], 'Nº d\'immeuble, rue…', (v) => _addresses[i].street = v),
                const SizedBox(height: 6),
                _addrField(ctls[1], 'Ville',                (v) => _addresses[i].city = v),
                const SizedBox(height: 6),
                _addrField(ctls[2], 'Département ou État',  (v) => _addresses[i].state = v),
                const SizedBox(height: 6),
                _addrField(ctls[3], 'Code postal',          (v) => _addresses[i].postalCode = v),
                const SizedBox(height: 6),
                _addrField(ctls[4], 'Pays',                 (v) => _addresses[i].country = v),
              ]),
            ),
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Ajouter une adresse'),
          onPressed: () => setState(() {
            _addresses.add(Address());
            _addrCtrl.add(_makeAddrCtrl(Address()));
          }),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.cake_outlined, 'Dates importantes'),
        const SizedBox(height: 8),
        ...List.generate(_dates.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            _typeDropdown<DateType>(
              value: _dates[i].type,
              items: DateType.values,
              labelOf: (v) => v.label,
              onChanged: (v) => setState(() => _dates[i].type = v!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _dates[i].date,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) setState(() => _dates[i].date = d);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_dates[i].date.day.toString().padLeft(2, '0')}/'
                    '${_dates[i].date.month.toString().padLeft(2, '0')}/'
                    '${_dates[i].date.year}',
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 32, width: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 18),
                onPressed: () => setState(() => _dates.removeAt(i)),
              ),
            ),
          ]),
        )),
        TextButton.icon(
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Ajouter une date'),
          onPressed: () =>
              setState(() => _dates.add(ImportantDate(date: DateTime.now()))),
        ),
      ],
    );
  }

  Widget _buildWebsiteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.language_outlined, 'Sites Web'),
        const SizedBox(height: 8),
        ...List.generate(_websites.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(children: [
            Row(children: [
              _typeDropdown<WebsiteType>(
                value: _websites[i].type,
                items: WebsiteType.values,
                labelOf: (v) => v.label,
                onChanged: (v) =>
                    setState(() => _websites[i].type = v!),
              ),
              const Spacer(),
              SizedBox(
                height: 32, width: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 18),
                  onPressed: () => setState(() {
                    _websiteCtrl[i].dispose();
                    _websiteCtrl.removeAt(i);
                    _websites.removeAt(i);
                  }),
                ),
              ),
            ]),
            const SizedBox(height: 2),
            _addrField(_websiteCtrl[i], 'URL',
                (v) => _websites[i].url = v),
          ]),
        )),
        TextButton.icon(
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Ajouter un site'),
          onPressed: () => setState(() {
            _websites.add(Website(url: ''));
            _websiteCtrl.add(TextEditingController());
          }),
        ),
      ],
    );
  }

  Widget _buildRelationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.people_outline_rounded, 'Relations'),
        const SizedBox(height: 8),
        ...List.generate(_relations.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(children: [
            Row(children: [
              _typeDropdown<RelationType>(
                value: _relations[i].type,
                items: RelationType.values,
                labelOf: (v) => v.label,
                onChanged: (v) =>
                    setState(() => _relations[i].type = v!),
              ),
              const Spacer(),
              SizedBox(
                height: 32, width: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 18),
                  onPressed: () => setState(() {
                    _relationCtrl[i].dispose();
                    _relationCtrl.removeAt(i);
                    _relations.removeAt(i);
                  }),
                ),
              ),
            ]),
            const SizedBox(height: 2),
            _addrField(_relationCtrl[i], 'Nom',
                (v) => _relations[i].name = v),
          ]),
        )),
        TextButton.icon(
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Ajouter une relation'),
          onPressed: () => setState(() {
            _relations.add(Relation(name: ''));
            _relationCtrl.add(TextEditingController());
          }),
        ),
      ],
    );
  }

  Widget _buildMessagingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.chat_outlined, 'Comptes de messagerie'),
        const SizedBox(height: 8),
        ...List.generate(_messaging.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(children: [
            Row(children: [
              _typeDropdown<MessagingPlatform>(
                value: _messaging[i].platform,
                items: MessagingPlatform.values,
                labelOf: (v) => v.label,
                onChanged: (v) =>
                    setState(() => _messaging[i].platform = v!),
              ),
              const Spacer(),
              SizedBox(
                height: 32, width: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 18),
                  onPressed: () => setState(() {
                    _msgCtrl[i].dispose();
                    _msgCtrl.removeAt(i);
                    _messaging.removeAt(i);
                  }),
                ),
              ),
            ]),
            const SizedBox(height: 2),
            _addrField(
                _msgCtrl[i], 'Identifiant / numéro',
                (v) => _messaging[i].handle = v),
          ]),
        )),
        TextButton.icon(
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Ajouter un compte'),
          onPressed: () => setState(() {
            _messaging.add(MessagingAccount(handle: ''));
            _msgCtrl.add(TextEditingController());
          }),
        ),
      ],
    );
  }

  // ─── Helpers UI ───────────────────────────────────────────────────────────

  Widget _sectionHeader(IconData icon, String label) {
    return Row(children: [
      Icon(icon, size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant),
      const SizedBox(width: 8),
      Text(label, style: Theme.of(context).textTheme.labelLarge),
    ]);
  }

  Widget _addrField(TextEditingController ctrl, String hint,
      ValueChanged<String> onChange) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(hintText: hint),
      onChanged: onChange,
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<T>(
          value: value,
          decoration: const InputDecoration(),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(labelOf(e))))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ── Point 3 : hauteur réduite pour les types ──────────────────────────────
  Widget _typeDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(labelOf(e),
                        style: const TextStyle(fontSize: 12)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}