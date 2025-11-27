import 'package:waslny/core/exports.dart';
import 'package:waslny/features/general/compound_services/data/models/get_compound_model.dart';

import '../data/repo.dart';
import 'state.dart';

class CompoundServicesCubit extends Cubit<CompoundServicesState> {
  CompoundServicesCubit(this.api) : super(CompoundServicesInitial());

  CompoundServicesRepo api;
  GetCompoundServicesModel? compoundServicesModel;

  getCompoundServices({String? search}) async {
    emit(LoadingGetCompoundServicesState());
    final res = await api.getCompoundServices(search);
    res.fold(
      (l) {
        emit(FailureGetCompoundServicesState());
      },
      (r) {
        compoundServicesModel = r;

        emit(SuccessGetCompoundServicesState());
      },
    );
  }
}
