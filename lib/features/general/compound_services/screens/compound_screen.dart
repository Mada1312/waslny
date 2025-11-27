import 'package:waslny/core/exports.dart';
import 'package:waslny/features/general/compound_services/screens/widgets/compound_widget.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';

class CompoundServicesScreen extends StatefulWidget {
  const CompoundServicesScreen({super.key, required this.isDriver});
  final bool isDriver;

  @override
  State<CompoundServicesScreen> createState() => _CompoundServicesScreenState();
}

class _CompoundServicesScreenState extends State<CompoundServicesScreen> {
  @override
  void initState() {
    var cubit = context.read<CompoundServicesCubit>();
    cubit.getCompoundServices();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompoundServicesCubit, CompoundServicesState>(
      builder: (context, state) {
        var cubit = context.read<CompoundServicesCubit>();

        return Scaffold(
          appBar: customAppBar(
            context,
            title: 'compound_services'.tr(),
            leading: SizedBox(),
          ),
          body: Center(
            child: state is FailureGetCompoundServicesState
                ? CustomNoDataWidget(
                    message: 'error_happened'.tr(),
                    onTap: () {
                      cubit.getCompoundServices();
                    },
                  )
                : state is LoadingGetCompoundServicesState ||
                      cubit.compoundServicesModel?.data == null
                ? const Center(child: CustomLoadingIndicator())
                : cubit.compoundServicesModel!.data!.isEmpty
                ? CustomNoDataWidget(
                    message: 'no_compound_services'.tr(),
                    onTap: () {
                      cubit.getCompoundServices();
                    },
                  )
                : RefreshIndicator(
                    color: AppColors.primary,

                    onRefresh: () async {
                      await cubit.getCompoundServices();
                    },
                    child: CompoundServicesListView(
                      compounds: cubit.compoundServicesModel?.data ?? [],
                      isDriver: widget.isDriver,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
