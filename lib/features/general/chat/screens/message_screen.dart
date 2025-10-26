import 'dart:developer';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/notification_services/notification_service.dart';
import 'package:waslny/core/widgets/network_image.dart';
import 'package:waslny/features/general/auth/cubit/cubit.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import 'widgets/chat_bubble_widget.dart';

class MainUserAndRoomChatModel {
  String? driverId;
  String? receiverId;
  String? tripId;
  String? chatId;
  String? title;
  bool? isDriver;
  bool? isNotification;
  MainUserAndRoomChatModel({
    this.driverId,
    this.receiverId,
    this.tripId,
    this.chatId,
    this.title,
    this.isDriver,
    this.isNotification = false,
  });
}

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key, required this.model});
  final MainUserAndRoomChatModel model;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  void initState() {
    super.initState();
    MessageStateManager().enterChatRoom("0");
    // MessageStateManager().enterChatRoom(widget.model.chatId ?? '');
    log('999999999 ${widget.model.chatId}');
    log('8888888888 ${widget.model.driverId.toString()}');
    log('7777777777 ${widget.model.tripId.toString()}');
    if (widget.model.chatId != null) {
      log('999999999 8888888888 ${widget.model.chatId}');

      context.read<ChatCubit>().listenForMessages(widget.model.chatId ?? '');
    } else {
      context.read<ChatCubit>().createChatRoom(
        driverId: widget.model.driverId ?? '',
        tripId: widget.model.tripId,
      );
    }
  }

  @override
  dispose() {
    super.dispose();
    MessageStateManager().leaveChatRoom('0');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        var cubit = context.read<ChatCubit>();
        return WillPopScope(
          onWillPop: () async {
            if (widget.model.isNotification == true) {
              Navigator.pushReplacementNamed(
                context,
                Routes.mainRoute,
                arguments: widget.model.isDriver == true,
              );
            } else {
              Navigator.pop(context);
            }
            return false;
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: AppColors.white, // your custom color
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.dark,
            ),
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: true,

                // appBar: customAppBar(
                //   context,
                //   title: widget.model.title ?? '',
                //   leading: IconButton(
                //     icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
                //     onPressed: () {
                //       MessageStateManager().isInChatRoom("1");
                //       if (widget.model.isNotification == true) {
                //         Navigator.pushReplacementNamed(
                //           context,
                //           Routes.mainRoute,
                //           arguments: widget.model.isDriver == true,
                //         );
                //       } else {
                //         Navigator.pop(context);
                //       }
                //     },
                //   ),
                // ),
                body:
                    (state is LoadingGetNewMessagteState ||
                        state is LoadingCreateChatRoomState)
                    ? Center(child: CustomLoadingIndicator())
                    : Container(
                        color: AppColors.unSeen,
                        child: Stack(
                          children: [
                            Image.asset(
                              ImageAssets.onBoardingOverlay,
                              fit: BoxFit.cover,
                              height: getHeightSize(context),
                              width: double.infinity,
                            ),
                            Column(
                              children: [
                                CustomChatHeader(
                                  isDriver: widget.model.isDriver ?? false,
                                  isNotification:
                                      widget.model.isNotification ?? false,
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    controller: cubit.scrollController,
                                    itemCount: cubit.messages.length,
                                    reverse: true,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 10.h,
                                    ),
                                    itemBuilder: (context, index) {
                                      var item = cubit.messages[index];
                                      return ChatBubble(
                                        chatId: item.chatId ?? '',
                                        messageId: item.id,
                                        isSender:
                                            ((context
                                                .read<LoginCubit>()
                                                .authData
                                                ?.data
                                                ?.id
                                                .toString() ==
                                            item.senderId.toString())),
                                        // image: item.fileUrl,
                                        message: item.bodyMessage ?? '',
                                        time: item.time!,
                                      );
                                    },
                                  ),
                                  // : Container(),
                                ),
                                // Input Field
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.w,
                                              vertical: 8.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(30.sp),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    _showBottomSheet(
                                                      context,
                                                      cubit,
                                                    );
                                                  },
                                                  icon: Icon(
                                                    Icons
                                                        .emoji_emotions_outlined,
                                                    color: AppColors.gray,
                                                    size: 24.sp,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: TextField(
                                                    onSubmitted: (value) {
                                                      cubit.sendMessage(
                                                        receiverId: widget
                                                            .model
                                                            .receiverId,

                                                        chatId:
                                                            widget
                                                                .model
                                                                .chatId ??
                                                            cubit
                                                                .createChatRoomModel
                                                                ?.data
                                                                ?.roomToken ??
                                                            '',
                                                      );
                                                    },
                                                    controller:
                                                        cubit.messageController,
                                                    decoration: InputDecoration(
                                                      hintText: "write_msg"
                                                          .tr(),
                                                      hintStyle: TextStyle(
                                                        color: AppColors.gray,
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 5.w,
                                                            vertical: 5.h,
                                                          ),
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20.sp,
                                                            ),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                      filled: true,
                                                      fillColor: AppColors.gray
                                                          .withOpacity(0.1),
                                                    ),
                                                  ),
                                                ),

                                                // IconButton(
                                                //   onPressed: () {
                                                //     showModalBottomSheet(
                                                //       isScrollControlled: true,
                                                //       context: context,
                                                //       enableDrag: true,
                                                //       builder: (context) {
                                                //         return Container(
                                                //           width: double.infinity,
                                                //           child: Column(
                                                //             mainAxisSize: MainAxisSize.min,
                                                //             children: [
                                                //               TextButton(
                                                //                   onPressed: () {
                                                //                     cubit.pickImage(
                                                //                       context,
                                                //                       isGallery: false,
                                                //                       chatId: widget.model.chatId ??
                                                //                           cubit.createChatRoomModel
                                                //                               ?.data?.uuid ??
                                                //                           '',
                                                //                     );
                                                //                   },
                                                //                   child: Text('Camera')),
                                                //               TextButton(
                                                //                   onPressed: () {
                                                //                     cubit.pickImage(
                                                //                       context,
                                                //                       isGallery: true,
                                                //                       chatId: widget.model.chatId ??
                                                //                           cubit.createChatRoomModel
                                                //                               ?.data?.uuid ??
                                                //                           '',
                                                //                     );
                                                //                   },
                                                //                   child: Text('Gallary')),
                                                //             ],
                                                //           ),
                                                //         );
                                                //       },
                                                //     );
                                                //   },
                                                //   icon: Padding(
                                                //     padding: const EdgeInsets.all(4.0),
                                                //     child: SvgPicture.asset(
                                                //       ImageAssets.attachIcon,
                                                //       color: AppColors.gray,
                                                //     ),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        GestureDetector(
                                          onTap:
                                              (state
                                                      is LoadingCreateChatRoomState ||
                                                  state
                                                      is LoadingCreate2ChatRoomState)
                                              ? () {}
                                              : () {
                                                  if (cubit
                                                      .messageController
                                                      .text
                                                      .isNotEmpty) {
                                                    cubit.sendMessage(
                                                      receiverId: widget
                                                          .model
                                                          .receiverId,
                                                      chatId:
                                                          widget.model.chatId ??
                                                          cubit
                                                              .createChatRoomModel
                                                              ?.data
                                                              ?.roomToken ??
                                                          '',
                                                    );
                                                  }
                                                },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primary,
                                            ),
                                            padding: EdgeInsets.all(22.sp),
                                            child: SvgPicture.asset(
                                              AppIcons.sendIcon,
                                              width: 24.w,
                                              height: 24.h,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, ChatCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to adjust its height
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              context,
            ).viewInsets.bottom, // Adjust for keyboard
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Ensures the column takes minimal space
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the bottom sheet
                      },
                      icon: Icon(
                        Icons.close,
                        color: AppColors.gray,
                        size: 24.sp,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: cubit.messageController,
                        decoration: InputDecoration(
                          hintText: "write_msg".tr(),
                          hintStyle: TextStyle(color: AppColors.gray),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 5.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.sp),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.gray.withOpacity(0.1),
                        ),
                        onSubmitted: (value) {
                          cubit.sendMessage(
                            receiverId: widget.model.receiverId,
                            chatId:
                                widget.model.chatId ??
                                cubit.createChatRoomModel?.data?.roomToken ??
                                '',
                          );
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        log(
                          '0000 : ${widget.model.chatId ?? cubit.createChatRoomModel?.data?.roomToken ?? ''}',
                        );
                        cubit.sendMessage(
                          receiverId: widget.model.receiverId,
                          chatId:
                              widget.model.chatId ??
                              cubit.createChatRoomModel?.data?.roomToken ??
                              '',
                        );
                      },
                      icon: SvgPicture.asset(AppIcons.sendIcon),
                    ),
                  ],
                ),
              ),

              Offstage(
                offstage: cubit.isEmojiVisible,
                child: SizedBox(
                  height: 300.h, // Adjust the height as needed
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      cubit.messageController.text += emoji.emoji;
                    },
                    textEditingController: cubit.messageController,
                    config: Config(
                      bottomActionBarConfig: BottomActionBarConfig(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              // TextField inside the bottom sheet
            ],
          ),
        );
      },
    );
  }
}

