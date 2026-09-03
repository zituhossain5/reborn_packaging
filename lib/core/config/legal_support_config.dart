enum LegalSupportLink {
  privacyPolicy('Privacy Policy'),
  terms('Terms & Conditions'),
  support('Contact / Support'),
  accountDeletion('Delete Account');

  const LegalSupportLink(this.label);

  final String label;
}

class LegalSupportConfig {
  const LegalSupportConfig({
    required this.privacyPolicyUrl,
    required this.termsUrl,
    required this.supportUrl,
    required this.accountDeletionUrl,
  });

  factory LegalSupportConfig.fromEnvironment() {
    return const LegalSupportConfig(
      privacyPolicyUrl: String.fromEnvironment('PRIVACY_POLICY_URL'),
      termsUrl: String.fromEnvironment('TERMS_URL'),
      supportUrl: String.fromEnvironment('SUPPORT_URL'),
      accountDeletionUrl: String.fromEnvironment('ACCOUNT_DELETION_URL'),
    );
  }

  final String privacyPolicyUrl;
  final String termsUrl;
  final String supportUrl;
  final String accountDeletionUrl;

  Uri? uriFor(LegalSupportLink link) {
    return switch (link) {
      LegalSupportLink.privacyPolicy => _httpsUri(privacyPolicyUrl),
      LegalSupportLink.terms => _httpsUri(termsUrl),
      LegalSupportLink.support => _httpsUri(supportUrl),
      LegalSupportLink.accountDeletion => _httpsUri(accountDeletionUrl),
    };
  }

  List<LegalSupportLink> get configuredLinks {
    return LegalSupportLink.values
        .where((link) => uriFor(link) != null)
        .toList(growable: false);
  }

  List<String> get missingKeys {
    final missing = <String>[];
    if (_httpsUri(privacyPolicyUrl) == null) missing.add('PRIVACY_POLICY_URL');
    if (_httpsUri(termsUrl) == null) missing.add('TERMS_URL');
    if (_httpsUri(supportUrl) == null) missing.add('SUPPORT_URL');
    if (_httpsUri(accountDeletionUrl) == null) {
      missing.add('ACCOUNT_DELETION_URL');
    }
    return missing;
  }

  static Uri? _httpsUri(String value) {
    final normalizedValue = _plainUrl(value);
    final uri = Uri.tryParse(normalizedValue);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
        ? uri
        : null;
  }

  static String _plainUrl(String value) {
    final trimmed = value.trim();
    final markdownLink = RegExp(r'^\[[^\]]+\]\((https://[^)]+)\)$')
        .firstMatch(trimmed);
    return markdownLink?.group(1)?.trim() ?? trimmed;
  }
}
