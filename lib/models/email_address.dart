enum EmailType { personal, work, other }

extension EmailTypeLabel on EmailType {
  String get label {
    switch (this) {
      case EmailType.personal: return 'Personnel';
      case EmailType.work:     return 'Travail';
      case EmailType.other:    return 'Autre';
    }
  }
}

class EmailAddress {
  String _value;
  EmailType _type;
  String? _customLabel;

  EmailAddress({
    required String value,
    EmailType type = EmailType.personal,
    String? customLabel,
  })  : _value = value,
        _type = type,
        _customLabel = customLabel;

  factory EmailAddress.fromJson(Map<String, dynamic> json) {
    return EmailAddress(
      value: json['value'] as String,
      type: EmailType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EmailType.personal,
      ),
      customLabel: json['customLabel'] as String?,
    );
  }

  String get value => _value;
  set value(String v) {
    if (!v.contains('@')) throw ArgumentError('Adresse e-mail invalide');
    _value = v.trim();
  }

  EmailType get type => _type;
  set type(EmailType t) => _type = t;

  String? get customLabel => _customLabel;
  set customLabel(String? v) => _customLabel = v;

  String get displayLabel =>
      _type == EmailType.other && _customLabel != null ? _customLabel! : _type.label;

  Map<String, dynamic> toJson() => {
        'value': _value,
        'type': _type.name,
        'customLabel': _customLabel,
      };
}