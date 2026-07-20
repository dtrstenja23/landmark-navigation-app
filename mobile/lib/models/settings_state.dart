class SettingsState {
  const SettingsState({
    this.userId,
    this.mode = 'hybrid',
    this.isLoading = true,
  });

  final int? userId;
  final String mode;
  final bool isLoading;

  SettingsState copyWith({
    int? userId,
    String? mode,
    bool? isLoading,
  }) {
    return SettingsState(
      userId: userId ?? this.userId,
      mode: mode ?? this.mode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
