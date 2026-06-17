enum AddressType { home, work, other }

extension AddressTypeLabel on AddressType {
  String get label {
    switch (this) {
      case AddressType.home:  return 'Domicile';
      case AddressType.work:  return 'Travail';
      case AddressType.other: return 'Autre';
    }
  }
}

class Address {
  String _street;
  String _city;
  String _state;
  String _postalCode;
  String _country;
  AddressType _type;
  String? _customLabel;

  Address({
    String street = '',
    String city = '',
    String state = '',
    String postalCode = '',
    String country = '',
    AddressType type = AddressType.home,
    String? customLabel,
  })  : _street = street,
        _city = city,
        _state = state,
        _postalCode = postalCode,
        _country = country,
        _type = type,
        _customLabel = customLabel;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      country: json['country'] as String? ?? '',
      type: AddressType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AddressType.home,
      ),
      customLabel: json['customLabel'] as String?,
    );
  }

  String get street => _street;
  set street(String v) => _street = v;

  String get city => _city;
  set city(String v) => _city = v;

  String get state => _state;
  set state(String v) => _state = v;

  String get postalCode => _postalCode;
  set postalCode(String v) => _postalCode = v;

  String get country => _country;
  set country(String v) => _country = v;

  AddressType get type => _type;
  set type(AddressType t) => _type = t;

  String? get customLabel => _customLabel;
  set customLabel(String? v) => _customLabel = v;

  String get displayLabel =>
      _type == AddressType.other && _customLabel != null ? _customLabel! : _type.label;

  String get fullAddress {
    final parts = [_street, _city, _state, _postalCode, _country]
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  bool get isEmpty =>
      _street.isEmpty && _city.isEmpty && _state.isEmpty &&
      _postalCode.isEmpty && _country.isEmpty;

  Map<String, dynamic> toJson() => {
        'street': _street,
        'city': _city,
        'state': _state,
        'postalCode': _postalCode,
        'country': _country,
        'type': _type.name,
        'customLabel': _customLabel,
      };
}