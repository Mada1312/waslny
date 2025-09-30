import 'package:waslny/core/exports.dart';
import '../data/model/driver_details_model.dart';
import '../data/repo.dart';
import 'state.dart';

class DriverDetailsCubit extends Cubit<DriverDetailsState> {
  DriverDetailsCubit(this.api) : super(DriverDetailsInit());

  DriverDetailsRepo api;
  DriverDetailsModel? driverDetailsModel;
  getDriverById(String driverId) async {
    emit(DriverDetailsLoading());
    try {
      final response = await api.getDriverById(driverId: driverId);

      response.fold((l) {
        emit(DriverDetailsError("No driver found with this ID"));
      }, (r) {
        driverDetailsModel = r;
        emit(DriverDetailsLoaded(r));
      });
    } catch (e) {
      emit(DriverDetailsError(e.toString()));
    }
  }
}
