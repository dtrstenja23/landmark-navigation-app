import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdentityService {
  static const _deviceIdKey = 'device_id';

  Future<String> getDeviceId() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final existingId = sharedPrefs.getString(_deviceIdKey);
    if (existingId != null) return existingId;

    final newId = const Uuid().v4();
    await sharedPrefs.setString(_deviceIdKey, newId);
    return newId;
  }
}
