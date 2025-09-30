import 'package:easy_localization/easy_localization.dart';
import 'package:waslny/core/exports.dart';

String getCurrentFormattedDate() {
  final now = DateTime.now();
  return "${now.day}/${now.month}/${now.year}";
}

class DatePickerField extends StatelessWidget {
  final Function()? onTab;
  final DateTime? selectedDate;
  final String title;
  final bool isWithTime;
  const DatePickerField({
    super.key,
    this.onTab,
    this.selectedDate,
    this.isWithTime = false,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10.sp,
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.black,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.sp,
          ),
          GestureDetector(
            onTap: onTab,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? isWithTime
                            ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}\n${selectedDate!.hour}:${selectedDate!.minute}'
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : "data_filter".tr(),
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  const Icon(Icons.calendar_today, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
