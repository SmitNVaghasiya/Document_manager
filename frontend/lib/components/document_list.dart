import 'package:flutter/material.dart';
import '../models/document_model.dart';

class DocumentList extends StatefulWidget {
  final List<Document> documents;

  const DocumentList({super.key, required this.documents});

  @override
  State<DocumentList> createState() => _DocumentListState();
}

class _DocumentListState extends State<DocumentList> {
  String? _selectedCategory;
  String _searchQuery = '';
  bool _groupDocuments = false;

  List<String> get _categories => [
    'All',
    ...{for (final doc in widget.documents) doc.category},
  ];

  Map<String, List<Document>> get _groupedDocuments {
    final filtered = _filteredDocuments;
    if (!_groupDocuments) {
      return {'ungrouped': filtered};
    }

    final grouped = <String, List<Document>>{};
    for (final doc in filtered) {
      final key = doc.groupId ?? doc.name;
      grouped[key] = [...(grouped[key] ?? []), doc];
    }
    return grouped;
  }

  List<Document> get _filteredDocuments {
    var filtered = widget.documents;

    if (_selectedCategory != null && _selectedCategory != 'All') {
      filtered = filtered
          .where((doc) => doc.category == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (doc) =>
                doc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                doc.category.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (doc.user?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                    false),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterSection(),
        const SizedBox(height: 16),
        Expanded(
          child: _filteredDocuments.isEmpty
              ? _buildEmptyState()
              : _buildDocumentList(),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search documents...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategory ?? 'All',
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
            ),
            const SizedBox(width: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Icon(Icons.group_work, size: 16),
                    const SizedBox(width: 4),
                    Switch(
                      value: _groupDocuments,
                      onChanged: (value) =>
                          setState(() => _groupDocuments = value),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No documents found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentList() {
    final grouped = _groupedDocuments;

    return ListView.builder(
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        final groupKey = grouped.keys.elementAt(index);
        final documents = grouped[groupKey]!;

        if (!_groupDocuments) {
          return _buildDocumentCard(documents.first);
        }

        return _buildDocumentGroup(groupKey, documents);
      },
    );
  }

  Widget _buildDocumentGroup(String groupKey, List<Document> documents) {
    if (documents.length == 1) {
      return _buildDocumentCard(documents.first);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(Icons.folder, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          groupKey,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${documents.length} documents'),
        children: documents
            .map((doc) => _buildDocumentCard(doc, isGrouped: true))
            .toList(),
      ),
    );
  }

  Widget _buildDocumentCard(Document doc, {bool isGrouped = false}) {
    return Card(
      margin: isGrouped
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
          : const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getDocumentColor(doc).withOpacity(0.1),
          child: Icon(_getDocumentIcon(doc), color: _getDocumentColor(doc)),
        ),
        title: Text(
          doc.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${doc.category}'),
            if (doc.user != null) Text('User: ${doc.user}'),
            Text('Uploaded: ${_formatDate(doc.uploadedAt)}'),
            if (doc.expiryDate != null) _buildExpiryText(doc),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (doc.isExpired)
              const Icon(Icons.warning, color: Colors.red, size: 20),
            if (doc.isExpiringSoon)
              const Icon(Icons.schedule, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text(
              doc.fileExtension,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
          ],
        ),
        onTap: () {
          // TODO: Open document
        },
      ),
    );
  }

  Widget _buildExpiryText(Document doc) {
    if (doc.isExpired) {
      return Text(
        'Expired',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
      );
    } else if (doc.isExpiringSoon) {
      return Text(
        'Expires: ${_formatDate(doc.expiryDate!)}',
        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
      );
    } else {
      return Text(
        'Expires: ${_formatDate(doc.expiryDate!)}',
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
      );
    }
  }

  Color _getDocumentColor(Document doc) {
    switch (doc.category) {
      case 'Degree':
      case 'Diploma':
      case 'High School':
        return Colors.blue;
      case 'Medical':
        return Colors.red;
      case 'Property':
      case 'Home':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getDocumentIcon(Document doc) {
    switch (doc.category) {
      case 'Degree':
      case 'Diploma':
      case 'High School':
        return Icons.school;
      case 'Medical':
        return Icons.local_hospital;
      case 'Property':
      case 'Home':
        return Icons.home;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
