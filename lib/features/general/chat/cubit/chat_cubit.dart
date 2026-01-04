// ignore_for_file: use_build_context_synchronously

import 'dart:async';
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController messageController = TextEditingController();
  List<MessageModel> messages = [];

  StreamSubscription? _messagesSubscription;

  Future<String?> _getCurrentUserId() async {
    try {
      final userModel = await Preferences.instance.getUserModel();
      return userModel.data?.id?.toString();
    } catch (e) {
      log('Error getting current user ID: $e');
      return null;
    }
  }

  /// 🟢 Guard function: التحقق من صحة chatId
  bool _isValidChatId(String? chatId) {
    return chatId != null && chatId.trim().isNotEmpty;
  }

  /// 🟢 استمع للرسائل مع حماية كاملة
  void listenForMessages(String? chatId) {
    if (!_isValidChatId(chatId)) {
      log('⚠️  listenForMessages skipped: invalid chatId = "$chatId"');
      emit(MessageErrorState());
      return;
    }

    emit(LoadingGetNewMessagteState());

    _messagesSubscription?.cancel();

    try {
      _messagesSubscription = _firestore
          .collection('rooms')
          .doc(chatId!)
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              try {
                messages = snapshot.docs
                    .map((doc) => MessageModel.fromJson(doc.data()))
                    .toList();
                log('✅ Messages loaded: ${messages.length}');
                emit(ChatLoaded(messages));
              } catch (e) {
                log('❌ Error processing messages: $e');
                emit(MessageErrorState());
              }
            },
            onError: (e) {
              log('❌ Error listening to messages: $e');
              emit(MessageErrorState());
            },
          );
    } catch (e) {
      log('❌ Error in listenForMessages: $e');
      emit(MessageErrorState());
    }
  }

  /// 🟢 إرسال الرسالة مع حماية كاملة
  Future<void> sendMessage({
    required String? chatId,
    required String? receiverId,
    bool isDriverArrived = false,
  }) async {
    if (!_isValidChatId(chatId)) {
      log('⚠️  sendMessage skipped: invalid chatId = "$chatId"');
      return;
    }

    final currentUserId = await _getCurrentUserId();

    if (currentUserId == null ||
        (messageController.text.isEmpty && !isDriverArrived)) {
      return;
    }

    try {
      final messageRef = _firestore
          .collection('rooms')
          .doc(chatId!)
          .collection('messages')
          .doc();

      final message = MessageModel(
        id: messageRef.id,
        bodyMessage: isDriverArrived
            ? "i_arrived".tr()
            : messageController.text,
        chatId: chatId,
        senderId: currentUserId,
        receiverId: receiverId,
        time: Timestamp.now(),
        readBy: [currentUserId],
      );
      messageController.clear();

      await messageRef.set(message.toJson());
      log('✅ Message sent with ID: ${messageRef.id}');

      unawaited(
        sentNotification(
          message: message.bodyMessage ?? '',
          chatId: chatId,
          receiverId: receiverId,
        ),
      );
    } catch (e) {
      log('❌ Error sending message: $e');
      emit(MessageErrorState());
    }
  }

  /// 🟢 عد الرسائل غير المقروءة مع حماية
  Stream<int> getUnreadMessagesCountStream(String? roomId) {
    if (!_isValidChatId(roomId)) {
      log('⚠️  getUnreadMessagesCountStream skipped: invalid roomId');
      return Stream.value(0);
    }

    return Stream.fromFuture(_getCurrentUserId()).switchMap((currentUserId) {
      if (currentUserId == null) {
        return Stream.value(0);
      }

      return _firestore
          .collection('rooms')
          .doc(roomId!)
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
            log('❌ Error listening to unread count for $roomId: $error');
            return 0;
          });
    });
  }

  /// 🟢 تحديث حالة الرسائل غير المقروءة مع حماية
  Future<void> markMessagesAsRead(String? chatId) async {
    if (!_isValidChatId(chatId)) {
      log('⚠️  markMessagesAsRead skipped: invalid chatId');
      return;
    }

    final currentUserId = await _getCurrentUserId();
    if (currentUserId == null) return;

    final messagesRef = _firestore
        .collection('rooms')
        .doc(chatId!)
        .collection('messages');

    try {
      final querySnapshot = await messagesRef
          .where('senderId', isNotEqualTo: currentUserId)
          .get();

      final batch = _firestore.batch();
      bool needsUpdate = false;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final List<String> readBy = List<String>.from(data['readBy'] ?? []);

        if (!readBy.contains(currentUserId)) {
          batch.update(doc.reference, {
            'readBy': FieldValue.arrayUnion([currentUserId]),
          });
          needsUpdate = true;
        }
      }

      if (needsUpdate) {
        await batch.commit();
        log('✅ Messages in $chatId marked as read by $currentUserId');
      }
    } catch (e) {
      log('❌ Error marking messages as read: $e');
    }
  }

  /// 🟢 إرسال الإشعارات
  Future<void> sentNotification({
    required String message,
    required String? chatId,
    required String? receiverId,
  }) async {
    if (!_isValidChatId(chatId)) {
      log('⚠️  sentNotification skipped: invalid chatId');
      return;
    }

    try {
      final res = await chatRepo.sendMessageNotification(
        message: message,
        roomToken: chatId!,
        userId: receiverId,
      );

      res.fold(
        (l) {
          log('❌ Error sending notification: $l');
        },
        (r) {
          if (r.status == 200) {
            log('✅ Notification sent: ${r.msg}');
          }
        },
      );
    } catch (e) {
      log('❌ Error in sentNotification: $e');
    }
  }

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
    required String? chatId,
    required String messageId,
  }) async {
    if (!_isValidChatId(chatId)) {
      log('⚠️  deleteMessage skipped: invalid chatId');
      return;
    }

    try {
      await _firestore
          .collection('rooms')
          .doc(chatId!)
          .collection('messages')
          .doc(messageId)
          .delete();

      messages.removeWhere((message) => message.id == messageId);
      emit(ChatLoaded(messages));
    } catch (e) {
      log('❌ Error deleting message: $e');
      emit(MessageErrorState());
    }
  }

  MainCreateChatRoomModel? createChatRoomModel;

  void createChatRoom({String? driverId, String? tripId}) async {
    emit(LoadingCreateChatRoomState());
    log('Creating chat room - DriverID: $driverId, TripID: $tripId');

    final res = await chatRepo.createChatRoom(
      driverId: driverId,
      tripId: tripId,
    );

    res.fold(
      (l) {
        log('❌ Error creating chat room: $l');
        emit(ErrorCreateChatRoomState());
      },
      (r) async {
        final token = r.data?.roomToken;
        if (!_isValidChatId(token)) {
          log('❌ createChatRoom failed: invalid roomToken');
          emit(ErrorCreateChatRoomState());
          return;
        }

        messages = [];
        listenForMessages(token);
        await markMessagesAsRead(token);

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
        log('❌ Error getting chat rooms: $l');
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
          log('❌ Error updating trip status: $failure');
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context);
          if (response.status == 200 || response.status == 201) {
            emit(UpdateTripStatusSuccessState());
            successGetBar(response.msg ?? "Trip status updated");

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
              if (_isValidChatId(chatId)) {
                unawaited(
                  sendMessage(
                    isDriverArrived: true,
                    chatId: chatId,
                    receiverId: receiverId,
                  ),
                );
              } else {
                log('⚠️  Skipping arrival message: invalid chatId = "$chatId"');
              }
            }
          } else {
            errorGetBar(response.msg ?? "Failed to update trip");
          }
        },
      );
    } catch (e) {
      log("❌ Error in updateTripStatus: $e");
      Navigator.pop(context);
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
          Navigator.pop(context);
          log('❌ Error starting trip: $failure');
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context);
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
      log("❌ Error in startTrip: $e");
      Navigator.pop(context);
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
          Navigator.pop(context);
          log('❌ Error ending trip: $failure');
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context);
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
      log("❌ Error in endTrip: $e");
      Navigator.pop(context);
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
          log('❌ Error getting trip details: $failure');
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
      log("❌ Error in getTripDetails: $e");
      emit(GetTripStatusErrorState());
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    messageController.dispose();
    scrollController.dispose();
    return super.close();
  }
}

String extractTimeFromTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  DateFormat outputFormat = DateFormat('h:mm a');
  return outputFormat.format(dateTime);
}

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
