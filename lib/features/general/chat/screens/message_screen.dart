import 'dart:developer';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/notification_services/notification_service.dart';
import 'package:waslny/features/general/auth/cubit/cubit.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import 'widgets/chat_bubble_widget.dart';

class MainUserAndRoomChatModel {
  String? driverId;
  String? tripId;
  String? chatId;
  String? title;
  bool? isDriver;
  bool? isNotification;
  MainUserAndRoomChatModel({
    this.driverId,
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
          child: SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: customAppBar(
                context,
                title: widget.model.title ?? '',
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
                  onPressed: () {
                    MessageStateManager().isInChatRoom("1");
                    if (widget.model.isNotification == true) {
                      Navigator.pushReplacementNamed(
                        context,
                        Routes.mainRoute,
                        arguments: widget.model.isDriver == true,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              body:
                  (state is LoadingGetNewMessagteState ||
                      state is LoadingCreateChatRoomState)
                  ? Center(child: CustomLoadingIndicator())
                  : Column(
                      children: [
                        // App Bar with Image

                        // Chat Messages Area
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
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border(
                              top: BorderSide(
                                color: AppColors.gray.withOpacity(0.5),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _showBottomSheet(context, cubit);
                                },
                                icon: Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: AppColors.gray,
                                  size: 24.sp,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  onSubmitted: (value) {
                                    cubit.sendMessage(
                                      receiverId: widget.model.driverId,
                                      chatId:
                                          widget.model.chatId ??
                                          cubit
                                              .createChatRoomModel
                                              ?.data
                                              ?.roomToken ??
                                          '',
                                    );
                                  },
                                  controller: cubit.messageController,
                                  decoration: InputDecoration(
                                    hintText: "write_msg".tr(),
                                    hintStyle: TextStyle(color: AppColors.gray),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 5.h,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        20.sp,
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.gray.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed:
                                    (state is LoadingCreateChatRoomState ||
                                        state is LoadingCreate2ChatRoomState)
                                    ? () {}
                                    : () {
                                        if (cubit
                                            .messageController
                                            .text
                                            .isNotEmpty) {
                                          cubit.sendMessage(
                                            receiverId: widget.model.driverId,
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
                                icon: SvgPicture.asset(AppIcons.sendIcon),
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
                      ],
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
                            receiverId: widget.model.driverId,
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
                          receiverId: widget.model.driverId,
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
