import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:contacts_app/models/contact.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  static const String _baseUrl = 'https://randomuser.me/api/';
  final _uuid = const Uuid();

  // ─── GET : importer N contacts fictifs depuis randomuser.me ──────────────
  Future<List<Contact>> fetchRandomContacts({int count = 10}) async {
    final uri = Uri.parse('$_baseUrl?results=$count&nat=fr');

    late http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception('Impossible de contacter le serveur : $e');
    }

    if (response.statusCode != 200) {
      throw Exception(
          'Erreur HTTP ${response.statusCode} : ${response.reasonPhrase}');
    }

    late Map<String, dynamic> body;
    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Réponse invalide du serveur.');
    }

    final results = body['results'] as List<dynamic>? ?? [];
    return results.map((raw) {
      return Contact.fromRandomUser(
        raw as Map<String, dynamic>,
        _uuid.v4(),
      );
    }).toList();
  }
}