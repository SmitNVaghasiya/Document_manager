import 'package:flutter/material.dart';
import '../models/priority_model.dart';

class SortFilterWidget extends StatelessWidget {
  final SortOption selectedSortOption;
  final Function(SortOption) onSortChanged;
  final String? selectedCategory;
  final List<String> categories;
  final Function(String?) onCategoryChanged;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final bool groupDocuments;
  final Function(bool) onGroupToggle;

  const SortFilterWidget({
    super.key,
    required this.selectedSortOption,
    required this.onSortChanged,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.groupDocuments,
    required this.onGroupToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search documents...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 16),

        // Filter Row
        Row(
          children: [
            // Category Filter
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: selectedCategory ?? 'All',
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: onCategoryChanged,
              ),
            ),
            const SizedBox(width: 12),

            // Sort Options
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<SortOption>(
                value: selectedSortOption,
                decoration: const InputDecoration(
                  labelText: 'Sort by',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sort),
                ),
                items: SortOption.values
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Row(
                            children: [
                              Text(option.icon, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(option.displayName)),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) => onSortChanged(value!),
              ),
            ),
            const SizedBox(width: 12),

            // Group Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Icon(
                      groupDocuments ? Icons.group_work : Icons.group_work_outlined,
                      size: 20,
                      color: groupDocuments ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                    const SizedBox(height: 4),
                    Switch(
                      value: groupDocuments,
                      onChanged: onGroupToggle,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Quick Sort Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: SortOption.values.map((option) {
              final isSelected = selectedSortOption == option;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(option.icon, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(option.displayName),
                    ],
                  ),
                  onSelected: (selected) {
                    if (selected) onSortChanged(option);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}