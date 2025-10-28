import '../data/model/message_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class SuccessAddNewMessagteState extends ChatState {}

class LoadingAddNewMessagteState extends ChatState {}

class LoadingGetNewMessagteState extends ChatState {}

class ChatLoaded extends ChatState {
  ChatLoaded(this.messages);

  List<MessageModel> messages;
}

class LoadingCreateChatRoomState extends ChatState {}

class LoadedCreateChatRoomState extends ChatState {}

class ErrorCreateChatRoomState extends ChatState {}

class Error2CreateChatRoomState extends ChatState {}

class LoadedCreate2ChatRoomState extends ChatState {}

class LoadingCreate2ChatRoomState extends ChatState {}

class OntoggleEmojiSocietyState extends ChatState {}

class FilePickCancelled extends ChatState {}

class UpdateProfileError extends ChatState {}

class UpdateProfileImagePicked extends ChatState {}

class MessageErrorState extends ChatState {}
class UpdateTripStatusLoadingState extends ChatState {}
class UpdateTripStatusSuccessState extends ChatState {}
class UpdateTripStatusErrorState extends ChatState {}

