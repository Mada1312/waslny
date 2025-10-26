import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/exports.dart';
import '../../cubit/chat_cubit.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({
    super.key,
    required this.isSender,
    this.message,
    this.messageId,
    this.chatId,
    required this.time,
    this.image,
  });

  final bool isSender;
  final String? message;
  final String? image;
  final String? messageId;
  final String? chatId;
  final Timestamp time;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  void initState() {
    log(widget.image.toString());
    super.initState();
  }

  Widget buildMessageWithLinks(String message, TextStyle style) {
    final RegExp urlRegExp = RegExp(
      r'(https?:\/\/[^\s]+)',
      caseSensitive: false,
    );

    final List<TextSpan> spans = [];
    int start = 0;

    urlRegExp.allMatches(message).forEach((match) {
      if (match.start > start) {
        spans.add(
          TextSpan(text: message.substring(start, match.start), style: style),
        );
      }
      final String url = message.substring(match.start, match.end);
      spans.add(
        TextSpan(
          text: url,
          style: style.copyWith(color: AppColors.secondPrimary),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
        ),
      );
      start = match.end;
    });

    if (start < message.length) {
      spans.add(TextSpan(text: message.substring(start), style: style));
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final Uri? uri = Uri.tryParse(widget.image ?? '');
    print('555 ${uri!.host.isNotEmpty}');
    return InkWell(
      onLongPress: () {
        warningDialog(
          context,
          title: 'delete_message'.tr(),
          onPressedOk: () {
            context.read<ChatCubit>().deleteMessage(
              chatId: widget.chatId ?? '',
              messageId: widget.messageId ?? '',
            );
          },
        );
      },
      child: SizedBox(
        child: Align(
          alignment: widget.isSender
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: widget.isSender
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              (uri.host.isNotEmpty)
                  ? ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 1.4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [CachedNetworkImage(imageUrl: widget.image!)],
                      ),
                    )
                  : widget.message == null
                  ? Container()
                  : ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 1.4,
                      ),
                      child: Container(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        margin: EdgeInsets.symmetric(vertical: 5.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: widget.isSender
                              ? AppColors.secondPrimary
                              : AppColors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.sp),
                            bottomRight: Radius.circular(10.sp),
                            topLeft: widget.isSender
                                ? Radius.circular(10.sp)
                                : Radius.zero,
                            topRight: widget.isSender
                                ? Radius.zero
                                : Radius.circular(10.sp),
                          ),
                        ),
                        child: buildMessageWithLinks(
                          widget.message ?? '',
                          getRegularStyle(
                            fontSize: 14.sp,
                            color: widget.isSender
                                ? AppColors.white
                                : AppColors.secondPrimary,
                          ),
                        ),
                      ),
                    ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  extractTimeFromTimestamp(widget.time),
                  style: getRegularStyle(
                    fontSize: 12.sp,
                    color: AppColors.gray,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
