import 'dart:io';

import 'package:waslny/core/exports.dart';
import 'package:waslny/core/preferences/preferences.dart';
import 'package:waslny/core/utils/appwidget.dart';
import 'package:waslny/features/maintenance_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/models/fav_ecporter_model.dart';
import '../data/models/main_settings_model.dart';
import '../data/repo.dart';
import 'state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this.api) : super(ProfileInitial());

  ProfileRepo api;

  TextEditingController addressController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  Future<String> _getStoreUrl() async {
    final info = await PackageInfo.fromPlatform();
    final packageName = info.packageName;

    if (Platform.isAndroid) {
      return "https://play.google.com/store/apps/details?id=$packageName";
    } else if (Platform.isIOS) {
      return "https://apps.apple.com/us/app/$packageName";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  Future<void> rateApp() async {
    try {
      final url = await _getStoreUrl();
      final uri = Uri.parse(url);
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!success) throw Exception("Could not launch $url");
      emit(AppUtilsSuccess("App store opened"));
    } catch (e) {
      emit(AppUtilsError(e.toString()));
    }
  }

  Future<void> shareApp() async {
    try {
      final url = await _getStoreUrl();
      await Share.share(url);
      emit(AppUtilsSuccess("App link shared"));
    } catch (e) {
      emit(AppUtilsError(e.toString()));
    }
  }

  contactUs(BuildContext context) async {
    try {
      AppWidget.createProgressDialog(context);
      emit(LoadingContactUsState());

      final res = await api.contactUs(
        address: addressController.text,
        subject: subjectController.text,
        message: messageController.text,
      );

      res.fold(
        (l) {
          errorGetBar(l.toString());
          Navigator.pop(context);

          emit(ErrorContactUsState());
        },
        (r) {
          if (r.status == 200) {
            successGetBar(r.msg);
            addressController.clear();
            subjectController.clear();
            messageController.clear();
            emit(LoadedContactUsState());
            Navigator.pop(context);
          } else {
            errorGetBar(r.msg ?? '');
            emit(ErrorContactUsState());
          }
          Navigator.pop(context);
        },
      );
    } catch (e) {
      errorGetBar(e.toString());
      Navigator.pop(context);
      emit(ErrorContactUsState());
    }
  }

  deleteAccount(BuildContext context) async {
    try {
      AppWidget.createProgressDialog(context);
      emit(LoadingContactUsState());

      final res = await api.deleteAccount();

      res.fold(
        (l) {
          errorGetBar(l.toString());
          Navigator.pop(context);

          emit(ErrorContactUsState());
        },
        (r) {
          if (r.status == 200) {
            successGetBar(r.msg);
            Preferences.instance.clearUser();
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.chooseLoginRoute,
              (route) => false,
            );
            emit(LoadedContactUsState());
          } else {
            errorGetBar(r.msg ?? '');
            Navigator.pop(context);

            emit(ErrorContactUsState());
          }
        },
      );
    } catch (e) {
      errorGetBar(e.toString());
      Navigator.pop(context);
      emit(ErrorContactUsState());
    }
  }

  logout(BuildContext context) async {
    try {
      AppWidget.createProgressDialog(context);
      emit(LoadingContactUsState());

      final res = await api.logout();

      res.fold(
        (l) {
          errorGetBar(l.toString());
          Navigator.pop(context);
          Preferences.instance.clearUser();
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.chooseLoginRoute,
            (route) => false,
          );
          emit(ErrorContactUsState());
        },
        (r) {
          if (r.status == 200) {
            successGetBar(r.msg);
            Preferences.instance.clearUser();
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.chooseLoginRoute,
              (route) => false,
            );
            emit(LoadedContactUsState());
          } else {
            errorGetBar(r.msg ?? '');
            Navigator.pop(context);
            Preferences.instance.clearUser();

            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.chooseLoginRoute,
              (route) => false,
            );

            emit(ErrorContactUsState());
          }
        },
      );
    } catch (e) {
      errorGetBar(e.toString());
      Navigator.pop(context);
      Preferences.instance.clearUser();

      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.chooseLoginRoute,
        (route) => false,
      );
      emit(ErrorContactUsState());
    }
  }

  MainFavModel? mainFavModel;
  getMainFavUserDriver() async {
    try {
      emit(LoadingContactUsState());

      final res = await api.getMainFavUserDriver();

      res.fold(
        (l) {
          emit(ErrorContactUsState());
        },
        (r) {
          if (r.status == 200) {
            mainFavModel = r;
            emit(LoadedContactUsState());
          } else {
            emit(ErrorContactUsState());
          }
        },
      );
    } catch (e) {
      emit(ErrorContactUsState());
    }
  }

  actionFav(String driverId, {bool isFavScreen = true}) async {
    try {
      emit(LoadingContactUsState());

      final res = await api.actionFav(driverId);

      res.fold(
        (l) {
          emit(ErrorContactUsState());
        },
        (r) {
          if (r.status == 200) {
            if (isFavScreen) {
              mainFavModel?.data!.removeWhere(
                (element) => element.driverId.toString() == driverId,
              );
              emit(LoadedContactUsState());
            } else {
              emit(ErrorContactUsState());
            }
          }
        },
      );
    } catch (e) {
      emit(ErrorContactUsState());
    }
  }

  MainSettingModel? settings;
  getSettings(BuildContext context) async {
    try {
      emit(LoadingContactUsState());

      final res = await api.getSettings();

      res.fold(
        (l) {
          emit(ErrorContactUsState());
        },
        (r) async {
          if (r.status == 200) {
            settings = r;
            if (r.data?.appMaintenance == 'true') {
              //!
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MaintenanceScreen()),
              );
            }
            if (r.data?.liveLocationHours != null) {
              await Preferences.instance.setLocationHours(
                r.data?.liveLocationHours ?? '3',
              );
            }
            await checkAndShowUpdateDialog(
              context: context,
              latestAndroidVersion: r.data?.androidAppVersion ?? "1.0.0",
              latestIosVersion: r.data?.iosAppVersion ?? "1.0.0",
            );
            emit(LoadedContactUsState());
          } else {
            emit(ErrorContactUsState());
          }
        },
      );
    } catch (e) {
      emit(ErrorContactUsState());
    }
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> checkAndShowUpdateDialog({
    required BuildContext context,
    required String latestAndroidVersion,
    required String latestIosVersion,
  }) async {
    // Get current app version info
    final packageInfo = await PackageInfo.fromPlatform();

    // Determine platform and latest version
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final latestVersion = isIOS ? latestIosVersion : latestAndroidVersion;

    // Extract build numbers for comparison
    final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
    final latestBuild = extractBuildMetadata(latestVersion) ?? 0;

    // Debug prints (optional, can be removed)
    debugPrint('Current: ${packageInfo.version}+${packageInfo.buildNumber}');
    debugPrint('Latest: $latestVersion');

    // Check if update is needed
    final needsUpdate = !isCurrentVersionGreaterThanOrEqual(
      packageInfo.version,
      latestVersion,
      currentBuild,
      latestBuild,
    );

    if (needsUpdate) {
      _showUpdateDialog(context, latestVersion, packageInfo.packageName, isIOS);
    }
  }

  int? extractBuildMetadata(String version) {
    final buildRegExp = RegExp(r'\+(\d+)$');
    final match = buildRegExp.firstMatch(version);
    return match != null ? int.parse(match.group(1)!) : null;
  }

  bool isCurrentVersionGreaterThanOrEqual(
    String currentVersion,
    String targetVersion,
    int currentBuildNumber,
    int targetBuildVersion,
  ) {
    final versionRegExp = RegExp(r'^(\d+)\.(\d+)\.(\d+)');
    final currentMatch = versionRegExp.firstMatch(currentVersion);
    final targetMatch = versionRegExp.firstMatch(targetVersion);

    if (currentMatch == null || targetMatch == null) {
      throw FormatException('Invalid version format');
    }

    final currentMajor = int.parse(currentMatch.group(1)!);
    final currentMinor = int.parse(currentMatch.group(2)!);
    final currentPatch = int.parse(currentMatch.group(3)!);

    final targetMajor = int.parse(targetMatch.group(1)!);
    final targetMinor = int.parse(targetMatch.group(2)!);
    final targetPatch = int.parse(targetMatch.group(3)!);

    if (currentMajor > targetMajor) return true;
    if (currentMajor < targetMajor) return false;

    if (currentMinor > targetMinor) return true;
    if (currentMinor < targetMinor) return false;

    if (currentPatch > targetPatch) return true;
    if (currentPatch < targetPatch) return false;

    // If version numbers are equal, compare build numbers
    return currentBuildNumber >= targetBuildVersion;
  }

  void _showUpdateDialog(
    BuildContext context,
    String latestVersion,
    String packageName,
    bool isIOS,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: Icon(
                    Icons.tips_and_updates_rounded,
                    color: Colors.orange,
                  ),
                ),
                const Flexible(child: Text('متاح تحديث')),
              ],
            ),
            content: Text(
              'توجد نسخة جديدة ($latestVersion). يرجى التحديث إلى أحدث نسخة.',
            ),
            actions: <Widget>[
              TextButton(
                child: Text('تحديث الان!'),
                onPressed: () async {
                  final url = isIOS
                      ? 'https://apps.apple.com/app/idYOUR_APP_ID' // <-- Replace with your App Store ID
                      : 'https://play.google.com/store/apps/details?id=$packageName';
                  _launchUrl(url);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
