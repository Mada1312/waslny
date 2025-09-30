import 'package:waslny/core/exports.dart';
import '../data/models/main_tutorial_videos.dart';
import '../data/repo.dart';
import 'state.dart';

class TutorialVideoCubit extends Cubit<TutorialVideoState> {
  TutorialVideoCubit(this.api) : super(TutorialVideoInitial());

  TutorialVideoRepo api;
  MainTutorialVideoModel? mainTutorialVideoModel;
  getTutorialVideos() async {
    try {
      emit(LoadingGetTutorialVideoState());
      final res = await api.getTutorialVideos();
      res.fold((l) {
        mainTutorialVideoModel = null;
        emit(ErrorGetTutorialVideoState());
      }, (r) {
        mainTutorialVideoModel = r;
        emit(LoadedGetTutorialVideoState());
      });
    } catch (e) {
      mainTutorialVideoModel = null;
      emit(ErrorGetTutorialVideoState());
    }
  }
}
