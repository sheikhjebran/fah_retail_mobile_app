import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/category_model.dart';

/// Category filter widget with horizontal scrollable chips
class CategoryFilter extends StatelessWidget {
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildChip(
              label: 'All',
              isSelected: selectedCategoryId == null,
              onTap: () => onCategorySelected(null),
            );
          }

          final category = categories[index - 1];
          return _buildChip(
            label: category.name,
            isSelected: selectedCategoryId == category.id,
            onTap: () => onCategorySelected(category.id),
          );
        },
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryLight,
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        backgroundColor: AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

/// Grid category filter for product list
class CategoryGridFilter extends StatelessWidget {
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;

  const CategoryGridFilter({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int?>(
      onSelected: onCategorySelected,
      itemBuilder: (context) => [
        const PopupMenuItem<int?>(
          value: null,
          child: Text('All Categories'),
        ),
        const PopupMenuDivider(),
        ...categories.map((category) => PopupMenuItem<int?>(
              value: category.id,
              child: Row(
                children: [
                  if (selectedCategoryId == category.id)
                    const Icon(Icons.check, size: 16, color: AppColors.primary)
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: 8),
                  Text(category.name),
                ],
              ),
            )),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list, size: 18),
            const SizedBox(width: 4),
            Text(
              selectedCategoryId == null
                  ? 'Category'
                  : categories
                          .where((c) => c.id == selectedCategoryId)
                          .firstOrNull
                          ?.name ??
                      'Category',
              style: const TextStyle(fontSize: 14),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
