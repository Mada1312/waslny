import 'dart:developer';

import '../../../../../core/exports.dart';
import '../model/create_chat_room.dart';
import '../model/room_model.dart';

class ChatRepo {
  BaseApiConsumer dio;
  ChatRepo(this.dio);

//! :: chat/getChatRooms
  Future<Either<Failure, ChatRoomModel>> getChatRooms() async {
    try {
      final response = await dio.get(EndPoints.getChatRoomsUrl);
      log('Get Chat Rooms Response: ${response.toString()}');
      return Right(ChatRoomModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, MainCreateChatRoomModel>> createChatRoom(
      {String? shipmentId, String? driverId}) async {
    try {
      final response = await dio.get(EndPoints.createChatRoomUrl,
          queryParameters: {"shipment_id": shipmentId, "driver_id": driverId});

      return Right(MainCreateChatRoomModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, MainCreateChatRoomModel>> sendMessageNotification({
    String? message,
    String? roomToken,
    String? userId,
  }) async {
    try {
      final response = await dio.post(
        EndPoints.sendMessageNotificationUrl,
        body: {
          "message": message,
          "room_token": roomToken,
          "user_id": userId,
        },
      );

      return Right(MainCreateChatRoomModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
  // Future<Either<Failure, DefaultMainModel>> sendMessage(
  //     {String? chatId, String? message, File? file}) async {
  //   try {
  //     log('"file"${file?.path ?? ''}');
  //     final response = await dio
  //         .post(EndPoints.sendMessageUrl, formDataIsEnabled: true, body: {
  //       "chat_id": chatId,
  //       "message": message,
  //       if (file != null)
  //         "file": MultipartFile.fromFileSync(file.path, filename: file.path),
  //     });
  //     return Right(DefaultMainModel.fromJson(response));
  //   } on ServerException {
  //     return Left(ServerFailure());
  //   }
  // }
}