class CustomChatHeader extends StatelessWidget {
  const CustomChatHeader({
    super.key,
    required this.isDriver,
    required this.isNotification,
  });
  final bool isDriver;
  final bool isNotification;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.white,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.unSeen,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.sp),
                topRight: Radius.circular(30.sp),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: 25.sp,
                    color: AppColors.secondPrimary,
                  ),
                  onPressed: () {
                    MessageStateManager().isInChatRoom("1");
                    if (isNotification == true) {
                      Navigator.pushReplacementNamed(
                        context,
                        Routes.mainRoute,
                        arguments: isDriver == true,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),

                // SizedBox(width: 10.w),
                Container(
                  padding: EdgeInsets.all(4.sp),
                  decoration: BoxDecoration(
                    color: AppColors.secondPrimary,
                    borderRadius: BorderRadius.circular(1000),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: CustomNetworkImage(
                    image:
                        "https://images.ctfassets.net/xjcz23wx147q/iegram9XLv7h3GemB5vUR/0345811de2da23fafc79bd00b8e5f1c6/Max_Rehkopf_200x200.jpeg",
                    isUser: true,
                    height: 50.sp,
                    width: 50.sp,
                    borderRadius: 1000,
                  ),
                ),
                12.horizontalSpace,
                Expanded(child: Text("Max Rehkopf", style: getBoldStyle())),
              ],
            ),
          ),
        ),
        Divider(thickness: 2.h, color: AppColors.white),
        10.verticalSpace,
        isDriver
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: CustomButton(
                        title: "accept".tr(),
                        onPressed: () {},
                      ),
                    ),
                    10.w.horizontalSpace,
                    Flexible(
                      flex: 1,
                      child: CustomButton(
                        title: "arrived".tr(),
                        btnColor: AppColors.secondPrimary,
                        textColor: AppColors.primary,
                        onPressed: () {
                          // warningDialog(
                          //   context,
                          //   title: "are_you_sure_you_want_to_reject_trip"
                          //       .tr(),
                          //   onPressedOk: () {
                          //     context.read<DriverHomeCubit>().cancleTrip(
                          //       tripId: trip?.id ?? 0,
                          //       context: context,
                          //     );
                          //   },
                          // );
                        },
                      ),
                    ),
                    10.w.horizontalSpace,
                    Flexible(
                      flex: 1,
                      child: CustomButton(
                        title: "another_trip".tr(),
                        btnColor: AppColors.secondPrimary,
                        textColor: AppColors.primary,
                        onPressed: () {
                          // warningDialog(
                          //   context,
                          //   title: "are_you_sure_you_want_to_reject_trip"
                          //       .tr(),
                          //   onPressedOk: () {
                          //     context.read<DriverHomeCubit>().cancleTrip(
                          //       tripId: trip?.id ?? 0,
                          //       context: context,
                          //     );
                          //   },
                          // );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: CustomButton(
                        title: "accept_trip".tr(),
                        onPressed: () {},
                      ),
                    ),
                    10.w.horizontalSpace,
                    Flexible(
                      flex: 2,
                      child: CustomButton(
                        title: "change_captain".tr(),
                        btnColor: AppColors.secondPrimary,
                        textColor: AppColors.primary,
                        onPressed: () {
                          // warningDialog(
                          //   context,
                          //   title: "are_you_sure_you_want_to_reject_trip"
                          //       .tr(),
                          //   onPressedOk: () {
                          //     context.read<DriverHomeCubit>().cancleTrip(
                          //       tripId: trip?.id ?? 0,
                          //       context: context,
                          //     );
                          //   },
                          // );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}
