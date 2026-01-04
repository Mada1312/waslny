// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:waslny/features/main/screens/main_screen.dart';

import '../data/repo.dart';
import 'state.dart';

class DriverHomeCubit extends Cubit<DriverHomeState> {
  DriverHomeCubit(this.api) : super(DriverHomeInitial());

  DriverHomeRepo api;
  bool isDataVerifided = false;
  GetDriverHomeModel? homeModel;

  // ================== Polling ==================
  Timer? _idlePollingTimer;
  static const Duration _idlePollingInterval = Duration(seconds: 5);

  Future<void> getDriverHomeData(
    BuildContext context, {
    bool? isVerify = false,
  }) async {
    emit(DriverHomeLoading());
    try {
      final result = await api.getHome();
      result.fold((failure) => emit(DriverHomeError()), (data) {
        if (data.status != 200 && data.status != 201) {
          emit(DriverHomeError());
          return;
        }
        homeModel = data;
        log('6666666666666 ${data.data?.isWebhookVerified}');

        isDataVerifided = homeModel?.data?.user?.isVerified == 1;
        if (homeModel?.data?.user?.isDataUploaded != 1) {
          Navigator.pushNamed(context, Routes.driverDataRoute);
        } else if (homeModel?.data?.user?.isVerified != 1) {
          completeDialog(
            context,
            btnOkText: 'done'.tr(),
            title: 'reviewing_data'.tr(),
            onPressedOk: () async {
              bool shouldExit = await showExitDialog(context);
              log("shouldExit: $shouldExit");
              if (shouldExit) {
                SystemNavigator.pop();
              }
            },
          );
        }

        emit(DriverHomeLoaded());

        // ✅ ابدأ الـ polling دايمًا
        _startIdlePolling();
      });
    } catch (e) {
      log("Error in getDriverHomeData: $e");
      emit(DriverHomeError());
    }
  }

  /*============================================================================*/
  /*                           SMART POLLING                                   */
  /*============================================================================*/
  void _startIdlePolling() {
    // ✅ شرط: ميعملش polling غير لما الكابتن يكون متصل (isActive == 1)
    if (homeModel?.data?.user?.isActive != 1) {
      log('⏹️ Polling not started: Driver is offline (isActive != 1)');
      _stopIdlePolling();
      return;
    }

    // ✅ لو الـ polling يعمل بالفعل → لا تبدأ واحد جديد
    if (_idlePollingTimer != null) {
      log('✅ Polling already running');
      return;
    }

    log('🔄 Starting Polling... (Driver is online)');

    _idlePollingTimer = Timer.periodic(_idlePollingInterval, (_) async {
      try {
        // ✅ تحقق من الحالة قبل كل polling
        if (homeModel?.data?.user?.isActive != 1) {
          log('⏹️ Polling stopped: Driver went offline');
          _stopIdlePolling();
          return;
        }

        final result = await api.getHome();
        result.fold(
          (failure) {
            log("⚠️ Polling error: API failed");
          },
          (data) {
            try {
              // ✅ قارن البيانات بشكل مفصّل
              if (_isSameTripData(
                homeModel?.data?.currentTrip,
                data.data?.currentTrip,
              )) {
                log('📊 Polling: No changes detected');
                return;
              }

              // ✅ إذا كانت هناك تغييرات → حدّث البيانات
              homeModel = data;
              emit(DriverHomeLoaded());

              log(
                '✅ بيانات محدّثة: trip = ${data.data?.currentTrip?.id ?? "none"}, status = ${data.data?.currentTrip?.status ?? "none"}',
              );
            } catch (e) {
              log('⚠️ Error in polling comparison: $e');
              homeModel = data;
              emit(DriverHomeLoaded());
            }
          },
        );
      } catch (e) {
        log("❌ Polling error: $e");
      }
    });
  }

