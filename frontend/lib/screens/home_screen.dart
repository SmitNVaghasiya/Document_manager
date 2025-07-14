import 'package:flutter/material.dart';
import '../components/document_upload_form.dart';
import '../components/document_list.dart';
import '../models/document_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Document> _documents = [
    Document(
      name: 'Degree Certificate',
      category: 'Degree',
      filePath: '/docs/degree.pdf',
      uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
      user: 'Smit',
      expiryDate: null,
      groupId: 'education_1',
    ),
    Document(
      name: 'College Result',
      category: 'Degree',
      filePath: '/docs/result.pdf',
      uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
      user: 'Smit',
      expiryDate: null,
      groupId: 'education_1',
    ),
    Document(
      name: 'Medical Report',
      category: 'Medical',
      filePath: '/docs/medical.pdf',
      uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
      user: 'Family',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
    ),
    Document(
      name: 'Property Deed',
      category: 'Property',
      filePath: '/docs/property.pdf',
      uploadedAt: DateTime.now().subtract(const Duration(days: 20)),
      user: 'Smit',
      expiryDate: null,
    ),
    Document(
      name: 'Expired License',
      category: 'Other',
      filePath: '/docs/license.pdf',
      uploadedAt: DateTime.now().subtract(const Duration(days: 100)),
      user: 'Smit',
      expiryDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  void _showUploadForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: DocumentUploadForm(
          onUpload: (name, category, filePath, user, expiryDate, groupId) {
            setState(() {
              _documents.add(Document(
                name: name,
                category: category,
                filePath: filePath,
                uploadedAt: DateTime.now(),
                user: user,
                expiryDate: expiryDate,
                groupId: groupId,
              ));
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show expiry notifications
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCards(),
            const SizedBox(height: 24),
            Expanded(
              child: DocumentList(documents: _documents),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Upload'),
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalDocs = _documents.length;
    final expiredDocs = _documents.where((doc) => 
      doc.expiryDate != null && doc.expiryDate!.isBefore(DateTime.now())
    ).length;
    final expiringSoon = _documents.where((doc) => 
      doc.expiryDate != null && 
      doc.expiryDate!.isAfter(DateTime.now()) &&
      doc.expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)))
    ).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Documents',
            value: totalDocs.toString(),
            icon: Icons.folder,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Expired',
            value: expiredDocs.toString(),
            icon: Icons.warning,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Expiring Soon',
            value: expiringSoon.toString(),
            icon: Icons.schedule,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}