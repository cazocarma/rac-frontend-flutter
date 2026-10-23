class AccountStanding {
  const AccountStanding({
    required this.enabled,
    this.status,
    this.version,
    this.capabilities = const {},
  });
  final bool enabled;
  final String? status;
  final int? version;
  final Map<String, bool> capabilities;
  static const commercial = [
    'publish_listing',
    'request_booking',
    'accept_booking',
    'send_message',
    'write_review',
  ];
  static const protective = [
    'submit_report',
    'appeal',
    'access_safety',
    'cancel_own_booking',
    'request_privacy',
    'recover_account',
    'accept_documents',
  ];

  factory AccountStanding.fromJson(Map<String, dynamic> json) {
    if (json['enforcement_enabled'] == false) {
      return const AccountStanding(enabled: false);
    }
    final status = json['status'];
    final version = json['version'];
    final raw = json['capabilities'];
    if (json['enforcement_enabled'] != true ||
        !['active', 'restricted', 'suspended', 'banned'].contains(status) ||
        version is! int ||
        version <= 0 ||
        raw is! Map) {
      throw const FormatException('Invalid account standing');
    }
    final capabilities = <String, bool>{};
    for (final key in [...commercial, ...protective]) {
      if (raw[key] is! bool) {
        throw const FormatException('Invalid account capability');
      }
      capabilities[key] = raw[key] as bool;
    }
    return AccountStanding(
      enabled: true,
      status: status as String,
      version: version,
      capabilities: Map.unmodifiable(capabilities),
    );
  }
  bool get hasRestrictions =>
      enabled && commercial.any((key) => capabilities[key] != true);
}
