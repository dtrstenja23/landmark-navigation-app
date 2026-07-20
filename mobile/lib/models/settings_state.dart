class SettingsState {
  const SettingsState({
    this.userId,
    this.mode = 'hybrid',
    this.consentResearch = false,
    this.isLoading = true,
  });

  final int? userId;
  final String mode;
  final bool consentResearch;
  final bool isLoading;

  SettingsState copyWith({
    int? userId,
    String? mode,
    bool? consentResearch,
    bool? isLoading,
  }) {
    return SettingsState(
      userId: userId ?? this.userId,
      mode: mode ?? this.mode,
      consentResearch: consentResearch ?? this.consentResearch,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
