import 'package:waslny/core/exports.dart';
import 'package:waslny/features/user/add_new_trip/cubit/cubit.dart';
import 'package:waslny/features/user/add_new_trip/screens/widget/latest_locations_widget.dart';

class AlllatestLocationsScreen extends StatefulWidget {
  const AlllatestLocationsScreen({super.key});

  @override
  State<AlllatestLocationsScreen> createState() =>
      _AlllatestLocationsScreenState();
}

class _AlllatestLocationsScreenState extends State<AlllatestLocationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LatestLocationsWidgets(
        cubit: context.read<AddNewTripCubit>(),
        showAll: true,
      ),
    );
  }
}