  /*============================================================================*/
  /*                    COMPARE TRIP DATA (SMART)                              */
  /*============================================================================*/
  bool _isSameTripData(DriverTripModel? oldTrip, DriverTripModel? newTrip) {
    // لو كلاهما null = نفس
    if (oldTrip == null && newTrip == null) return true;

    // لو واحد null والآخر لا = مختلف
    if (oldTrip == null || newTrip == null) return false;

    try {
      // ✅ قارن الـ properties الأساسية والمهمة
      return oldTrip.id == newTrip.id &&
          oldTrip.status == newTrip.status &&
          oldTrip.statusName == newTrip.statusName &&
          oldTrip.isDriverArrived == newTrip.isDriverArrived &&
          oldTrip.isUserStartTrip == newTrip.isUserStartTrip &&
          oldTrip.isDriverStartTrip == newTrip.isDriverStartTrip &&
          oldTrip.isUserAccept == newTrip.isUserAccept &&
          oldTrip.isDriverAccept == newTrip.isDriverAccept &&
          oldTrip.isUserChangeCaptain == newTrip.isUserChangeCaptain &&
          oldTrip.isDriverAnotherTrip == newTrip.isDriverAnotherTrip;
    } catch (e) {
      log('❌ Error comparing trips: $e');
      return false;
    }
  }

  /*============================================================================*/
  /*                         STOP POLLING                                      */
  /*============================================================================*/
  void _stopIdlePolling() {
    if (_idlePollingTimer != null) {
      _idlePollingTimer?.cancel();
      _idlePollingTimer = null;
      log('⏹️ Polling stopped');
    }
  }

  /*============================================================================*/
  /*                   SILENT REFRESH (بدون loading dialog)                    */
  /*============================================================================*/
  Future<void> getDriverHomeDataSilent() async {
    try {
      final result = await api.getHome();
      result.fold(
        (failure) {
          log("⚠️ Silent refresh failed");
        },
        (data) {
          if (data.status == 200 || data.status == 201) {
            homeModel = data;
            emit(DriverHomeLoaded());

            // ✅ لو صار متصل → ابدأ polling
            if (homeModel?.data?.user?.isActive == 1) {
              log('✅ Driver is now online - starting polling');
              _startIdlePolling();
            } else {
              // ✅ لو صار offline → توقف polling
              log('🔴 Driver is now offline - stopping polling');
              _stopIdlePolling();
            }

            log('✅ Silent refresh: isActive = ${data.data?.user?.isActive}');
          }
        },
      );
    } catch (e) {
      log("Error in getDriverHomeDataSilent: $e");
    }
  }

  Future<void> startTrip({
    required int tripId,
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(UpdateTripStatusLoadingState());
    try {
      final response = await api.startTrip(id: tripId);
      response.fold(
        (failure) {
          Navigator.pop(context);
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context);
          if (response.status == 200 || response.status == 201) {
            emit(UpdateTripStatusSuccessState());
            successGetBar(response.msg ?? "Trip started successfully");
            _stopIdlePolling();
            getDriverHomeData(context);
          } else {
            errorGetBar(response.msg ?? "Failed to start trip");
          }
        },
      );
    } catch (e) {
      log("Error in startTrip: $e");
      emit(UpdateTripStatusErrorState());
    }
  }

  Future<void> endTrip({
    required int tripId,
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(UpdateTripStatusLoadingState());
    try {
      final response = await api.endTrip(id: tripId);
      response.fold(
        (failure) {
          Navigator.pop(context);
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context);
          if (response.status == 200 || response.status == 201) {
            emit(UpdateTripStatusSuccessState());
            successGetBar(response.msg ?? "Trip ended successfully");
            Navigator.pushNamed(context, Routes.mainRoute, arguments: true);
            _stopIdlePolling();
            getDriverHomeData(context);
          } else {
            errorGetBar(response.msg ?? "Failed to end trip");
          }
        },
      );
    } catch (e) {
      log("Error in endTrip: $e");
      emit(UpdateTripStatusErrorState());
    }
  }

  Future<void> cancleTrip({
    required int tripId,
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(UpdateTripStatusLoadingState());
    try {
      final response = await api.cancleTrip(id: tripId);
      response.fold(
        (failure) {
          Navigator.pop(context);
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context);
          if (response.status == 200 || response.status == 201) {
            emit(UpdateTripStatusSuccessState());
            successGetBar(response.msg ?? "Trip cancelled successfully");
            Navigator.pushNamed(context, Routes.mainRoute, arguments: true);
            _stopIdlePolling();
            getDriverHomeData(context);
          } else {
            errorGetBar(response.msg ?? "Failed to cancel trip");
          }
        },
      );
    } catch (e) {
      log("Error in cancelShipment: $e");
      emit(UpdateTripStatusErrorState());
    }
  }

