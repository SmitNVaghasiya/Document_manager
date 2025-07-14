import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DocumentUploadForm extends StatefulWidget {
  final void Function(
    String name,
    String category,
    String filePath,
    String? user,
    DateTime? expiryDate,
    String? groupId,
  )?
  onUpload;

  const DocumentUploadForm({super.key, this.onUpload});

  @override
  State<DocumentUploadForm> createState() => _DocumentUploadFormState();
}

class _DocumentUploadFormState extends State<DocumentUploadForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _userController = TextEditingController();
  final _categoryController = TextEditingController();
  final _groupController = TextEditingController();

  String? _selectedCategory;
  String? _filePath;
  DateTime? _expiryDate;
  bool _hasExpiry = false;

  final List<String> _categories = [
    'Degree',
    'Diploma',
    'High School',
    'Medical',
    'Home',
    'Property',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _userController.dispose();
    _categoryController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _filePath = result.files.single.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  Future<void> _pickExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _addCategory() {
    final newCategory = _categoryController.text.trim();
    if (newCategory.isNotEmpty && !_categories.contains(newCategory)) {
      setState(() {
        _categories.add(newCategory);
        _selectedCategory = newCategory;
        _categoryController.clear();
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _filePath != null) {
      _formKey.currentState!.save();

      final groupId = _groupController.text.trim().isNotEmpty
          ? _groupController.text.trim()
          : null;

      widget.onUpload?.call(
        _nameController.text.trim(),
        _selectedCategory!,
        _filePath!,
        _userController.text.trim().isNotEmpty
            ? _userController.text.trim()
            : null,
        _hasExpiry ? _expiryDate : null,
        groupId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a document file'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.upload_file, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Upload Document',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),

          // File picker
          Card(
            child: InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _filePath == null
                          ? Icons.cloud_upload
                          : Icons.check_circle,
                      size: 48,
                      color: _filePath == null ? Colors.grey : Colors.green,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _filePath == null
                          ? 'Tap to select document'
                          : 'Document selected',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_filePath != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _filePath!.split('/').last,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Document name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Document Name *',
              hintText: 'Enter document name',
              prefixIcon: Icon(Icons.description),
            ),
            validator: (value) => value?.trim().isEmpty ?? true
                ? 'Please enter a document name'
                : null,
          ),
          const SizedBox(height: 16),

          // Category selection
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category *',
              prefixIcon: Icon(Icons.category),
            ),
            items: _categories
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
            validator: (value) => value == null || value.isEmpty
                ? 'Please select a category'
                : null,
          ),
          const SizedBox(height: 12),

          // Add new category
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Add New Category',
                    prefixIcon: Icon(Icons.add),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _addCategory, child: const Text('Add')),
            ],
          ),
          const SizedBox(height: 16),

          // User name
          TextFormField(
            controller: _userController,
            decoration: const InputDecoration(
              labelText: 'User Name (Optional)',
              hintText: 'Enter user name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),

          // Group ID
          TextFormField(
            controller: _groupController,
            decoration: const InputDecoration(
              labelText: 'Group ID (Optional)',
              hintText: 'Enter group ID to group related documents',
              prefixIcon: Icon(Icons.group_work),
            ),
          ),
          const SizedBox(height: 16),

          // Expiry date section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Expiry Date',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Switch(
                        value: _hasExpiry,
                        onChanged: (value) => setState(() {
                          _hasExpiry = value;
                          if (!value) _expiryDate = null;
                        }),
                      ),
                    ],
                  ),
                  if (_hasExpiry) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickExpiryDate,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.date_range, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _expiryDate == null
                                  ? 'Select expiry date'
                                  : '${_expiryDate!.day.toString().padLeft(2, '0')}/${_expiryDate!.month.toString().padLeft(2, '0')}/${_expiryDate!.year}',
                              style: TextStyle(
                                color: _expiryDate == null
                                    ? Colors.grey[600]
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Upload Document',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
