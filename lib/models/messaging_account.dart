enum MessagingPlatform { whatsapp, facebook, telegram, instagram, twitter, snapchat, other }

extension MessagingPlatformLabel on MessagingPlatform {
  String get label {
    switch (this) {
      case MessagingPlatform.whatsapp:  return 'WhatsApp';
      case MessagingPlatform.facebook:  return 'Facebook';
      case MessagingPlatform.telegram:  return 'Telegram';
      case MessagingPlatform.instagram: return 'Instagram';
      case MessagingPlatform.twitter:   return 'Twitter/X';
      case MessagingPlatform.snapchat:  return 'Snapchat';
      case MessagingPlatform.other:     return 'Autre';
    }
  }
}

class MessagingAccount {
  String _handle;
  MessagingPlatform _platform;
  String? _customLabel;

  MessagingAccount({
    required String handle,
    MessagingPlatform platform = MessagingPlatform.whatsapp,
    String? customLabel,
  })  : _handle = handle,
        _platform = platform,
        _customLabel = customLabel;

  factory MessagingAccount.fromJson(Map<String, dynamic> json) {
    return MessagingAccount(
      handle: json['handle'] as String,
      platform: MessagingPlatform.values.firstWhere(
        (e) => e.name == json['platform'],
        orElse: () => MessagingPlatform.other,
      ),
      customLabel: json['customLabel'] as String?,
    );
  }

  String get handle => _handle;
  set handle(String v) => _handle = v;

  MessagingPlatform get platform => _platform;
  set platform(MessagingPlatform p) => _platform = p;

  String? get customLabel => _customLabel;
  set customLabel(String? v) => _customLabel = v;

  String get displayLabel =>
      _platform == MessagingPlatform.other && _customLabel != null
          ? _customLabel!
          : _platform.label;

  Map<String, dynamic> toJson() => {
        'handle': _handle,
        'platform': _platform.name,
        'customLabel': _customLabel,
      };
}