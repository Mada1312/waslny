import 'package:waslny/core/exports.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';
import 'pdf_viewer.dart';
import 'video_player_screen.dart';
import 'youtube_video_player.dart';

class TutorialVideoScreen extends StatefulWidget {
  const TutorialVideoScreen({
    super.key,
  });

  @override
  State<TutorialVideoScreen> createState() => _TutorialVideoScreenState();
}

class _TutorialVideoScreenState extends State<TutorialVideoScreen> {
  @override
  void initState() {
    context.read<TutorialVideoCubit>().getTutorialVideos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TutorialVideoCubit, TutorialVideoState>(
        builder: (context, state) {
      var cubit = context.read<TutorialVideoCubit>();

      return Scaffold(
        appBar: customAppBar(context, title: 'tutorial_video'.tr()),
        body: state is LoadingGetTutorialVideoState
            ? const Center(child: CustomLoadingIndicator())
            : Padding(
                padding: EdgeInsets.all(12.w),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: cubit.mainTutorialVideoModel?.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    var video = cubit.mainTutorialVideoModel?.data?[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => (video?.type == 0 &&
                                        video?.typeName == 'يوتيوب')
                                    ? YoutubeVideoPlayer(
                                        title: video?.title ?? '',
                                        videoLinkId: video?.video ?? '')
                                    : VideoPlayerScreen(
                                        title: video?.title ?? '',
                                        videoUrl: video?.video ?? '')
                                // : PdfViewerScreen(
                                //     title: video?.title ?? '',
                                //     pdfUrl: video?.video ?? '')
                                ));
                      },
                      child: Container(
                        margin: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Column(
                          children: [
                            Flexible(
                                fit: FlexFit.tight,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: CachedNetworkImage(
                                    imageUrl: video?.image ?? '',
                                    errorWidget: (context, error, stackTrace) =>
                                        Image.asset(
                                      ImageAssets.driverCover,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                )),
                            Text(
                              (video?.title ?? "" '\n'),
                              maxLines: 2,
                              style: getRegularStyle(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
      );
    });
  }
}
