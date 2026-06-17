enum DateType { birthday, anniversary, other }

extension DateTypeLabel on DateType {
  String get label {
    switch (this) {
      case DateType.birthday:    return 'Anniversaire';
      case DateType.anniversary: return 'Anniversaire de mariage';
      case DateType.other:       return 'Autre';
    }
  }
}

class ImportantDate {
  DateTime _date;
  DateType _type;
  String? _customLabel;

  ImportantDate({
    required DateTime date,
    DateType type = DateType.birthday,
    String? customLabel,
  })  : _date = date,
        _type = type,
        _customLabel = customLabel;

  factory ImportantDate.fromJson(Map<String, dynamic> json) {
    return ImportantDate(
      date: DateTime.parse(json['date'] as String),
      type: DateType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DateType.birthday,
      ),
      customLabel: json['customLabel'] as String?,
    );
  }

  DateTime get date => _date;
  set date(DateTime d) => _date = d;

  DateType get type => _type;
  set type(DateType t) => _type = t;

  String? get customLabel => _customLabel;
  set customLabel(String? v) => _customLabel = v;

  String get displayLabel =>
      _type == DateType.other && _customLabel != null ? _customLabel! : _type.label;

  Map<String, dynamic> toJson() => {
        'date': _date.toIso8601String(),
        'type': _type.name,
        'customLabel': _customLabel,
      };
}