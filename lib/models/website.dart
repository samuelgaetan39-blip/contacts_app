enum WebsiteType { personal, work, blog, other }

extension WebsiteTypeLabel on WebsiteType {
  String get label {
    switch (this) {
      case WebsiteType.personal: return 'Personnel';
      case WebsiteType.work:     return 'Travail';
      case WebsiteType.blog:     return 'Blog';
      case WebsiteType.other:    return 'Autre';
    }
  }
}

class Website {
  String _url;
  WebsiteType _type;
  String? _customLabel;

  Website({
    required String url,
    WebsiteType type = WebsiteType.personal,
    String? customLabel,
  })  : _url = url,
        _type = type,
        _customLabel = customLabel;

  factory Website.fromJson(Map<String, dynamic> json) {
    return Website(
      url: json['url'] as String,
      type: WebsiteType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WebsiteType.personal,
      ),
      customLabel: json['customLabel'] as String?,
    );
  }

  String get url => _url;
  set url(String v) => _url = v.trim();

  WebsiteType get type => _type;
  set type(WebsiteType t) => _type = t;

  String? get customLabel => _customLabel;
  set customLabel(String? v) => _customLabel = v;

  String get displayLabel =>
      _type == WebsiteType.other && _customLabel != null ? _customLabel! : _type.label;

  Map<String, dynamic> toJson() => {
        'url': _url,
        'type': _type.name,
        'customLabel': _customLabel,
      };
}