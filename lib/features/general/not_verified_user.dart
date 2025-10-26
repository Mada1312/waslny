import 'dart:async';
import 'dart:developer';

import 'package:waslny/core/exports.dart';
import 'package:waslny/core/preferences/preferences.dart';
import 'package:waslny/core/utils/app_colors.dart';
import 'package:waslny/features/driver/home/cubit/cubit.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/general/profile/cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotVerifiedUserScreen extends StatefulWidget {
  const NotVerifiedUserScreen({super.key, required this.isDriver});
  final bool isDriver;
  @override
  State<NotVerifiedUserScreen> createState() => _NotVerifiedUserScreenState();
}

class _NotVerifiedUserScreenState extends State<NotVerifiedUserScreen> {
  Future<void> _launchWhatsApp(BuildContext context) async {
    Future<void> _launch(String? phone) async {
      if (phone == null || phone.isEmpty) {
        throw 'Phone number is not available';
      }
      final message = "Hello i want be partner in waslny app";
      final Uri whatsappUri = Uri(
        scheme: 'https',
        host: 'wa.me',
        path: phone,
        queryParameters: {'text': message},
      );

      if (!await launchUrl(whatsappUri)) {
        throw 'Could not launch $whatsappUri';
      }
    }

    final profileCubit = context.read<ProfileCubit>();
    if (profileCubit.settings != null) {
      await _launch(profileCubit.settings?.data?.waapiPhone);
    } else {
      await profileCubit.getSettings(context);
      await _launch(profileCubit.settings?.data?.waapiPhone);
    }
  }

  Future<void> _onWhatsAppClick(BuildContext context) async {
    if (widget.isDriver) {
      await context.read<DriverHomeCubit>().getDriverHomeData(
        context,
        isVerify: true,
      );
      if (context.read<DriverHomeCubit>().homeModel?.data?.isWebhookVerified ==
          0) {
        await _launchWhatsApp(context);
      }
    } else {
      await context.read<UserHomeCubit>().getHome(context, isVerify: true);
      if (context.read<UserHomeCubit>().homeModel?.data?.isWebhookVerified ==
          0) {
        await _launchWhatsApp(context);
      }
    }
  }

  bool _isCooldown = false;
  Timer? _cooldownTimer;
  Timer? _countdownTimer;
  int _secondsRemaining = 0;
  String? phoneNumber;
  @override
  void initState() {
    super.initState();
    _getUserPhone();
  }

  _getUserPhone() async {
    LoginModel? userModel = await Preferences.instance.getUserModel();
    setState(() {
      phoneNumber = userModel.data?.phone.toString() ?? "";
    });
    (() {});
    log('User phone number: $phoneNumber');
  }

  void _startCooldown() {
    setState(() {
      _isCooldown = true;
      _secondsRemaining = 60; // 30 seconds countdown
    });

    _countdownTimer?.cancel(); // Cancel any existing timer

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        }
        if (_secondsRemaining == 0) {
          _isCooldown = false;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.secondPrimary,
                    size: 100,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'تأكيد رقم الهاتف',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (phoneNumber != null) const SizedBox(height: 8),
                  if (phoneNumber != null)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        "+" + (phoneNumber ?? ""),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'سيتم التحقق خلال دقيقة إلى 3 دقائق، برجاء الانتظار أو إعادة المحاولة',
                    style: TextStyle(fontSize: 20, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    isDisabled: _isCooldown,
                    title: _isCooldown
                        ? 'يرجى الانتظار ($_secondsRemaining ثواني)'
                        : 'إعادة المحاولة',
                    padding: EdgeInsets.all(8),
                    radius: 10.r,
                    onPressed: _isCooldown
                        ? null
                        : () async {
                            setState(() {
                              _isCooldown = true;
                            });

                            await _onWhatsAppClick(context);

                            _startCooldown();
                          },
                    width: 200.w,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
