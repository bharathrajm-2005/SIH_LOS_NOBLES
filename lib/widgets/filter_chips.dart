import 'package:flutter/material.dart';
import '../core/utils/app_colors.dart';

class FilterChips extends StatelessWidget {
  final List<String> options;
  final List<String> selectedOptions;
  final Function(String) onSelectionChanged;
  final bool multiSelect;

  const FilterChips({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.onSelectionChanged,
    this.multiSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: options.map((option) {
        final isSelected = selectedOptions.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) => onSelectionChanged(option),
          backgroundColor: AppColors.backgroundColor,
          selectedColor: AppColors.primaryColor.withOpacity(0.2),
          checkmarkColor: AppColors.primaryColor,
          labelStyle: TextStyle(
            color:
                isSelected ? AppColors.primaryColor : AppColors.textSecondary,
            fontSize: 12,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
            width: 1,
          ),
        );
      }).toList(),
    );
  }
}
