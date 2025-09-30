import 'package:waslny/features/general/auth/cubit/cubit.dart';
import 'package:waslny/features/general/profile/cubit/cubit.dart';

import '../../../../core/exports.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import 'message_screen.dart';

class AllRoomScreen extends StatefulWidget {
  const AllRoomScreen({super.key});

  @override
  State<AllRoomScreen> createState() => _AllRoomScreenState();
}

class _AllRoomScreenState extends State<AllRoomScreen> {
  @override
  void initState() {
    context.read<ChatCubit>().getChatRooms();
    print('AllRoomScreen');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        var cubit = context.read<ChatCubit>();
        return Scaffold(
          appBar: customAppBar(context,
              title: 'messages'.tr(), leading: SizedBox()),
          body: (state is LoadingCreateChatRoomState)
              ? const Center(child: CustomLoadingIndicator())
              : (state is ErrorCreateChatRoomState)
                  ? const Center(child: CircularProgressIndicator())
                  : cubit.chatRoomModel?.data?.length == 0
                      ? Center(
                          child: CustomNoDataWidget(
                            message: 'no_rooms'.tr(),
                          ),
                        )
                      : ListView.builder(
                          itemCount: cubit.chatRoomModel?.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            return Material(
                              color: Colors.white,
                              shadowColor: Colors.grey,
                              elevation: 1,
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0, vertical: 0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage((context
                                                        .read<LoginCubit>()
                                                        .authData
                                                        ?.data
                                                        ?.userType ==
                                                    0
                                                ? (cubit
                                                    .chatRoomModel
                                                    ?.data?[index]
                                                    .driver
                                                    ?.image)
                                                : cubit
                                                    .chatRoomModel
                                                    ?.data?[index]
                                                    .user
                                                    ?.image) ??
                                            ''),
                                      ),
                                      Flexible(
                                          child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 8.0),
                                        child: Text(
                                          "#${cubit.chatRoomModel?.data?[index].shipmentCode ?? ''}-${context.read<LoginCubit>().authData?.data?.userType == 0 ? (cubit.chatRoomModel?.data?[index].driver?.name ?? '') : (cubit.chatRoomModel?.data?[index].user?.name ?? '')}",
                                          maxLines: 2,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  //

                                  Navigator.pushNamed(
                                    context,
                                    Routes.messageRoute,
                                    arguments: MainUserAndRoomChatModel(
                                      driverId: cubit.chatRoomModel
                                          ?.data?[index].driver?.id
                                          ?.toString(),
                                      shipmentId: cubit.chatRoomModel
                                          ?.data?[index].shipmentId
                                          ?.toString(),
                                      chatId: cubit
                                          .chatRoomModel?.data?[index].roomToken
                                          .toString(),
                                      title:
                                          "#${cubit.chatRoomModel?.data?[index].shipmentCode ?? ''}-${context.read<LoginCubit>().authData?.data?.userType == 0 ? (cubit.chatRoomModel?.data?[index].driver?.name ?? '') : (cubit.chatRoomModel?.data?[index].user?.name ?? '')}",
                                    ),
                                  );

                                  //
                                },
                              ),
                            );
                          }),
        );
      },
    );
  }
}
