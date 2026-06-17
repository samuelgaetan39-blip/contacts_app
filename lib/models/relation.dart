enum RelationType { spouse, partner, parent, child, sibling, friend, colleague, manager, other }

extension RelationTypeLabel on RelationType {
  String get label {
    switch (this) {
      case RelationType.spouse:    return 'Époux/Épouse';
      case RelationType.partner:   return 'Partenaire';
      case RelationType.parent:    return 'Parent';
      case RelationType.child:     return 'Enfant';
      case RelationType.sibling:   return 'Frère/Sœur';
      case RelationType.friend:    return 'Ami(e)';
      case RelationType.colleague: return 'Collègue';
      case RelationType.manager:   return 'Responsable';
      case RelationType.other:     return 'Autre';
    }
  }
}

class Relation {
  String _name;
  RelationType _type;
  String? _customLabel;

  Relation({
    required String name,
    RelationType type = RelationType.friend,
    String? customLabel,
  })  : _name = name,
        _type = type,
        _customLabel = customLabel;

  factory Relation.fromJson(Map<String, dynamic> json) {
    return Relation(
      name: json['name'] as String,
      type: RelationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RelationType.other,
      ),
      customLabel: json['customLabel'] as String?,
    );
  }

  String get name => _name;
  set name(String v) => _name = v;

  RelationType get type => _type;
  set type(RelationType t) => _type = t;

  String? get customLabel => _customLabel;
  set customLabel(String? v) => _customLabel = v;

  String get displayLabel =>
      _type == RelationType.other && _customLabel != null ? _customLabel! : _type.label;

  Map<String, dynamic> toJson() => {
        'name': _name,
        'type': _type.name,
        'customLabel': _customLabel,
      };
}