import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landmark_navigation_app/models/settings_state.dart';
import 'package:landmark_navigation_app/services/device_identity_service.dart';
import 'package:landmark_navigation_app/services/user_service.dart';

class SettingsNotifier extends Notifier<SettingsState> {
  final _deviceIdentityService = DeviceIdentityService();
  final _userService = UserService();

  @override
  SettingsState build() {
    return const SettingsState();
  }

  Future<void> load() async {
    final deviceId = await _deviceIdentityService.getDeviceId();
    final user = await _userService.upsertUser(deviceId: deviceId);
    state = state.copyWith(
      userId: user.id,
      mode: user.preferredMode,
      consentResearch: user.consentResearch,
      isLoading: false,
    );
  }

  Future<void> setMode(String mode) async {
    final userId = state.userId;
    if (userId == null) return;
    try {
      await _userService.updateUser(userId, preferredMode: mode);
      state = state.copyWith(mode: mode);
    } catch (_) {}
  }

  Future<void> setConsent(bool consent) async {
    final userId = state.userId;
    if (userId == null) return;
    try {
      await _userService.updateUser(userId, consentResearch: consent);
      state = state.copyWith(consentResearch: consent);
    } catch (_) {}
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
