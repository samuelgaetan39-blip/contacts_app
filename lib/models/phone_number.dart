enum PhoneType { mobile, home, work, fax, other }

extension PhoneTypeLabel on PhoneType {
  String get label {
    switch (this) {
      case PhoneType.mobile:   return 'Mobile';
      case PhoneType.home:     return 'Domicile';
      case PhoneType.work:     return 'Travail';
      case PhoneType.fax:      return 'Fax';
      case PhoneType.other:    return 'Autre';
    }
  }
}

class PhoneNumber {
  String _value;
  PhoneType _type;
  String? _customLabel;

  PhoneNumber({
    required String value,
    PhoneType type = PhoneType.mobile,
    String? customLabel,
  })  : _value = value,
        _type = type,
        _customLabel = customLabel;

  factory PhoneNumber.fromJson(Map<String, dynamic> json) {
    return PhoneNumber(
      value: json['value'] as String,
      type: PhoneType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PhoneType.mobile,
      ),
      customLabel: json['customLabel'] as String?,
    );
  }

  String get value => _value;
  set value(String v) {
    if (v.trim().isEmpty) throw ArgumentError('Le numéro ne peut pas être vide');
    _value = v.trim();
  }

  PhoneType get type => _type;
  set type(PhoneType t) => _type = t;

  String? get customLabel => _customLabel;
  set customLabel(String? v) => _customLabel = v;

  String get displayLabel =>
      _type == PhoneType.other && _customLabel != null ? _customLabel! : _type.label;

  Map<String, dynamic> toJson() => {
        'value': _value,
        'type': _type.name,
        'customLabel': _customLabel,
      };
}