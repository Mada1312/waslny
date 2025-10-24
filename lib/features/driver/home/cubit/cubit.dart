import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
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
  Future<void> getDriverHomeData(BuildContext context) async {
    emit(DriverHomeLoading());
    try {
      final result = await api.getHome();
      result.fold((failure) => emit(DriverHomeError()), (data) {
        homeModel = data;
        isDataVerifided = homeModel?.data?.user?.isVerified == 1;
        if (homeModel?.data?.user?.isDataUploaded != 1) {
          Navigator.pushNamed(context, Routes.driverDataRoute);
        }
       else if (homeModel?.data?.user?.isVerified != 1) {
          completeDialog(
            context,
            btnOkText: 'done'.tr(),
            title: 'reviewing_data'.tr(),
            onPressedOk: () {
              showExitDialog(context);
            },
          );
        }

        emit(DriverHomeLoaded());
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

  changeActiveStatus() {
    homeModel?.data?.user?.isActive = (homeModel?.data?.user?.isActive == 1)
        ? 0
        : 1;
    emit(ChangeOnlineStatusState());
    api.toggleActive().then((value) {
      value.fold((failure) {
        homeModel?.data?.user?.isActive = (homeModel?.data?.user?.isActive == 1)
            ? 0
            : 1;
        emit(ChangeOnlineStatusState());
      }, (response) {});
    });
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
