import 'package:contacts_app/models/address.dart';
import 'package:contacts_app/models/email_address.dart';
import 'package:contacts_app/models/important_date.dart';
import 'package:contacts_app/models/messaging_account.dart';
import 'package:contacts_app/models/phone_number.dart';
import 'package:contacts_app/models/relation.dart';
import 'package:contacts_app/models/website.dart';

// Point 5 : SIM 1 et SIM 2 remplacés par "Autre"
enum StorageLocation { phone, other }

extension StorageLocationLabel on StorageLocation {
  String get label {
    switch (this) {
      case StorageLocation.phone: return 'Téléphone';
      case StorageLocation.other: return 'Autre';
    }
  }
}

class Contact {
  final String _id;
  String _firstName;
  String _lastName;
  String? _imagePath;
  StorageLocation _storageLocation;
  List<PhoneNumber> _phoneNumbers;
  List<EmailAddress> _emails;
  List<String> _groups;
  List<Address> _addresses;
  List<ImportantDate> _importantDates;
  List<Website> _websites;
  List<Relation> _relations;
  List<MessagingAccount> _messagingAccounts;
  String? _ringtone;
  String? _notes;
  String? _honorificPrefix;
  String? _honorificSuffix;
  final DateTime _createdAt;
  DateTime _updatedAt;
  bool _isDeleted;
  DateTime? _deletedAt;

