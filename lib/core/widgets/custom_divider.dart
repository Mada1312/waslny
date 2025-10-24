import 'package:waslny/core/exports.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key, this.color, this.endIndent, this.indent});
  final Color? color;
  final double? endIndent;
  final double? indent;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Divider(
        height: 3,
        thickness: 1,
        endIndent: endIndent ?? 10,
        indent: indent ?? 10,
        color: color ?? AppColors.second3Primary,
      ),
    );
  }
}
