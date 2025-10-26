import 'package:waslny/core/exports.dart';
import '../data/model/driver_details_model.dart';
import '../data/repo.dart';
import 'state.dart';

class DriverProfileCubit extends Cubit<DriverProfileState> {
  DriverProfileCubit(this.api) : super(DriverProfileInit());

  DriverProfileRepo api;
  DriverProfileMainModel? driverDetailsModel;
  getDriverDetails() async {
    emit(DriverDetailsLoading());
    try {
      final response = await api.getDriverById();
      response.fold(
        (l) {
          emit(DriverDetailsError("No driver found with this ID"));
        },
        (r) {
          driverDetailsModel = r;
          emit(DriverDetailsLoaded(r));
        },
      );
    } catch (e) {
      emit(DriverDetailsError(e.toString()));
    }
  }
}
