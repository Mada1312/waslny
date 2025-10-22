import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/background_services.dart';
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/repo.dart';
import 'state.dart';

class DriverHomeCubit extends Cubit<DriverHomeState> {
  DriverHomeCubit(this.api) : super(DriverHomeInitial()) {
    // _checkServiceStatus();
    // _listenToServiceUpdates();
  }

  DriverHomeRepo api;

  GetDriverHomeModel? homeModel;
  Future<void> getDriverHomeData(BuildContext context) async {
    emit(DriverHomeLoading());
    try {
      final result = await api.getHome();
      result.fold((failure) => emit(DriverHomeError()), (data) {
        homeModel = data;

        emit(DriverHomeLoaded());
        // if (homeModel?.data?.hasShipment == false) {
        //   stopLocationService();
        // } else {
        //   homeModel?.data?.currentDriverShipment?.status == 2
        //       //  &&
        //       //         homeModel?.data?.currentDriverShipment?.driverIsDeliverd ==
        //       //             0
        //       ? isServiceRunning
        //           ? null
        //           : startLocationService(context: context)
        //       : stopLocationService();
        // }
      });
    } catch (e) {
      log("Error in getDriverHomeData: $e");
      emit(DriverHomeError());
    }
  }

  Future<void> completeShipment({
    required String shipmentId,
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(CompleteShipmentLoadingState());
    try {
      final response = await api.completeShipment(id: shipmentId);
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(CompleteShipmentErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(CompleteShipmentSuccessState());
            // stopLocationService();
            successGetBar(response.msg ?? "Shipment completed successfully");
            Navigator.pushNamed(context, Routes.mainRoute, arguments: true);
            getDriverHomeData(context);
          } else {
            errorGetBar(response.msg ?? "Failed to complete shipment");
          }
        },
      );
    } catch (e) {
      log("Error in completeShipment: $e");
      emit(CompleteShipmentErrorState());
    }
  }

  Future<void> cancleCurrentShipment({
    required String shipmentId,
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(CancelShipmentLoadingState());
    try {
      final response = await api.cancleCurrentShipment(id: shipmentId);
      response.fold(
        (failure) {
          Navigator.pop(context); // Close the progress dialog
          emit(CancelShipmentErrorState());
        },
        (response) {
          Navigator.pop(context); // Close the progress dialog
          if (response.status == 200 || response.status == 201) {
            emit(CancelShipmentSuccessState());
            successGetBar(response.msg ?? "Shipment cancelled successfully");
            Navigator.pushNamed(context, Routes.mainRoute, arguments: true);
            getDriverHomeData(context);
          } else {
            errorGetBar(response.msg ?? "Failed to cancel shipment");
          }
        },
      );
    } catch (e) {
      log("Error in cancelShipment: $e");
      emit(CancelShipmentErrorState());
    }
  }

  // wasalnyyy  */

  bool isOnline = false;

  changeOnlineStatus() {
    isOnline = !isOnline;
    emit(ChangeOnlineStatusState());
  }

  // 0 first time 1 has trip
  int step = 0;

  changeStep() {
    if (step == 1)
      step = 0;
    else
      step++;
    emit(ChangeOnlineStatusState());
  }

  int selectedIndex = 1;

  changeSelectedIndex(int index) {
    selectedIndex = index;
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

  Future<void> pickImage(DriverDataImages imageType, bool isCamera) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile != null) {
      setImageFile(imageType, File(pickedFile.path));
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
