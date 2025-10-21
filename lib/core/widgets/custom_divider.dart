import 'package:waslny/core/exports.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Divider(
        height: 3,
        thickness: 1,
        endIndent: 10,
        indent: 10,
        color: AppColors.second3Primary,
      ),
    );
  }
}
