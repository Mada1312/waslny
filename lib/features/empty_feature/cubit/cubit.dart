import 'package:waslny/core/exports.dart';
import '../data/repo.dart';
import 'state.dart';

class EmpCubit extends Cubit<EmpState> {
  EmpCubit(this.api) : super(EmpInitial());

  EmpRepo api;
}
