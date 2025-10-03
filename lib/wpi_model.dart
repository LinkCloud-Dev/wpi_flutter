import 'dart:convert';

Map<String, dynamic>? _inner(Map<String, dynamic>? outer, String key) {
  if (outer == null) return null;
  final s = outer[key] as String?;
  if (s == null) return null;
  return jsonDecode(s) as Map<String, dynamic>;
}

/// ===== WPI =====

enum WpiBusinessResult { success, failure, unknown }

class WpiResponse {
  final int? androidResultCode;
  final String? serviceType;   // WPI_SERVICE_TYPE
  final String? version;       // WPI_VERSION
  final String? sessionId;     // WPI_SESSION_ID
  final Map<String, dynamic>? outer;
  final Map<String, dynamic>? body; // = decoded WPI_RESPONSE

  WpiResponse(
      this.androidResultCode,
      this.serviceType,
      this.version,
      this.sessionId,
      this.outer,
      this.body
  );

  factory WpiResponse.fromChannelMap(Map<String, dynamic>? map) {
    final outer = map == null ? null : Map<String, dynamic>.from(map);
    final inner = _inner(outer, 'WPI_RESPONSE');
    return WpiResponse(
      outer?['androidResultCode'] as int?,
      outer?['WPI_SERVICE_TYPE'] as String?,
      outer?['WPI_VERSION'] as String?,
      outer?['WPI_SESSION_ID'] as String?,
      outer,
      inner,
    );
  }

  WpiBusinessResult get result {
    final r = body?['result'] as String?;
    if (r == null) return WpiBusinessResult.unknown;
    return r.toUpperCase().contains('SUCCESS') ? WpiBusinessResult.success : WpiBusinessResult.failure;
  }

  String? get errorCondition => body?['errorCondition'] as String?;
  String? get remark => body?['remark'] as String?;

  int? get authorizedAmount {
    final v = body?['authorizedAmount'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  String? get currency => body?['currency'] as String?;
  String? get paymentSolutionReference => body?['paymentSolutionReference'] as String?;
  dynamic get receipt => body?['receipt'];

  // Common optional fields
  String? get brandName => body?['brandName'] as String?;
  String? get actionCode => body?['actionCode'] as String?;
  String? get entryMode => body?['entryMode'] as String?;
}

/// ===== WMI =====

enum WmiBusinessResult { success, failure, unknown }

class WmiResponse {
  final int? androidResultCode;
  final String? serviceType;   // WMI_SERVICE_TYPE
  final Map<String, dynamic>? outer;
  final Map<String, dynamic>? body; // = decoded WMI_RESPONSE

  WmiResponse(
      this.androidResultCode,
      this.serviceType,
      this.outer,
      this.body
  );

  factory WmiResponse.fromChannelMap(Map<String, dynamic>? m) {
    final outer = m == null ? null : Map<String, dynamic>.from(m);
    final inner = _inner(outer, 'WMI_RESPONSE');
    return WmiResponse(
      outer?['androidResultCode'] as int?,
      outer?['WMI_SERVICE_TYPE'] as String?,
      outer,
      inner,
    );
  }

  WmiBusinessResult get result {
    final r = body?['result'] as String?;
    if (r == null) return WmiBusinessResult.unknown;
    return r.toUpperCase().contains('SUCCESS') ? WmiBusinessResult.success : WmiBusinessResult.failure;
  }

  String? get errorCondition => body?['errorCondition'] as String?;
  String? get remark => body?['remark'] as String?;
  String? get appStatus => body?['appStatus'] as String?;
}
