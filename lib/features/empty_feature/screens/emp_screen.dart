import 'package:waslny/core/exports.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';

class EmpScreen extends StatelessWidget {
  const EmpScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmpCubit, EmpState>(builder: (context, state) {
      var cubit = context.read<EmpCubit>();

      return Scaffold(
        appBar: customAppBar(context, title: 'title'.tr()),
        body: Padding(
          padding: EdgeInsets.all(12.w),
          child: Text('title'.tr()),
        ),
      );
    });
  }
}
