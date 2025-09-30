import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? id; // Added document ID field
  String? bodyMessage;
  String? chatId;
  String? receiverId;
  String? senderId;
  Timestamp? time;

  MessageModel({
    this.id,
    this.bodyMessage,
    this.chatId,
    this.receiverId,
    this.senderId,
    this.time,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String?, // Added ID
      bodyMessage: json['bodyMessage'] as String?,
      chatId: json['chatId'] as String?,
      receiverId: json['receiverId'] as String?,
      senderId: json['senderId'] as String?,
      time: json['time'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Added ID
      'bodyMessage': bodyMessage,
      'chatId': chatId,
      'receiverId': receiverId,
      'senderId': senderId,
      'time': time ?? Timestamp.now(),
    };
  }
}
