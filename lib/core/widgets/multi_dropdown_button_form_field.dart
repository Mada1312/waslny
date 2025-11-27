import '../exports.dart';

class MultiSelectDropdownWithChips<T> extends StatefulWidget {
  final List<T> items;
  final List<T>? selectedValues;
  final ValueChanged<List<T>> onChanged;
  final String Function(T item) itemBuilder;
  final String? title;
  final bool isRequired;
  final String? validationMessage;
  final String? hintText;
  final double chipSpacing;
  final double chipRunSpacing;

  const MultiSelectDropdownWithChips({
    super.key,
    required this.items,
    this.selectedValues,
    required this.onChanged,
    required this.itemBuilder,
    this.title,
    this.isRequired = false,
    this.validationMessage,
    this.hintText,
    this.chipSpacing = 8.0,
    this.chipRunSpacing = 8.0,
  });

  @override
  State<MultiSelectDropdownWithChips<T>> createState() =>
      _MultiSelectDropdownWithChipsState<T>();
}

class _MultiSelectDropdownWithChipsState<T>
    extends State<MultiSelectDropdownWithChips<T>> {
  late List<T> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.selectedValues ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Your original dropdown (single selection)
        CustomDropdownButtonFormField<T>(
          title: widget.title,
          value: null, // No value selected since we're using chips
          validationMessage: widget.validationMessage,
          validator: widget.isRequired
              ? (value) {
                  if (_selectedItems.isEmpty) {
                    return widget.validationMessage ??
                        'Please select at least one item';
                  }
                  return null;
                }
              : null,
          isRequired: widget.isRequired,
          items: widget.items,
          itemBuilder: widget.itemBuilder,
          onChanged: (selectedItem) {
            if (selectedItem != null &&
                !_selectedItems.contains(selectedItem)) {
              setState(() {
                _selectedItems.add(selectedItem);
                widget.onChanged(_selectedItems);
              });
            }
          },
          hintText: widget.hintText,
        ),

        // Selected items as chips
        if (_selectedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: widget.chipSpacing,
              runSpacing: widget.chipRunSpacing,
              children: _selectedItems.map((item) {
                return Chip(
                  label: Text(widget.itemBuilder(item)),
                  onDeleted: () {
                    setState(() {
                      _selectedItems.remove(item);
                      widget.onChanged(_selectedItems);
                    });
                  },
                  deleteIcon: const Icon(Icons.close, size: 18),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
