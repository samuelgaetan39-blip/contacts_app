import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contacts_app/models/contact.dart';

class StorageService {
  static const String _contactsKey = 'contacts_data';

  // ─── Lecture ──────────────────────────────────────────────────────────────
  Future<List<Contact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_contactsKey);
    if (raw == null) return [];

    try {
      final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
      return decoded
          .map((e) => Contact.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Écriture ─────────────────────────────────────────────────────────────
  Future<void> saveContacts(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(contacts.map((c) => c.toJson()).toList());
    await prefs.setString(_contactsKey, encoded);
  }
}