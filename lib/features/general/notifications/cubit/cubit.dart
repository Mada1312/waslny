import 'package:waslny/core/exports.dart';
import 'package:waslny/features/general/notifications/data/models/get_notifications_model.dart';

import '../data/repo.dart';
import 'state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this.api) : super(NotificationsInitial());

  NotificationsRepo api;
  GetNotificationsModel? notificationsModel;
  getNotifications() async {
    emit(LoadingGetNotificationsState());
    final res = await api.getNotifications();
    res.fold((l) {
      emit(FailureGetNotificationsState());
    }, (r) {
      notificationsModel = r;

      emit(SuccessGetNotificationsState());
    });
  }

  // markAsSeen(BuildContext context, {required String notificationId}) async {
  //   emit(LoadingMarkAsSeenState());
  //   final res = await api.markAsSeen(notificationId: notificationId);
  //   res.fold((l) {
  //     emit(FailureMarkAsSeenState());
  //   }, (r) {
  //     if (r.status == 200 || r.status == 201) {
  //       getNotifications();
  //       if (context.read<ProfileCubit>().loginModel.data != null) {
  //         context.read<ProfileCubit>().loginModel.data!.notificationCount =
  //             context.read<ProfileCubit>().loginModel.data!.notificationCount! -
  //                 1;
  //       }
  //       context.read<ProfileCubit>().emit(GetAccountSuccess());
  //     }
  //     emit(SuccessMarkAsSeenState());
  //   });
  // }
}
