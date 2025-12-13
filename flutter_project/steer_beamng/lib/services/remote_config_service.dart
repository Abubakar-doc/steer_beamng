import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:steer_beamng/utils/logger.dart';

class RemoteConfigService {
  static FirebaseRemoteConfig? _remoteConfig;
  static int _appVersion = 1;

  static Future<void> initialize() async {
    Logger.info('RemoteConfig init started', tag: 'RC');

    _remoteConfig = FirebaseRemoteConfig.instance;

    await _remoteConfig!.setDefaults(<String, Object>{
      'appVersion': 1,
    });
    Logger.debug('Defaults set: appVersion=1', tag: 'RC');

    await _remoteConfig!.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );
    Logger.debug('Config settings applied', tag: 'RC');

    if (await _hasInternet()) {
      try {
        final activated = await _remoteConfig!.fetchAndActivate();
        Logger.success('Fetch & activate: $activated', tag: 'RC');
      } catch (e) {
        Logger.error(e.toString(), tag: 'RC');
      }
    } else {
      Logger.warn('No internet, using defaults', tag: 'RC');
    }

    final value = _remoteConfig!.getInt('appVersion');
    Logger.info('Received appVersion: $value', tag: 'RC');

    _appVersion = value > 0 ? value : 1;
    Logger.success('Final appVersion: $_appVersion', tag: 'RC');
  }

  static int get requiredAppVersion => _appVersion;

  static Future<bool> _hasInternet() async {
    try {
      final r = await InternetAddress.lookup('example.com');
      return r.isNotEmpty && r.first.rawAddress.isNotEmpty;
    } catch (e) {
      Logger.warn(e.toString(), tag: 'RC');
      return false;
    }
  }
}
