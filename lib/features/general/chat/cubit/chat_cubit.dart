// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/preferences/preferences.dart';
import 'package:waslny/features/general/chat/cubit/chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:waslny/features/general/chat/data/model/get_trips_model.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';

import '../../../driver/home/cubit/cubit.dart';
import '../data/model/create_chat_room.dart';
import '../data/model/message_model.dart';
import '../data/model/room_model.dart';
import '../data/repos/chat_repo.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this.chatRepo) : super(ChatInitial());
  ChatRepo chatRepo;

  //! Firebase

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController messageController = TextEditingController();
  List<MessageModel> messages = [];
  Future<String?> _getCurrentUserId() async {
    try {
      final userModel = await Preferences.instance.getUserModel();
      return userModel.data?.id?.toString();
    } catch (e) {
      log('Error getting current user ID: $e');
      return null;
    }
  } /*
  void listenForMessages(String chatId) {
    emit(LoadingGetNewMessagteState());
    _firestore
        .collection('rooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots()
        .listen((snapshot) {
          messages = snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.data()))
              .toList();
          log('messages length : ${messages.length}');
          emit(ChatLoaded(messages));
        });
  }
*/

  void listenForMessages(String chatId) {
    emit(LoadingGetNewMessagteState());
    _firestore
        .collection('rooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots()
        .listen((snapshot) {
          messages = snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.data()))
              .toList();
          log('messages length : ${messages.length}');
          emit(ChatLoaded(messages));
        })
        .onError((e) {
          log('Error listening to messages: $e');
          // يمكنك إصدار حالة خطأ هنا
        });
  }

  //!
  // --- 2. إرسال رسالة (تم تعديلها لإضافة حقل 'readBy') ---
  Future<void> sendMessage({
    required String chatId,
    required String? receiverId,
    bool isDriverArrived = false,
  }) async {
    final currentUserId = await _getCurrentUserId();

    if (currentUserId == null ||
        (messageController.text.isEmpty && !isDriverArrived)) {
      return;
    }

    try {
      // Create a new document reference
      final messageRef = _firestore
          .collection('rooms')
          .doc(chatId)
          .collection('messages')
          .doc();

      // Create message model
      final message = MessageModel(
        id: messageRef.id, // Set the ID explicitly
        bodyMessage: isDriverArrived
            ? "i_arrived".tr()
            : messageController.text,
        chatId: chatId,
        senderId: currentUserId,
        receiverId: receiverId,
        time: Timestamp.now(),
        // 💡 التعديل: المرسل هو أول من قرأ الرسالة
        readBy: [currentUserId],
      );
      messageController.clear();

      // Save to Firestore
      await messageRef.set(message.toJson());

      // نفترض أن دالة الإشعارات تعمل بشكل صحيح
      // await sentNotification(...)
    } catch (e) {
      log('Error sending message: $e');
      emit(MessageErrorState());
    }
  }

  Stream<int> getUnreadMessagesCountStream(String roomId) {
    // 💡 نستخدم switchMap من rxdart للتعامل مع الـ Future قبل الـ Stream
    // يجب أن يكون الـ import موجودًا لكي يعمل الـ switchMap
    return Stream.fromFuture(_getCurrentUserId()).switchMap((currentUserId) {
      if (currentUserId == null) {
        return Stream.value(0); // لو مفيش ID، رجع صفر
      }

      return _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .snapshots()
          .map((snapshot) {
            int unreadCount = 0;
            for (var doc in snapshot.docs) {
              final data = doc.data();
              final List<String> readBy = List<String>.from(
                data['readBy'] ?? [],
              );

              if (data['senderId'] != currentUserId &&
                  !readBy.contains(currentUserId)) {
                unreadCount++;
              }
            }
            return unreadCount;
          })
          .handleError((error) {
            log('Error listening to unread count for $roomId: $error');
            return 0;
          });
    });
  }

  // --- 4. الدالة التي تضع علامة "مقروءة" (عند فتح الشات) ---
  /// 💡 Method: تحديث حالة الرسائل غير المقروءة إلى "مقروءة"
  /// يتم استدعاؤها بمجرد فتح المستخدم لشاشة الشات
  Future<void> markMessagesAsRead(String chatId) async {
    final currentUserId = await _getCurrentUserId();
    if (currentUserId == null) return;

    final messagesRef = _firestore
        .collection('rooms')
        .doc(chatId)
        .collection('messages');

    try {
      // 1. نجيب الرسائل اللي مبعوته من طرف آخر (SenderId != CurrentUserId)
      final querySnapshot = await messagesRef
          .where('senderId', isNotEqualTo: currentUserId)
          .get();

      final batch = _firestore.batch();
      bool needsUpdate = false;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final List<String> readBy = List<String>.from(data['readBy'] ?? []);

        // لو الـ ID بتاعنا مش موجود في الـ readBy، نعمل تحديث
        if (!readBy.contains(currentUserId)) {
          // نستخدم FieldValue.arrayUnion عشان نضيف الـ ID بتاعنا
          batch.update(doc.reference, {
            'readBy': FieldValue.arrayUnion([currentUserId]),
          });
          needsUpdate = true;
        }
      }

      // 3. ننفذ الـ Batch لو فيه أي تحديثات
      if (needsUpdate) {
        await batch.commit();
        log(
          'Batch commit: Messages in $chatId marked as read by $currentUserId',
        );
      }
    } catch (e) {
      log('Error marking messages as read: $e');
    }
  }

  //////////!
  /* Future<void> sendMessage({
    required String chatId,
    required String? receiverId,
    bool isDriverArrived = false,
  }) async {
    if (messageController.text.isEmpty && !isDriverArrived) {
      return;
    }
    try {
      final userModel = await Preferences.instance.getUserModel();
      // Create a new document reference
      final messageRef = _firestore
          .collection('rooms')
          .doc(chatId)
          .collection('messages')
          .doc();

      // Create message model
      final message = MessageModel(
        id: messageRef.id, // Set the ID explicitly
        bodyMessage: isDriverArrived
            ? "i_arrived".tr()
            : messageController.text,
        chatId: chatId,
        senderId: userModel.data?.id?.toString(),
        receiverId: receiverId,
        time: Timestamp.now(),
      );
      messageController.clear();

      // Save to Firestore
      await messageRef.set(message.toJson());
      await sentNotification(
        message: message.bodyMessage ?? '',
        chatId: chatId,
        receiverId: receiverId,
      );
    } catch (e) {
      log('Error sending message: $e');
      emit(MessageErrorState());
    }
  }
*/
  sentNotification({
    required String message,
    required String chatId,
    required String? receiverId,
  }) async {
    final res = await chatRepo.sendMessageNotification(
      message: message,
      roomToken: chatId,
      userId: receiverId,
    );

    res.fold(
      (l) {
        log('Error sending message notification: ${l.toString()}');
      },
      (r) {
        if (kDebugMode) {
          if (r.status == 200) {
            successGetBar(r.msg);
          } else {}
        }
        log('Message notification sent successfully: ${r.msg}');
      },
    );
  }
  // Future<void> sendMessage({
  //   required String chatId,
  //   required String? receiverId,
  // }) async {
  //   try {
  //     final userModel = await Preferences.instance.getUserModel();
  //     // Create a new document reference
  //     final messageRef = _firestore
  //         .collection('rooms')
  //         .doc(chatId)
  //         .collection('messages')
  //         .doc();

  //     // Create message model
  //     final message = MessageModel(
  //       id: messageRef.id, // Set the ID explicitly
  //       bodyMessage: messageController.text,
  //       chatId: chatId,
  //       senderId: userModel.data?.id?.toString(),
  //       receiverId: receiverId,
  //       time: Timestamp.now(),
  //     );

  //     // Save to Firestore
  //     await messageRef.set(message.toJson());

  //     messageController.clear();
  //   } catch (e) {
  //     log('Error sending message: $e');
  //     emit(MessageErrorState());
  //   }
  // }

  bool isEmojiVisible = false;
  void toggleEmojiKeyboard() {
    isEmojiVisible = !isEmojiVisible;
    emit(OntoggleEmojiSocietyState());
  }

  ScrollController scrollController = ScrollController();

  void listenForMessagesWithScroll() {
    scrollController.animateTo(
      0,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection('rooms')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();

      // Update local state
      messages.removeWhere((message) => message.id == messageId);
      emit(ChatLoaded(messages));
    } catch (e) {
      log('Error deleting message: $e');
      emit(MessageErrorState());
    }
  }
  //////////!

  MainCreateChatRoomModel? createChatRoomModel;

  void createChatRoom({String? driverId, String? tripId}) async {
    emit(LoadingCreateChatRoomState());
    log('xxxxxxxxx ${driverId}');
    log('xxxxxxxxx ${tripId}');
    final res = await chatRepo.createChatRoom(
      driverId: driverId,
      tripId: tripId,
    );

    res.fold(
      (l) {
        emit(ErrorCreateChatRoomState());
      },
      (r) async {
        messages = [];

        listenForMessages(r.data?.roomToken ?? '');
        await markMessagesAsRead(r.data?.roomToken ?? '');

        createChatRoomModel = r;
        emit(LoadedCreateChatRoomState());
      },
    );
  }

  ChatRoomModel? chatRoomModel;
  void getChatRooms() async {
    emit(LoadingCreateChatRoomState());
    final res = await chatRepo.getChatRooms();
    res.fold(
      (l) {
        emit(ErrorCreateChatRoomState());
      },
      (r) {
        chatRoomModel = r;
        emit(LoadedCreateChatRoomState());
      },
    );
  }

  Future<void> updateTripStatus({
    required TripStep step,
    required bool isDriver,
    String? receiverId,
    String? chatId,
    required BuildContext context,
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
      final response = await chatRepo.updateTripStatus(
        id: getTripDetailsModel?.data?.id ?? 0,
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
            if (isDriver) {
              if (step == TripStep.isDriverAnotherTrip) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.mainRoute,
                  (route) => false,
                  arguments: true,
                );
                return;
              }
              getTripDetails(
                id: getTripDetailsModel?.data?.id.toString() ?? '',
              );
              DriverHomeCubit driverHomeCubit =
                  BlocProvider.of<DriverHomeCubit>(context);
              driverHomeCubit.getDriverHomeData(context);
            } else {
              if (step == TripStep.isUserChangeCaptain) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.mainRoute,
                  (route) => false,
                  arguments: false,
                );
                return;
              }
              getTripDetails(
                id: getTripDetailsModel?.data?.id.toString() ?? '',
              );
              UserHomeCubit homeCubit = BlocProvider.of<UserHomeCubit>(context);
              homeCubit.getHome(context);
            }
            if (step == TripStep.isDriverArrived) {
              sendMessage(
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

  Future<void> startTrip({
    required int tripId,
    required BuildContext context,
  }) async {
    AppWidget.createProgressDialog(context, msg: "...");
    emit(UpdateTripStatusLoadingState());
    try {
      final response = await chatRepo.startTrip(id: tripId);
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
            getTripDetails(id: tripId.toString());
            context.read<DriverHomeCubit>().getDriverHomeData(context);
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
      final response = await chatRepo.endTrip(id: tripId);
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

  GetTripDetailsModel? getTripDetailsModel;
  Future<void> getTripDetails({required String id}) async {
    getTripDetailsModel = null;
    emit(GetTripStatusLoadingState());
    try {
      final response = await chatRepo.getTripDetails(id: id);
      response.fold(
        (failure) {
          emit(GetTripStatusErrorState());
        },
        (response) {
          if (response.status == 200 || response.status == 201) {
            emit(GetTripStatusSuccessState());
            getTripDetailsModel = response;
          } else {
            errorGetBar(response.msg ?? "Failed to get trip details");
            emit(GetTripStatusErrorState());
          }
        },
      );
    } catch (e) {
      log("Error in cancelShipment: $e");
      emit(GetTripStatusErrorState());
    }
  }
}

String extractTimeFromTimestamp(Timestamp timestamp) {
  // Convert Firestore Timestamp to DateTime
  DateTime dateTime = timestamp.toDate();

  // Create formatter for local timezone (or specify specific zone)
  DateFormat outputFormat = DateFormat('h:mm a');

  // Return formatted time string
  return outputFormat.format(dateTime);
}

// create enum with trip steps is_user_accept|is_driver_accept|is_driver_arrived|is_user_start_trip|is_driver_start_trip|is_user_change_captain|is_driver_another_trip
enum TripStep {
  isUserAccept,
  isDriverAccept,
  isDriverArrived,
  isUserStartTrip,
  isDriverStartTrip,
  isUserChangeCaptain,
  isDriverAnotherTrip,
}

extension TripStepExtension on TripStep {
  String get stepValue {
    switch (this) {
      case TripStep.isUserAccept:
        return 'is_user_accept';
      case TripStep.isDriverAccept:
        return 'is_driver_accept';
      case TripStep.isDriverArrived:
        return 'is_driver_arrived';
      case TripStep.isUserStartTrip:
        return 'is_user_start_trip';
      case TripStep.isDriverStartTrip:
        return 'is_driver_start_trip';
      case TripStep.isUserChangeCaptain:
        return 'is_user_change_captain';
      case TripStep.isDriverAnotherTrip:
        return 'is_driver_another_trip';
    }
  }
}