  Contact({
    required String id,
    required String firstName,
    String lastName = '',
    String? imagePath,
    StorageLocation storageLocation = StorageLocation.phone,
    List<PhoneNumber>? phoneNumbers,
    List<EmailAddress>? emails,
    List<String>? groups,
    List<Address>? addresses,
    List<ImportantDate>? importantDates,
    List<Website>? websites,
    List<Relation>? relations,
    List<MessagingAccount>? messagingAccounts,
    String? ringtone,
    String? notes,
    String? honorificPrefix,
    String? honorificSuffix,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isDeleted = false,
    DateTime? deletedAt,
  })  : _id = id,
        _firstName = firstName,
        _lastName = lastName,
        _imagePath = imagePath,
        _storageLocation = storageLocation,
        _phoneNumbers = phoneNumbers ?? [],
        _emails = emails ?? [],
        _groups = groups ?? [],
        _addresses = addresses ?? [],
        _importantDates = importantDates ?? [],
        _websites = websites ?? [],
        _relations = relations ?? [],
        _messagingAccounts = messagingAccounts ?? [],
        _ringtone = ringtone,
        _notes = notes,
        _honorificPrefix = honorificPrefix,
        _honorificSuffix = honorificSuffix,
        _createdAt = createdAt ?? DateTime.now(),
        _updatedAt = updatedAt ?? DateTime.now(),
        _isDeleted = isDeleted,
        _deletedAt = deletedAt;

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      storageLocation: StorageLocation.values.firstWhere(
        (e) => e.name == json['storageLocation'],
        orElse: () => StorageLocation.phone,
      ),
      phoneNumbers: (json['phoneNumbers'] as List<dynamic>?)
              ?.map((e) => PhoneNumber.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      emails: (json['emails'] as List<dynamic>?)
              ?.map((e) => EmailAddress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      groups: (json['groups'] as List<dynamic>?)?.cast<String>() ?? [],
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      importantDates: (json['importantDates'] as List<dynamic>?)
              ?.map((e) => ImportantDate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      websites: (json['websites'] as List<dynamic>?)
              ?.map((e) => Website.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      relations: (json['relations'] as List<dynamic>?)
              ?.map((e) => Relation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      messagingAccounts: (json['messagingAccounts'] as List<dynamic>?)
              ?.map((e) => MessagingAccount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ringtone: json['ringtone'] as String?,
      notes: json['notes'] as String?,
      honorificPrefix: json['honorificPrefix'] as String?,
      honorificSuffix: json['honorificSuffix'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }

  factory Contact.fromRandomUser(Map<String, dynamic> json, String generatedId) {
    final name     = json['name']     as Map<String, dynamic>;
    final location = json['location'] as Map<String, dynamic>?;
    final picture  = json['picture']  as Map<String, dynamic>?;
    final street   = location?['street'] as Map<String, dynamic>?;

    final phones = <PhoneNumber>[];
    if (json['phone'] != null) {
      phones.add(PhoneNumber(value: json['phone'] as String, type: PhoneType.mobile));
    }
    if (json['cell'] != null) {
      phones.add(PhoneNumber(value: json['cell'] as String, type: PhoneType.mobile));
    }

    final emails = <EmailAddress>[];
    if (json['email'] != null) {
      emails.add(EmailAddress(value: json['email'] as String, type: EmailType.personal));
    }

    final addresses = <Address>[];
    if (location != null) {
      addresses.add(Address(
        street:     '${street?['number'] ?? ''} ${street?['name'] ?? ''}'.trim(),
        city:       location['city']     as String? ?? '',
        state:      location['state']    as String? ?? '',
        postalCode: location['postcode']?.toString() ?? '',
        country:    location['country']  as String? ?? '',
        type:       AddressType.home,
      ));
    }

    return Contact(
      id:           generatedId,
      firstName:    name['first'] as String? ?? '',
      lastName:     name['last']  as String? ?? '',
      imagePath:    picture?['large'] as String?,
      phoneNumbers: phones,
      emails:       emails,
      addresses:    addresses,
    );
  }

  String get id => _id;

  String get firstName => _firstName;
  set firstName(String v) {
    if (v.trim().isEmpty) throw ArgumentError('Le prénom ne peut pas être vide');
    _firstName = v.trim();
    _touch();
  }

  String get lastName => _lastName;
  set lastName(String v) { _lastName = v.trim(); _touch(); }

  String? get imagePath => _imagePath;
  set imagePath(String? v) { _imagePath = v; _touch(); }

  StorageLocation get storageLocation => _storageLocation;
  set storageLocation(StorageLocation v) { _storageLocation = v; _touch(); }

  List<PhoneNumber>      get phoneNumbers      => List.unmodifiable(_phoneNumbers);
  List<EmailAddress>     get emails            => List.unmodifiable(_emails);
  List<String>           get groups            => List.unmodifiable(_groups);
  List<Address>          get addresses         => List.unmodifiable(_addresses);
  List<ImportantDate>    get importantDates    => List.unmodifiable(_importantDates);
  List<Website>          get websites          => List.unmodifiable(_websites);
  List<Relation>         get relations         => List.unmodifiable(_relations);
  List<MessagingAccount> get messagingAccounts => List.unmodifiable(_messagingAccounts);

  String? get ringtone => _ringtone;
  set ringtone(String? v) { _ringtone = v; _touch(); }

  String? get notes => _notes;
  set notes(String? v) { _notes = v; _touch(); }

  String? get honorificPrefix => _honorificPrefix;
  set honorificPrefix(String? v) { _honorificPrefix = v; _touch(); }

  String? get honorificSuffix => _honorificSuffix;
  set honorificSuffix(String? v) { _honorificSuffix = v; _touch(); }

  DateTime  get createdAt => _createdAt;
  DateTime  get updatedAt => _updatedAt;
  bool      get isDeleted => _isDeleted;
  DateTime? get deletedAt => _deletedAt;

  String get fullName {
    final parts = [
      if (_honorificPrefix?.isNotEmpty == true) _honorificPrefix!,
      _firstName,
      _lastName,
      if (_honorificSuffix?.isNotEmpty == true) _honorificSuffix!,
    ];
    return parts.join(' ').trim();
  }

  String get initials {
    final f = _firstName.isNotEmpty ? _firstName[0].toUpperCase() : '';
    final l = _lastName.isNotEmpty  ? _lastName[0].toUpperCase()  : '';
    return '$f$l'.isEmpty ? '?' : '$f$l';
  }

  String get primaryPhone => _phoneNumbers.isNotEmpty ? _phoneNumbers.first.value : '';
  String get primaryEmail => _emails.isNotEmpty       ? _emails.first.value       : '';

  void addPhoneNumber(PhoneNumber p)           { _phoneNumbers.add(p);  _touch(); }
  void removePhoneNumber(int i)                { _removeAt(_phoneNumbers, i); }
  void updatePhoneNumber(int i, PhoneNumber p) { _phoneNumbers[i] = p;  _touch(); }

  void addEmail(EmailAddress e)                { _emails.add(e);        _touch(); }
  void removeEmail(int i)                      { _removeAt(_emails, i); }
  void updateEmail(int i, EmailAddress e)      { _emails[i] = e;        _touch(); }

  void addGroup(String g)    { if (!_groups.contains(g)) { _groups.add(g); _touch(); } }
  void removeGroup(String g) { _groups.remove(g); _touch(); }

  void addAddress(Address a)       { _addresses.add(a);       _touch(); }
  void removeAddress(int i)        { _removeAt(_addresses, i); }

  void addImportantDate(ImportantDate d)  { _importantDates.add(d);      _touch(); }
  void removeImportantDate(int i)         { _removeAt(_importantDates, i); }

  void addWebsite(Website w)       { _websites.add(w);        _touch(); }
  void removeWebsite(int i)        { _removeAt(_websites, i); }

  void addRelation(Relation r)     { _relations.add(r);       _touch(); }
  void removeRelation(int i)       { _removeAt(_relations, i); }

  void addMessagingAccount(MessagingAccount m) { _messagingAccounts.add(m); _touch(); }
  void removeMessagingAccount(int i)           { _removeAt(_messagingAccounts, i); }

  void softDelete() { _isDeleted = true; _deletedAt = DateTime.now(); _touch(); }
  void restore()    { _isDeleted = false; _deletedAt = null; _touch(); }

  Map<String, dynamic> toJson() => {
        'id':                _id,
        'firstName':         _firstName,
        'lastName':          _lastName,
        'imagePath':         _imagePath,
        'storageLocation':   _storageLocation.name,
        'phoneNumbers':      _phoneNumbers.map((e) => e.toJson()).toList(),
        'emails':            _emails.map((e) => e.toJson()).toList(),
        'groups':            _groups,
        'addresses':         _addresses.map((e) => e.toJson()).toList(),
        'importantDates':    _importantDates.map((e) => e.toJson()).toList(),
        'websites':          _websites.map((e) => e.toJson()).toList(),
        'relations':         _relations.map((e) => e.toJson()).toList(),
        'messagingAccounts': _messagingAccounts.map((e) => e.toJson()).toList(),
        'ringtone':          _ringtone,
        'notes':             _notes,
        'honorificPrefix':   _honorificPrefix,
        'honorificSuffix':   _honorificSuffix,
        'createdAt':         _createdAt.toIso8601String(),
        'updatedAt':         _updatedAt.toIso8601String(),
        'isDeleted':         _isDeleted,
        'deletedAt':         _deletedAt?.toIso8601String(),
      };

  void _touch() => _updatedAt = DateTime.now();
  void _removeAt(List<dynamic> list, int i) {
    if (i >= 0 && i < list.length) { list.removeAt(i); _touch(); }
  }
}