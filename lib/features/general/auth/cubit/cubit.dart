import 'dart:io';

import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/features/user/add_new_trip/cubit/cubit.dart';

import '../../../../core/exports.dart';
import '../../../../core/preferences/preferences.dart';
import '../data/login_repo.dart';

import 'state.dart';
import 'package:image_picker/image_picker.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.api) : super(LoginStateInitial());
  LoginRepo api;
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController phoneNumberForgetController = TextEditingController();
  String? fullPhoneNumber;
  bool acceptTermsAndConditions = false;
  Gender? gender;
  VehicleType? vehicleType;
  onChangeStatus() {
    acceptTermsAndConditions = !acceptTermsAndConditions;
    emit(OnChangeStatusOfLogin());
  }

  //! Login Method
  Future<void> login(BuildContext context, bool isDriver) async {
    AppWidget.createProgressDialog(context, msg: 'loading'.tr());
    emit(LoadingLoginState());
    final res = await api.login(
      fullPhoneNumber ?? '',
      passwordController.text,
      isDriver: isDriver,
    );
    res.fold(
      (l) {
        errorGetBar(l.toString());
        emit(ErrorLoginState());
        Navigator.pop(context);

        //!
      },
      (r) async {
        try {
          //! Nav to Main Screen
          emit(LoadedLoginState());
          if (r.status == 200) {
            await Preferences.instance.setUser(r);
            successGetBar(r.msg);
            Navigator.pop(context);

            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.mainRoute,
              (route) => false,
              arguments: r.data?.userType == 0 ? false : true,
            );
            clearData();
          } else {
            errorGetBar(r.msg ?? '');
            Navigator.pop(context);

            emit(ErrorLoginState());
          }
        } catch (e) {
          errorGetBar(e.toString());
          Navigator.pop(context);

          emit(ErrorLoginState());
        }

        //!
      },
    );
  }

  clearData() {
    fullPhoneNumber = null;
    phoneNumberController.clear();
    passwordController.clear();
    pinController.clear();
    nameController.clear();
    confirmPasswordController.clear();
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    phoneNumberForgetController.clear();
  }

  Future<void> valudateData(BuildContext context, bool isDriver) async {
    try {
      AppWidget.createProgressDialog(context, msg: 'loading'.tr());
      emit(LoadingValidateDataState());
      final res = await api.validateData(
        isDriver: isDriver,
        name: nameController.text,
        gender: gender?.name == Gender.male.name ? '0' : '1',
        vehicleType: vehicleType?.name == VehicleType.car.name
            ? 'car'
            : 'scooter', //TODO get it from List
        phone: fullPhoneNumber ?? '',
        password: passwordController.text,
      );
      res.fold(
        (l) {
          emit(ErrorValidateDataState());
          Navigator.pop(context);
          errorGetBar(l.toString()); //!
        },
        (r) async {
          //! Nav to Main Screen
          emit(LoadedValidateDataState());
          if (r.status == 200) {
            successGetBar(r.msg);
            Navigator.pop(context);

            Navigator.pushReplacementNamed(
              context,
              Routes.verifyCodeScreen,
              arguments: [isDriver, false],
            );
          } else {
            Navigator.pop(context);

            errorGetBar(r.msg ?? '');
            emit(ErrorValidateDataState());
          }

          //!
        },
      );
    } catch (e) {
      Navigator.pop(context);
      errorGetBar(e.toString()); //!
      emit(ErrorValidateDataState());
    }
  }

  Future<void> register(BuildContext context, bool isDriver) async {
    AppWidget.createProgressDialog(context, msg: 'loading'.tr());
    emit(LoadingLoginState());
    final res = await api.register(
      isDriver: isDriver,
      name: nameController.text,
      gender: gender?.name == Gender.male.name ? '0' : '1',
      vehicleType: vehicleType?.name == Gender.male.name
          ? 'car'
          : 'Moto', //TODO get it from List
      otp: pinController.text,
      phone: fullPhoneNumber ?? '',
      password: passwordController.text,
    );
    res.fold(
      (l) {
        emit(ErrorLoginState());
        Navigator.pop(context);

        //!
      },
      (r) async {
        //! Nav to Main Screen
        emit(LoadedLoginState());
        if (r.status == 200) {
          await Preferences.instance.setUser(r);

          successGetBar(r.msg);
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.mainRoute,
            (route) => false,
            arguments: isDriver,
          );
          clearData();
        } else {
          Navigator.pop(context);
          errorGetBar(r.msg ?? '');
          emit(ErrorLoginState());
        }

        //!
      },
    );
  }

  //! Login Method

  Future<void> forgetPasswordRequest(
    BuildContext context,
    bool isDriver,
  ) async {
    try {
      AppWidget.createProgressDialog(context, msg: 'loading'.tr());
      emit(LoadingsendCodeState());
      final res = await api.forgetPassword(fullPhoneNumber ?? '');
      res.fold(
        (l) {
          errorGetBar(l.toString());
          Navigator.pop(context);
          emit(ErrorsendCodeState());
        },
        (r) async {
          if (r.status == 200) {
            Navigator.pop(context);
            successGetBar(r.msg);
            Navigator.pushReplacementNamed(
              context,
              Routes.verifyCodeScreen,
              arguments: [isDriver, true],
            );
            emit(LoadedsendCodeState());
          } else {
            errorGetBar(r.msg ?? '');
            Navigator.pop(context);

            emit(ErrorsendCodeState());
          }
        },
      );
    } catch (e) {
      errorGetBar(e.toString());
      Navigator.pop(context);
      emit(ErrorsendCodeState());
    }
  }

  //!

  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();

  Future<void> resetPassword(BuildContext context, bool isDriver) async {
    try {
      AppWidget.createProgressDialog(context, msg: 'loading'.tr());
      emit(LoadingNewPasswordState());
      final res = await api.resetPassword(
        fullPhoneNumber ?? '2${phoneNumberForgetController.text}',
        newPasswordController.text,
        pinController.text,
      );

      res.fold(
        (l) {
          Navigator.pop(context);
          errorGetBar(l.toString());

          emit(ErrorNewPasswordState());
        },
        (r) async {
          if (r.status == 200) {
            successGetBar(r.msg);
            Navigator.pop(context);

            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.mainRoute,
              (route) => false,
              arguments: r.data?.userType == 0 ? false : true,
            );

            await Preferences.instance.setUser(r);

            emit(LoadedNewPasswordState());
            clearData();
          } else {
            errorGetBar(r.msg ?? '');
            Navigator.pop(context);

            emit(ErrorNewPasswordState());
          }
        },
      );
    } catch (e) {
      errorGetBar(e.toString());
      Navigator.pop(context);
      emit(ErrorNewPasswordState());
    }
  }

  //! Update
  File? pickedProfileImage;
  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      pickedProfileImage = File(image.path);

      emit(PickImageFromGallaryState());
    } else {
      pickedProfileImage = null;
      emit(PickImageFromGallaryState());
    }
  }

  File? pickedUserCardProfileImage;
  File? pickedDeliveryFrontImage;
  File? pickedDeliveryBackImage;

  Future<void> pickUserCardImageFromGallery({
    bool isBackImage = false,
    bool isDeliveryBackImage = false,
  }) async {
    if (isDeliveryBackImage) {
      if (isBackImage) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );

        if (image != null) {
          pickedDeliveryBackImage = File(image.path);
          emit(PickImageFromGallaryState());
        } else {
          pickedDeliveryBackImage = null;
          emit(PickImageFromGallaryState());
        }
      } else {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );

        if (image != null) {
          pickedDeliveryFrontImage = File(image.path);
          emit(PickImageFromGallaryState());
        } else {
          pickedDeliveryFrontImage = null;
          emit(PickImageFromGallaryState());
        }
      }
    } else {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        pickedUserCardProfileImage = File(image.path);
        emit(PickImageFromGallaryState());
      } else {
        pickedUserCardProfileImage = null;
        emit(PickImageFromGallaryState());
      }
    }
  }

  TextEditingController updateNameController = TextEditingController();
  TextEditingController updateAddressController = TextEditingController();
  TextEditingController updatePhoneNumberController = TextEditingController();
  TextEditingController updateNationalIdController = TextEditingController();

  LoginModel? authData;
  onTapToEdit(BuildContext context, {bool isDeriver = false}) async {
    try {
      emit(GetAuthDataLoading());
      final res = await api.authData();

      res.fold(
        (l) {
          emit(GetAuthDataError());
        },
        (r) {
          authData = r;

          updateNameController.text = r.data?.name ?? '';
          updateAddressController.text = r.data?.address ?? '';
          updatePhoneNumberController.text = r.data?.phone.toString() ?? '';
          updateNationalIdController.text = r.data?.nationalId ?? '';

          emit(GetAuthDataLoaded());
        },
      );
    } catch (e) {
      emit(GetAuthDataError());
    }
  }

  bool isFirstTime = true;
  getAuthData(BuildContext context) async {
    try {
      emit(GetAuthDataLoading());
      final res = await api.authData();

      res.fold(
        (l) {
          emit(GetAuthDataError());
        },
        (r) {
          authData = r;

          if (isFirstTime) {
            /*if (authData?.data?.userType == 0) {
              if (authData?.data?.exportCard == null) {
                warningDialog(
                  context,
                  title: 'you_are_didnt_upload_export_card_please_upload_it'
                      .tr(),
                  onPressedOk: () {
                    Navigator.pushNamed(context, Routes.editUserProfileRoute);
                  },
                );
              }
            } else {
              if (authData?.data?.frontDriverCard == null &&
                  authData?.data?.backDriverCard == null) {
                warningDialog(
                  context,
                  title: 'you_are_didnt_upload_driver_card_please_upload_it'
                      .tr(),
                  onPressedOk: () {
                    Navigator.pushNamed(
                      context,
                      Routes.editDeliveryProfileRoute,
                    );
                  },
                );
              }
              if (authData?.data?.countries == null ||
                  (authData?.data?.countries?.isEmpty ?? true)) {
                warningDialog(
                  context,
                  title: 'you_are_didnt_upload_countries'.tr(),
                  onPressedOk: () {
                    Navigator.pushNamed(
                      context,
                      Routes.editDeliveryProfileRoute,
                    );
                  },
                );
              }
            }*/
            changeLanguage();
          }
          isFirstTime = false;

          emit(GetAuthDataLoaded());
        },
      );
    } catch (e) {
      emit(GetAuthDataError());
    }
  }

  changeLanguage() async {
    emit(GetAuthDataLoading());
    final response = await api.changeLanguage();
    response.fold(
      (l) {
        emit(GetAuthDataError());
      },
      (r) {
        emit(GetAuthDataLoaded());
      },
    );
  }

  updateUserProfile(BuildContext context) async {
    try {
      AppWidget.createProgressDialog(context);
      emit(LoadingUpadteProfileState());
      final res = await api.updateUserProfile(
        name: updateNameController.text,
        address: updateAddressController.text,
        image: pickedProfileImage,
        exportCard: pickedUserCardProfileImage,
      );

      res.fold(
        (l) {
          errorGetBar(l.toString());
          emit(ErrorUpadteProfileState());
          Navigator.pop(context);
        },
        (r) {
          if (r.status == 200) {
            successGetBar(r.msg.toString());
            Navigator.pop(context);
            getAuthData(context);
            emit(LoadedUpadteProfileState());
          } else {
            errorGetBar(r.msg.toString());
            emit(ErrorUpadteProfileState());
          }
          Navigator.pop(context);
        },
      );
    } catch (e) {
      errorGetBar(e.toString());
      Navigator.pop(context);

      emit(ErrorUpadteProfileState());
    }
  }

  updateDeliveryProfile(BuildContext context) async {
    try {
      AppWidget.createProgressDialog(context);
      emit(LoadingUpadteProfileState());
      final res = await api.updateDeliveryProfile(
        name: updateNameController.text,
        image: pickedProfileImage,
        backDriverCard: pickedDeliveryBackImage,
        frontDriverCard: pickedDeliveryFrontImage,
        countries:
            context.read<AddNewTripCubit>().selectedCountriesAtEditProfile ??
            [],
        truckTypeId: null,
      );

      res.fold(
        (l) {
          errorGetBar(l.toString());
          emit(ErrorUpadteProfileState());
          Navigator.pop(context);
        },
        (r) {
          if (r.status == 200) {
            successGetBar(r.msg.toString());
            Navigator.pop(context);
            getAuthData(context);
            emit(LoadedUpadteProfileState());
          } else {
            errorGetBar(r.msg.toString());
            emit(ErrorUpadteProfileState());
          }
          Navigator.pop(context);
        },
      );
    } catch (e) {
      errorGetBar(e.toString());
      Navigator.pop(context);

      emit(ErrorUpadteProfileState());
    }
  }
}
