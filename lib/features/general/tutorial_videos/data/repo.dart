import '../../../../core/exports.dart';
import 'models/main_tutorial_videos.dart';

class TutorialVideoRepo {
  BaseApiConsumer dio;
  TutorialVideoRepo(this.dio);

  Future<Either<Failure, MainTutorialVideoModel>> getTutorialVideos() async {
    try {
      var response = await dio.get(EndPoints.getVideosUrl);
      return Right(MainTutorialVideoModel.fromJson(response));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
