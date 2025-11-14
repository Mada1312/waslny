import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/extention.dart';

class ResponsiveTimeGenderVehicleDropdowns extends StatelessWidget {
  final TimeType? selectedTimeType;
  final Gender? selectedGenderType;
  final VehicleType? selectedVehicleType;
  final ValueChanged<TimeType?> onTimeTypeChanged;
  final ServiceTo? selectedServiceTo;
  final ValueChanged<ServiceTo?> onServiceToChanged;
  final ValueChanged<Gender?> onGenderTypeChanged;
  final ValueChanged<VehicleType?> onVehicleTypeChanged;
  final bool isService;
  const ResponsiveTimeGenderVehicleDropdowns({
    super.key,
    this.selectedTimeType,
    this.isService = false,
    this.selectedGenderType,
    this.selectedVehicleType,
    required this.onTimeTypeChanged,
    this.selectedServiceTo,
    required this.onServiceToChanged,
    required this.onGenderTypeChanged,
    required this.onVehicleTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive width depending on number of items per line
    double screenWidth = context.w;
    double spacing = 24.w; // same as 5.w.horizontalSpace * 2 roughly
    Widget buildDropdown<T>({
      required List<T> items,
      required T? value,
      required ValueChanged<T?> onChanged,
      required String Function(T) itemBuilder,
    }) {
      return SizedBox(
        width: (screenWidth / 2) - spacing,
        child: CustomDropdownButtonFormField<T>(
          items: items,
          borderRadius: 22.r,
          itemBuilder: itemBuilder,
          value: value,
          onChanged: onChanged,
        ),
      );
    }

    return Wrap(
      spacing: spacing,
      runSpacing: spacing / 2,
      children: [
        buildDropdown<TimeType>(
          items: TimeType.values,
          value: selectedTimeType,
          onChanged: onTimeTypeChanged,
          itemBuilder: (item) => item.displayValue,
        ),
        buildDropdown<Gender>(
          items: Gender.values,
          value: selectedGenderType,
          onChanged: onGenderTypeChanged,
          itemBuilder: (item) => item.displayValue,
        ),
        buildDropdown<VehicleType>(
          items: VehicleType.values,
          value: selectedVehicleType,
          onChanged: onVehicleTypeChanged,
          itemBuilder: (item) => item.displayValue,
        ),
        if (isService)
          buildDropdown<ServiceTo>(
            items: ServiceTo.values,
            value: selectedServiceTo,
            onChanged: onServiceToChanged,
            itemBuilder: (item) => item.displayValue,
          ),
      ],
    );
  }
}
