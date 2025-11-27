// presentation / widgets / star_indicator.dart
import '../../../../../core/exports.dart';

class StarIndicator extends StatelessWidget {
  const StarIndicator({super.key, required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    final rounded = rating.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          Icons.star,
          size: 20,
          color: i < rounded ? Colors.orange : Colors.grey.shade400,
        ),
      ),
    );
  }
}
