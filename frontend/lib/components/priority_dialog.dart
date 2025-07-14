import 'package:flutter/material.dart';
import '../models/priority_model.dart';

class PriorityDialog extends StatefulWidget {
  final DocumentPriority currentPriority;
  final Function(DocumentPriority) onPriorityChanged;

  const PriorityDialog({
    super.key,
    required this.currentPriority,
    required this.onPriorityChanged,
  });

  @override
  State<PriorityDialog> createState() => _PriorityDialogState();
}

class _PriorityDialogState extends State<PriorityDialog> {
  late PriorityLevel _selectedLevel;
  late bool _isLoved;
  late int? _customRank;
  final TextEditingController _rankController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.currentPriority.level;
    _isLoved = widget.currentPriority.isLoved;
    _customRank = widget.currentPriority.customRank;
    if (_customRank != null) {
      _rankController.text = _customRank.toString();
    }
  }

  @override
  void dispose() {
    _rankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.star, color: Colors.amber),
          SizedBox(width: 8),
          Text('Set Priority'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loved Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isLoved ? Icons.favorite : Icons.favorite_border,
                      color: _isLoved ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loved Document',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Mark as loved for quick access',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isLoved,
                      onChanged: (value) => setState(() => _isLoved = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priority Level
            const Text(
              'Priority Level:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...PriorityLevel.values.map((level) => _buildPriorityOption(level)),
            const SizedBox(height: 16),

            // Custom Rank
            if (_selectedLevel != PriorityLevel.none) ...[
              const Text(
                'Custom Rank (Optional):',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _rankController,
                decoration: const InputDecoration(
                  labelText: 'Rank (1-999)',
                  hintText: 'Lower number = Higher priority',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _customRank = int.tryParse(value);
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a number between 1-999. Lower numbers appear first.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newPriority = DocumentPriority(
              level: _selectedLevel,
              isLoved: _isLoved,
              customRank: _customRank,
              setPriorityDate: DateTime.now(),
            );
            widget.onPriorityChanged(newPriority);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildPriorityOption(PriorityLevel level) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<PriorityLevel>(
        title: Row(
          children: [
            Text(level.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(level.displayName),
          ],
        ),
        subtitle: Text(_getPriorityDescription(level)),
        value: level,
        groupValue: _selectedLevel,
        onChanged: (value) => setState(() => _selectedLevel = value!),
      ),
    );
  }

  String _getPriorityDescription(PriorityLevel level) {
    switch (level) {
      case PriorityLevel.none:
        return 'No special priority';
      case PriorityLevel.low:
        return 'Low importance documents';
      case PriorityLevel.medium:
        return 'Moderately important documents';
      case PriorityLevel.high:
        return 'Important documents';
      case PriorityLevel.critical:
        return 'Most important documents';
    }
  }
}
