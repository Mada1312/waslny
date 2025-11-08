// import 'package:waslny/core/exports.dart';
// import 'package:waslny/features/general/notifications/data/models/get_notifications_model.dart';
// import '../cubit/cubit.dart';
// import '../cubit/state.dart';
// import 'widgets/notification_widget.dart';

// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({super.key, required this.isDriver});
//   final bool isDriver;

//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends State<NotificationsScreen> {
//   @override
//   void initState() {
//     context.read<NotificationsCubit>().getNotifications();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<NotificationsCubit, NotificationsState>(
//       builder: (context, state) {
//         var cubit = context.read<NotificationsCubit>();

//         return Scaffold(
//           appBar: customAppBar(
//             context,
//             title: 'notifications'.tr(),
//             leading: SizedBox(),
//           ),
//           body: Center(
//             child: state is FailureGetNotificationsState
//                 ? CustomNoDataWidget(
//                     message: 'error_happened'.tr(),
//                     onTap: () {
//                       cubit.getNotifications();
//                     },
//                   )
//                 : state is LoadingGetNotificationsState ||
//                       cubit.notificationsModel?.data == null
//                 ? const Center(child: CustomLoadingIndicator())
//                 : cubit.notificationsModel!.data!.isEmpty
//                 ? CustomNoDataWidget(
//                     message: 'no_notifications'.tr(),
//                     onTap: () {
//                       cubit.getNotifications();
//                     },
//                   )
//                 : RefreshIndicator(
//                     color: AppColors.primary,

//                     onRefresh: () async {
//                       await cubit.getNotifications();
//                     },
//                     child: NotificationsListView(
//                       notifications: cubit.notificationsModel!.data!,
//                       isDriver: widget.isDriver,
//                     ),
//                   ),
//           ),
//         );
//       },
//     );
//   }
// }
