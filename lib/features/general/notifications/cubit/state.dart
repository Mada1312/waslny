abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class FailureGetNotificationsState extends NotificationsState {}

class LoadingGetNotificationsState extends NotificationsState {}

class SuccessGetNotificationsState extends NotificationsState {}
class LoadingMarkAsSeenState extends NotificationsState {}
class FailureMarkAsSeenState extends NotificationsState {}
class SuccessMarkAsSeenState extends NotificationsState {}
