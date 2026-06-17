import 'package:contacts_app/models/address.dart';
import 'package:contacts_app/models/email_address.dart';
import 'package:contacts_app/models/important_date.dart';
import 'package:contacts_app/models/messaging_account.dart';
import 'package:contacts_app/models/phone_number.dart';
import 'package:contacts_app/models/relation.dart';
import 'package:contacts_app/models/website.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:contacts_app/models/contact.dart';
import 'package:contacts_app/services/storage_service.dart';
import 'package:contacts_app/services/api_service.dart';
import 'package:contacts_app/providers/settings_provider.dart';

class ContactsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final ApiService     _api     = ApiService();
  final _uuid = const Uuid();

  List<Contact> _contacts  = [];
  bool   _isLoading        = false;
  bool   _isImporting      = false;
  String? _error;

  List<Contact> get activeContacts  => _contacts.where((c) => !c.isDeleted).toList();
  List<Contact> get trashedContacts => _contacts.where((c) =>  c.isDeleted).toList();

  bool    get isLoading   => _isLoading;
  bool    get isImporting => _isImporting;
  String? get error       => _error;

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _contacts = await _storage.loadContacts();
      _error    = null;
    } catch (e) {
      _error = 'Erreur lors du chargement : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Contact> sortedContacts(SettingsProvider settings) {
    final list = List<Contact>.from(activeContacts);
    list.sort((a, b) {
      int cmp;
      switch (settings.sortCriteria) {
        case SortCriteria.firstName:
          cmp = a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
          break;
        case SortCriteria.lastName:
          cmp = a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
          break;
        case SortCriteria.createdAt:
          cmp = a.createdAt.compareTo(b.createdAt);
          break;
        case SortCriteria.updatedAt:
          cmp = a.updatedAt.compareTo(b.updatedAt);
          break;
      }
      return settings.sortOrder == SortOrder.ascending ? cmp : -cmp;
    });
    return list;
  }

  Map<String, List<Contact>> groupedContacts(SettingsProvider settings) {
    final sorted = sortedContacts(settings);
    final Map<String, List<Contact>> groups = {};
    for (final c in sorted) {
      final key = _groupKey(c, settings.sortCriteria);
      groups.putIfAbsent(key, () => []).add(c);  // correction du bug ()=>[]
    }
    return groups;
  }

  String _groupKey(Contact c, SortCriteria criteria) {
    String first;
    switch (criteria) {
      case SortCriteria.lastName:
        first = c.lastName.isNotEmpty ? c.lastName[0].toUpperCase() : '#';
        break;
      default:
        first = c.firstName.isNotEmpty ? c.firstName[0].toUpperCase() : '#';
    }
    return RegExp(r'[A-ZÀ-Ÿ]').hasMatch(first) ? first : '#';
  }

  List<Contact> search(String query) {
    if (query.trim().isEmpty) return activeContacts;
    final q = query.toLowerCase();
    return activeContacts.where((c) {
      return c.fullName.toLowerCase().contains(q) ||
          c.primaryPhone.contains(q) ||
          c.primaryEmail.toLowerCase().contains(q);
    }).toList();
  }

  Future<Contact> addContact({
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
  }) async {
    final contact = Contact(
      id: _uuid.v4(),
      firstName: firstName,
      lastName: lastName,
      imagePath: imagePath,
      storageLocation: storageLocation,
      phoneNumbers: phoneNumbers,
      emails: emails,
      groups: groups,
      addresses: addresses,
      importantDates: importantDates,
      websites: websites,
      relations: relations,
      messagingAccounts: messagingAccounts,
      ringtone: ringtone,
      notes: notes,
      honorificPrefix: honorificPrefix,
      honorificSuffix: honorificSuffix,
    );
    _contacts.add(contact);
    await _persist();
    return contact;
  }

  Future<void> updateContact(Contact updated) async {
    final index = _contacts.indexWhere((c) => c.id == updated.id);
    if (index == -1) return;
    _contacts[index] = updated;
    await _persist();
  }

  Future<void> moveToTrash(String id) async {
    final contact = _contacts.firstWhere((c) => c.id == id);
    contact.softDelete();
    await _persist();
    notifyListeners();
  }

  Future<void> restoreContact(String id) async {
    final contact = _contacts.firstWhere((c) => c.id == id);
    contact.restore();
    await _persist();
    notifyListeners();
  }

  Future<void> deletePermanently(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> emptyTrash() async {
    _contacts.removeWhere((c) => c.isDeleted);
    await _persist();
    notifyListeners();
  }

  Future<void> restoreAll() async {
    for (final c in trashedContacts) { c.restore(); }
    await _persist();
    notifyListeners();
  }

  Future<int> importFromRandomUser({int count = 10}) async {
    _isImporting = true;
    _error = null;
    notifyListeners();
    try {
      final fetched = await _api.fetchRandomContacts(count: count);
      _contacts.addAll(fetched);
      await _persist();
      return fetched.length;
    } catch (e) {
      _error = e.toString();
      return 0;
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    await _storage.saveContacts(_contacts);
    notifyListeners();
  }
}