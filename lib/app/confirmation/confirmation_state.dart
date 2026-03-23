class ConfirmationState {
  const ConfirmationState({
    this.enabled = true,
    this.requiredConfirmations = 50,
  });

  final bool enabled;

  /// Number of DAA score confirmations required. Always >= 50.
  final int requiredConfirmations;

  ConfirmationState copyWith({bool? enabled, int? requiredConfirmations}) =>
      ConfirmationState(
        enabled: enabled ?? this.enabled,
        requiredConfirmations:
            requiredConfirmations ?? this.requiredConfirmations,
      );
}
