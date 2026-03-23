class InvoiceState {
  const InvoiceState({
    this.enabled = false,
    this.businessName = '',
    this.businessAddress = '',
    this.businessPhone = '',
    this.footerText = '',
  });

  final bool enabled;
  final String businessName;
  final String businessAddress;
  final String businessPhone;
  final String footerText;

  /// True when all required business fields are filled.
  bool get isConfigured =>
      businessName.trim().isNotEmpty &&
      businessAddress.trim().isNotEmpty &&
      businessPhone.trim().isNotEmpty;

  InvoiceState copyWith({
    bool? enabled,
    String? businessName,
    String? businessAddress,
    String? businessPhone,
    String? footerText,
  }) => InvoiceState(
    enabled: enabled ?? this.enabled,
    businessName: businessName ?? this.businessName,
    businessAddress: businessAddress ?? this.businessAddress,
    businessPhone: businessPhone ?? this.businessPhone,
    footerText: footerText ?? this.footerText,
  );
}
