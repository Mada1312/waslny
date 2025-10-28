
import 'package:waslny/core/exports.dart';

class MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isCircular;

  const MapButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shape: isCircular ? const CircleBorder() : const RoundedRectangleBorder(),
      color: Colors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
      ),
    );
  }
}
