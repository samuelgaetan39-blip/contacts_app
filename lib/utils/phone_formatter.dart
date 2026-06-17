import 'package:flutter/services.dart';

/// Formateur automatique de numéros de téléphone.
/// Détecte le pays via le préfixe et applique l'espacement approprié.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Ne pas formater lors d'une suppression
    if (newValue.text.length < oldValue.text.length) return newValue;
    final formatted = PhoneFormatter.format(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PhoneFormatter {
  PhoneFormatter._();

  static String format(String raw) {
    if (raw.isEmpty) return raw;

    final hasPlus = raw.startsWith('+');
    final digits  = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return hasPlus ? '+' : '';

    // Identification par préfixe international
    if (hasPlus || digits.length > 8) {
      if (_starts(digits, '509') || raw.startsWith('+509')) {
        return _haiti(digits, hasPlus);
      }
      if (_starts(digits, '1') || raw.startsWith('+1')) {
        return _northAmerica(digits, hasPlus);
      }
      if (_starts(digits, '33') || raw.startsWith('+33')) {
        return _france(digits, hasPlus);
      }
      if (_starts(digits, '44') || raw.startsWith('+44')) {
        return _uk(digits, hasPlus);
      }
      if (_starts(digits, '49') || raw.startsWith('+49')) {
        return _germany(digits, hasPlus);
      }
      if (_starts(digits, '34') || raw.startsWith('+34')) {
        return _spain(digits, hasPlus);
      }
      if (_starts(digits, '55') || raw.startsWith('+55')) {
        return _brazil(digits, hasPlus);
      }
    }

    // Numéro local (≤ 8 chiffres) → Haïti par défaut
    return _localHaiti(digits);
  }

  // ─── Haïti : +509 XXXX XXXX ──────────────────────────────────────────────
  static String _haiti(String digits, bool hasPlus) {
    final local = digits.startsWith('509')
        ? digits.substring(3)
        : digits;
    final trimmed = local.substring(0, local.length > 8 ? 8 : local.length);
    final prefix  = hasPlus ? '+509' : '509';
    if (trimmed.isEmpty) return prefix;
    if (trimmed.length <= 4) return '$prefix $trimmed';
    return '$prefix ${trimmed.substring(0, 4)} ${trimmed.substring(4)}';
  }

  static String _localHaiti(String digits) {
    final d = digits.substring(0, digits.length > 8 ? 8 : digits.length);
    if (d.length <= 4) return d;
    return '${d.substring(0, 4)} ${d.substring(4)}';
  }

  // ─── USA / Canada : +1 (XXX) XXX-XXXX ───────────────────────────────────
  static String _northAmerica(String digits, bool hasPlus) {
    final local   = digits.startsWith('1') ? digits.substring(1) : digits;
    final trimmed = local.substring(0, local.length > 10 ? 10 : local.length);
    final prefix  = hasPlus ? '+1' : '1';
    if (trimmed.isEmpty)      return prefix;
    if (trimmed.length <= 3)  return '$prefix ($trimmed';
    if (trimmed.length <= 6)  return '$prefix (${trimmed.substring(0, 3)}) ${trimmed.substring(3)}';
    return '$prefix (${trimmed.substring(0, 3)}) ${trimmed.substring(3, 6)}-${trimmed.substring(6)}';
  }

  // ─── France : +33 X XX XX XX XX ─────────────────────────────────────────
  static String _france(String digits, bool hasPlus) {
    final local   = digits.startsWith('33') ? digits.substring(2) : digits;
    final trimmed = local.substring(0, local.length > 9 ? 9 : local.length);
    final prefix  = hasPlus ? '+33' : '033';
    if (trimmed.isEmpty) return prefix;
    final buf = StringBuffer('$prefix ');
    for (int i = 0; i < trimmed.length; i++) {
      if (i > 0 && i % 2 == 0) buf.write(' ');
      buf.write(trimmed[i]);
    }
    return buf.toString();
  }

  // ─── Royaume-Uni : +44 XXXX XXXXXX ──────────────────────────────────────
  static String _uk(String digits, bool hasPlus) {
    final local   = digits.startsWith('44') ? digits.substring(2) : digits;
    final trimmed = local.substring(0, local.length > 10 ? 10 : local.length);
    final prefix  = hasPlus ? '+44' : '044';
    if (trimmed.isEmpty)     return prefix;
    if (trimmed.length <= 4) return '$prefix $trimmed';
    return '$prefix ${trimmed.substring(0, 4)} ${trimmed.substring(4)}';
  }

  // ─── Allemagne : +49 XXXX XXXXXXX ───────────────────────────────────────
  static String _germany(String digits, bool hasPlus) {
    final local   = digits.startsWith('49') ? digits.substring(2) : digits;
    final trimmed = local.substring(0, local.length > 11 ? 11 : local.length);
    final prefix  = hasPlus ? '+49' : '049';
    if (trimmed.isEmpty)     return prefix;
    if (trimmed.length <= 4) return '$prefix $trimmed';
    return '$prefix ${trimmed.substring(0, 4)} ${trimmed.substring(4)}';
  }

  // ─── Espagne : +34 XXX XXX XXX ───────────────────────────────────────────
  static String _spain(String digits, bool hasPlus) {
    final local   = digits.startsWith('34') ? digits.substring(2) : digits;
    final trimmed = local.substring(0, local.length > 9 ? 9 : local.length);
    final prefix  = hasPlus ? '+34' : '034';
    if (trimmed.isEmpty)     return prefix;
    if (trimmed.length <= 3) return '$prefix $trimmed';
    if (trimmed.length <= 6) return '$prefix ${trimmed.substring(0, 3)} ${trimmed.substring(3)}';
    return '$prefix ${trimmed.substring(0, 3)} ${trimmed.substring(3, 6)} ${trimmed.substring(6)}';
  }

  // ─── Brésil : +55 (XX) XXXXX-XXXX ───────────────────────────────────────
  static String _brazil(String digits, bool hasPlus) {
    final local   = digits.startsWith('55') ? digits.substring(2) : digits;
    final trimmed = local.substring(0, local.length > 11 ? 11 : local.length);
    final prefix  = hasPlus ? '+55' : '055';
    if (trimmed.isEmpty)      return prefix;
    if (trimmed.length <= 2)  return '$prefix ($trimmed';
    if (trimmed.length <= 7)  return '$prefix (${trimmed.substring(0, 2)}) ${trimmed.substring(2)}';
    return '$prefix (${trimmed.substring(0, 2)}) ${trimmed.substring(2, 7)}-${trimmed.substring(7)}';
  }

  static bool _starts(String s, String prefix) => s.startsWith(prefix);
}