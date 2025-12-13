import 'package:package_info_plus/package_info_plus.dart';
import 'package:steer_beamng/services/remote_config_service.dart';
import 'package:steer_beamng/utils/dialog_utils.dart';
import 'package:steer_beamng/utils/logger.dart';
import 'package:steer_beamng/utils/toast_utils.dart';

class AppVersionManager {
  static Future<void> checkForForcedUpdate() async {
    Logger.info('Checking app version...', tag: 'VERSION');

    final info = await PackageInfo.fromPlatform();
    Logger.debug({
      'version': info.version,
      'buildNumber': info.buildNumber,
    }, tag: 'VERSION');

    final versionString = info.buildNumber.trim();
    final localBuild = int.tryParse(versionString) ?? 1;
    Logger.info('Local build: $localBuild', tag: 'VERSION');

    final remoteBuild = RemoteConfigService.requiredAppVersion;
    Logger.info('Remote build: $remoteBuild', tag: 'VERSION');

    if (localBuild < remoteBuild) {
      Logger.warn('Update required', tag: 'VERSION');

      await DialogUtils.showForceUpdateDialog(
        title: 'Update Required!',
        message: "App can't run without update",
        confirmText: 'Update',
        barrierDismissible: false,
      );

      ToastUtils.infoToast(
        'Please update the app in order to continue!',
      );
    } else {
      Logger.success('App is up to date', tag: 'VERSION');
    }
  }
}
