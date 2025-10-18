// ───────────────── presentation / pages / driver_details_screen_by_id.dart
import 'package:waslny/core/exports.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';
import '../data/model/driver_details_model.dart';
import 'widget/rate_widget.dart';

class DriverDetailsScreenById extends StatefulWidget {
  const DriverDetailsScreenById({super.key, required this.driverId});

  final String driverId;

  @override
  State<DriverDetailsScreenById> createState() =>
      _DriverDetailsScreenByIdState();
}

class _DriverDetailsScreenByIdState extends State<DriverDetailsScreenById> {
  @override
  void initState() {
    context.read<DriverDetailsCubit>().getDriverById(widget.driverId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _DriverDetailsView();
  }
}

// ───────────────── internal view
class _DriverDetailsView extends StatelessWidget {
  const _DriverDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('driver_details'.tr())),
      body: BlocBuilder<DriverDetailsCubit, DriverDetailsState>(
        builder: (context, state) {
          if (state is DriverDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DriverDetailsError) {
            return Center(
              child: Text(state.message, textAlign: TextAlign.center),
            );
          }

          if (state is DriverDetailsLoaded) {
            final d = state.driver; // domain entity

            return state.driver == null
                ? Center(child: Text('no_data'.tr()))
                : Directionality(
                    textDirection: TextDirection.rtl,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ── Header picture & name ────────────────────────────────
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(
                                  d?.data?.image ?? '',
                                ),
                              ),
                              if (d?.data?.isVerified == 1)
                                Positioned(
                                  bottom: 0,
                                  child: Image.asset(
                                    ImageAssets.verifyIcon,
                                    width: 40.w,
                                    height: 40.w,
                                  ),
                                ),
                            ],
                          ),
                          10.h.verticalSpace,
                          Text(
                            d?.data?.name ?? '',
                            style: getBoldStyle(
                              color: AppColors.primary,
                              fontSize: 20.sp,
                            ),
                          ),
                          // Text('${d?.data?.country} , ${d?.data?.city}',
                          //     style: Theme.of(context)
                          //         .textTheme
                          //         .bodyMedium
                          //         ?.copyWith(color: Colors.grey)),
                          Text(
                            d?.data?.phone ?? '',
                            style: getMediumStyle(
                              color: AppColors.secondPrimary,
                            ),
                          ),
                          const Divider(thickness: 1.2, height: 32),

                          // ── Static info rows (value on the left) ────────────────
                          _InfoRow(
                            title: 'countries'.tr(),
                            value: d?.data?.countries ?? [],
                          ),
                          const Divider(thickness: 1.2, height: 32),

                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'shipment_type'.tr(),
                                  style: getBoldStyle(color: AppColors.primary),
                                ),
                                Text(
                                  d?.data?.truckType?.name ?? '',
                                  style: getRegularStyle(),
                                ),
                              ],
                            ),
                          ),
                          const Divider(thickness: 1.2, height: 32),

                          // ── Rating summary (average & histogram) ───────────────
                          _RatingSection(
                            average: double.parse(
                              d?.data?.averageRates ?? '0.0',
                            ),
                            counts: d?.data?.totalRates ?? 0,
                          ),
                        ],
                      ),
                    ),
                  );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ───────────────── helpers ──────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});
  final String title;
  final List<TruckType> value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: getBoldStyle(color: AppColors.primary)),
          ListView.builder(
            itemCount: value.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Text(value[index].name ?? '', style: getRegularStyle());
            },
          ),
        ],
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  const _RatingSection({required this.average, required this.counts});

  final double average;
  final int counts; // {5: 12, 4: 2, 3: 0, 2: 0, 1: 1}

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('rating'.tr(), style: getBoldStyle(color: AppColors.primary)),
        5.h.verticalSpace,
        Row(
          children: [
            Text("(${average.toStringAsFixed(1)})", style: getRegularStyle()),
            const SizedBox(width: 8),
            StarIndicator(rating: average), // reusable widget
          ],
        ),
      ],
    );
  }
}
