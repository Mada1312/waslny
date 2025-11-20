import 'package:cloud_firestore/cloud_firestore.dart';

// class MessageModel {
//   String? id; // Added document ID field
//   String? bodyMessage;
//   String? chatId;
//   String? receiverId;
//   String? senderId;
//   Timestamp? time;

//   MessageModel({
//     this.id,
//     this.bodyMessage,
//     this.chatId,
//     this.receiverId,
//     this.senderId,
//     this.time,
//   });

//   factory MessageModel.fromJson(Map<String, dynamic> json) {
//     return MessageModel(
//       id: json['id'] as String?, // Added ID
//       bodyMessage: json['bodyMessage'] as String?,
//       chatId: json['chatId'] as String?,
//       receiverId: json['receiverId'] as String?,
//       senderId: json['senderId'] as String?,
//       time: json['time'] as Timestamp?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id, // Added ID
//       'bodyMessage': bodyMessage,
//       'chatId': chatId,
//       'receiverId': receiverId,
//       'senderId': senderId,
//       'time': time ?? Timestamp.now(),
//     };
//   }
// }

// في ملف MessageModel
class MessageModel {
  // ... الحقول الحالية
  final String? id;
  final String? bodyMessage;
  final String? chatId;
  final String? senderId;
  final String? receiverId;
  final Timestamp? time;

  // 💡 الحقل الجديد: قائمة بمعرفات المستخدمين الذين قرأوا الرسالة
  final List<String> readBy; // **جديد**

  MessageModel({
    this.id,
    this.bodyMessage,
    this.chatId,
    this.senderId,
    this.receiverId,
    this.time,
    this.readBy = const [], // **جديد** - القيمة الافتراضية قائمة فارغة
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String?,
      bodyMessage: json['bodyMessage'] as String?,
      chatId: json['chatId'] as String?,
      senderId: json['senderId'] as String?,
      receiverId: json['receiverId'] as String?,
      time: json['time'] as Timestamp?,
      // **جديد**: قراءة الـ List من Firestore
      readBy:
          (json['readBy'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bodyMessage': bodyMessage,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'time': time,
      'readBy': readBy, // **جديد**
    };
  }
}
