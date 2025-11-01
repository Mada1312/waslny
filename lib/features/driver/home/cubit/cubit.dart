import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/main/screens/main_screen.dart';

import '../data/repo.dart';
import 'state.dart';

class DriverHomeCubit extends Cubit<DriverHomeState> {
  DriverHomeCubit(this.api) : super(DriverHomeInitial()) {
    // _checkServiceStatus();
    // _listenToServiceUpdates();
  }

  DriverHomeRepo api;
  bool isDataVerifided = false;
  GetDriverHomeModel? homeModel;
  Future<void> getDriverHomeData(
    BuildContext context, {
    bool? isVerify = false,
  }) async {
    emit(DriverHomeLoading());
    try {
      final result = await api.getHome();
      result.fold((failure) => emit(DriverHomeError()), (data) {
        homeModel = data;
        log('6666666666666 ${data.data?.isWebhookVerified}');
        // if (!(isVerify == true) || data.data?.isWebhookVerified == 1) {
        // if (data.data?.isWebhookVerified == 0) {
        //   Navigator.pushReplacementNamed(
        //     context,
        //     Routes.notVerifiedUserRoute,
        //     arguments: true,
        //   );
        // } else {
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
        // }
        // }

        emit(DriverHomeLoaded());
      });
    } catch (e) {
      log("Error in getDriverHomeData: $e");
      emit(DriverHomeError());
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
          Navigator.pop(context); // Close the progress dialog
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(UpdateTripStatusSuccessState());
            successGetBar(response.msg ?? "Trip started successfully");
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
          Navigator.pop(context); // Close the progress dialog
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(UpdateTripStatusSuccessState());
            successGetBar(response.msg ?? "Trip ended successfully");
            Navigator.pushNamed(context, Routes.mainRoute, arguments: true);
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
          Navigator.pop(context); // Close the progress dialog
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(UpdateTripStatusSuccessState());
            successGetBar(response.msg ?? "Trip cancelled successfully");
            Navigator.pushNamed(context, Routes.mainRoute, arguments: true);
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
          homeModel?.data?.user?.isActive =
              (homeModel?.data?.user?.isActive == 1) ? 0 : 1;
          successGetBar(s.msg);
          emit(ChangeOnlineStatusState());
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
    // Get the system's temporary directory to store the output file
    final dir = await getTemporaryDirectory();

    // Create a unique target path for the compressed file
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

  /// 2. Updated File Picker Method
  Future<void> pickImage(DriverDataImages imageType, bool isCamera) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile != null) {
      final originalPath = pickedFile.path;

      // Step 1: Attempt to compress the picked file
      final compressedFile = await compressImage(originalPath, quality: 70);

      // Step 2: Decide which file to use
      final fileToSet =
          compressedFile ??
          File(originalPath); // Use compressed, fallback to original

      // Step 3: Set the file and update state
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

    // الزر يتعطّل لو في صورة ناقصة من الخطوة الحالية
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