  Future<void> updateTripStatus({
    required TripStep step,
    required int id,
    required BuildContext context,
    String? receiverId,
    String? chatId,
  }) async {
    if (step == TripStep.isDriverArrived) {
      if (context.read<LocationCubit>().currentLocation == null) {
        await context.read<LocationCubit>().checkAndRequestLocationPermission(
          context,
        );
      }
      if (context.read<LocationCubit>().currentLocation == null) {
        errorGetBar("location_required".tr());
        return;
      }
    }
    AppWidget.createProgressDialog(context, msg: "...");
    emit(UpdateTripStatusLoadingState());
    try {
      final response = await api.updateTripStatus(
        id: id,
        step: step,
        arrivalLat: step != TripStep.isDriverArrived
            ? null
            : context.read<LocationCubit>().currentLocation?.latitude,
        arrivalLong: step != TripStep.isDriverArrived
            ? null
            : context.read<LocationCubit>().currentLocation?.longitude,
      );
      response.fold(
        (failure) {
          Navigator.pop(context);
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context);
          if (response.status == 200 || response.status == 201) {
            emit(UpdateTripStatusSuccessState());
            successGetBar(response.msg ?? "Trip cancelled successfully");

            _stopIdlePolling();
            getDriverHomeData(context);

            if (step == TripStep.isDriverArrived) {
              context.read<ChatCubit>().sendMessage(
                isDriverArrived: true,
                chatId: chatId ?? "",
                receiverId: receiverId,
              );
            }
          } else {
            errorGetBar(response.msg ?? "Failed to cancel trip");
          }
        },
      );
    } catch (e) {
      log("Error in cancelShipment: $e");
      emit(UpdateTripStatusErrorState());
    }
  }

  changeActiveStatus() async {
    emit(LoadingChangeOnlineStatusState());
    final res = await api.toggleActive();
    res.fold(
      (l) {
        log(l.toString());
        emit(ErrorChangeOnlineStatusState());
      },
      (s) {
        if (s.status == 200) {
          // ✅ Toggle الحالة محلياً
          homeModel?.data?.user?.isActive =
              (homeModel?.data?.user?.isActive == 1) ? 0 : 1;

          successGetBar(s.msg);
          emit(ChangeOnlineStatusState());

          // ✅ ابدأ/توقف polling بناءً على الحالة الجديدة
          if (homeModel?.data?.user?.isActive == 1) {
            log('✅ Driver is now online - starting polling');
            _startIdlePolling();
          } else {
            log('🔴 Driver went offline - stopping polling');
            _stopIdlePolling();
          }

          // ✅ احصل على البيانات الجديدة من الـ server (بدون dialog)
          getDriverHomeDataSilent();
        } else {
          emit(ErrorChangeOnlineStatusState());
        }
      },
    );
  }

  int selectedStep = 1;

  changeSelectedStep(int index) {
    selectedStep = index;
    emit(ChangeSelectedIndexState());
  }

  File? vehicleInfoFrontImage;
  File? vehicleInfoBackImage;
  File? driverLicenseImage;
  File? idCardFrontImage;
  File? idCardBackImage;
  File? personalPhotoImage;

  void setImageFile(DriverDataImages imageType, File imageFile) {
    switch (imageType) {
      case DriverDataImages.vehicleInfoFront:
        vehicleInfoFrontImage = imageFile;
        break;
      case DriverDataImages.vehicleInfoBack:
        vehicleInfoBackImage = imageFile;
        break;
      case DriverDataImages.driverLicense:
        driverLicenseImage = imageFile;
        break;
      case DriverDataImages.idCardFront:
        idCardFrontImage = imageFile;
        break;
      case DriverDataImages.idCardBack:
        idCardBackImage = imageFile;
        break;
      case DriverDataImages.personalPhoto:
        personalPhotoImage = imageFile;
        break;
    }
    emit(ImageFileUpdatedState());
  }

  showCameraOrImagePicker(BuildContext context, DriverDataImages imageType) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('gallery'.tr()),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(imageType, false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('camera'.tr()),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(imageType, true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File?> compressImage(String path, {int quality = 70}) async {
    final dir = await getTemporaryDirectory();

    final targetPath =
        '${dir.absolute.path}/COMPRESSED_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      final compressedResult = await FlutterImageCompress.compressAndGetFile(
        path,
        targetPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      if (compressedResult != null) {
        debugPrint('Original Size: ${await File(path).length()} bytes');
        debugPrint('Compressed Size: ${await compressedResult.length()} bytes');
        return File(compressedResult.path);
      }
    } catch (e) {
      debugPrint('Error during image compression: $e');
    }
    return null;
  }

  Future<void> pickImage(DriverDataImages imageType, bool isCamera) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile != null) {
      final originalPath = pickedFile.path;

      final compressedFile = await compressImage(originalPath, quality: 70);

      final fileToSet = compressedFile ?? File(originalPath);

      setImageFile(imageType, fileToSet);
    }
  }

  List<DriverDataImages> getRequiredImagesForStep(DriverDataSteps step) {
    switch (step) {
      case DriverDataSteps.vehicleInfo:
        return [
          DriverDataImages.vehicleInfoFront,
          DriverDataImages.vehicleInfoBack,
        ];
      case DriverDataSteps.driverLicense:
        return [DriverDataImages.driverLicense];
      case DriverDataSteps.idCard:
        return [DriverDataImages.idCardFront, DriverDataImages.idCardBack];
      case DriverDataSteps.personalPhoto:
        return [DriverDataImages.personalPhoto];
    }
  }

  bool isNextButtonDisabled(DriverDataSteps currentStep) {
    final requiredImages = getRequiredImagesForStep(currentStep);
    bool isUploaded(DriverDataImages image) {
      switch (image) {
        case DriverDataImages.vehicleInfoFront:
          return vehicleInfoFrontImage != null;
        case DriverDataImages.vehicleInfoBack:
          return vehicleInfoBackImage != null;
        case DriverDataImages.driverLicense:
          return driverLicenseImage != null;
        case DriverDataImages.idCardFront:
          return idCardFrontImage != null;
        case DriverDataImages.idCardBack:
          return idCardBackImage != null;
        case DriverDataImages.personalPhoto:
          return personalPhotoImage != null;
      }
    }

    return !requiredImages.every(isUploaded);
  }

  Future<void> updateDeliveryProfile(BuildContext context) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(UploadDriverDataLoadingState());
    try {
      final response = await api.updateDeliveryProfile(
        frontNationalId: idCardFrontImage,
        backNationalId: idCardBackImage,
        drivingLicense: driverLicenseImage,
        frontVehicleLicense: vehicleInfoFrontImage,
        backVehicleLicense: vehicleInfoBackImage,
        image: personalPhotoImage,
      );
      response.fold(
        (failure) {
          Navigator.pop(context);
          emit(UploadDriverDataErrorState());
        },
        (response) {
          Navigator.pop(context);
          if (response.status == 200 || response.status == 201) {
            emit(UploadDriverDataSuccessState());
            successGetBar(response.msg ?? "Data uploaded successfully");
            completeDialog(
              context,
              btnOkText: 'done'.tr(),
              title: 'review_and_approval'.tr(),
              onPressedOk: () {
                Navigator.pushReplacementNamed(
                  context,
                  Routes.mainRoute,
                  arguments: true,
                );
              },
            );
          } else {
            errorGetBar(response.msg ?? "Failed to upload data");
          }
        },
      );
    } catch (e) {
      log("Error in completeShipment: $e");
      emit(UploadDriverDataErrorState());
    }
  }

  @override
  Future<void> close() {
    _stopIdlePolling();
    return super.close();
  }
}

enum DriverDataImages {
  vehicleInfoFront,
  vehicleInfoBack,
  driverLicense,
  idCardFront,
  idCardBack,
  personalPhoto,
}

enum DriverDataSteps { vehicleInfo, driverLicense, idCard, personalPhoto }
