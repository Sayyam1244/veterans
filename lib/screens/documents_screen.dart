import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/document_service.dart';
import 'upload_document_screen.dart';
import 'document_detail_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> with SingleTickerProviderStateMixin {
  final DocumentService _documentService = DocumentService();
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: DocumentCategory.values.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Documents',
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D2D2D)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: const InputDecoration(
                    hintText: 'Search documents...',
                    prefixIcon: Icon(Icons.search, color: Color(0xFF757575)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              // Tab bar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: const Color(0xFF4CAF50),
                unselectedLabelColor: const Color(0xFF757575),
                indicatorColor: const Color(0xFF4CAF50),
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: [
                  const Tab(text: 'All'),
                  ...DocumentCategory.values.map(
                    (category) =>
                        Tab(text: DocumentService.getCategoryDisplayName(category).split(' ').first),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          // Storage usage indicator
          StreamBuilder<int>(
            stream: Stream.fromFuture(_documentService.getStorageUsage()),
            builder: (context, snapshot) {
              final usage = snapshot.data ?? 0;
              final usageMB = usage / (1024 * 1024);
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${usageMB.toStringAsFixed(1)} MB',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All documents
          _buildDocumentsList(_documentService.getUserDocuments()),
          // Category-specific tabs
          ...DocumentCategory.values.map(
            (category) => _buildDocumentsList(_documentService.getDocumentsByCategory(category)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadDocumentScreen()));
        },
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Upload Document', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildDocumentsList(Stream<List<UserDocument>> documentsStream) {
    return StreamBuilder<List<UserDocument>>(
      stream: documentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading documents: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => setState(() {}), child: const Text('Retry')),
              ],
            ),
          );
        }

        final documents = snapshot.data ?? [];

        // Filter documents based on search query
        final filteredDocuments =
            documents.where((doc) {
              return _searchQuery.isEmpty ||
                  doc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  doc.fileName.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

        if (filteredDocuments.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDocuments.length,
            itemBuilder: (context, index) {
              final document = filteredDocuments[index];
              return _buildDocumentCard(document);
            },
          ),
        );
      },
    );
  }

  Widget _buildDocumentCard(UserDocument document) {
    final isExpiringSoon =
        document.expiryDate != null &&
        document.expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: Colors.black12,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DocumentDetailScreen(document: document)),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isExpiringSoon ? Border.all(color: Colors.orange, width: 1) : null,
            ),
            child: Row(
              children: [
                // Document icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(document.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/${DocumentService.getCategoryIcon(document.category)}',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(_getCategoryColor(document.category), BlendMode.srcIn),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Document info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              document.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D2D2D),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isExpiringSoon)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Expiring Soon',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DocumentService.getCategoryDisplayName(document.category),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(document.uploadedAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.storage, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            _formatFileSize(document.size),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // More options
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, document),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                  child: const Icon(Icons.more_vert, color: Color(0xFF757575)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/doc.svg',
              width: 80,
              height: 80,
              colorFilter: ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn),
            ),
            const SizedBox(height: 20),
            Text(
              'No Documents Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload your important documents to keep them secure and accessible.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.4),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadDocumentScreen()),
                );
              },
              icon: const Icon(Icons.cloud_upload, color: Colors.white),
              label: const Text(
                'Upload First Document',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.medical:
        return const Color(0xFFE91E63);
      case DocumentCategory.benefits:
        return const Color(0xFF4CAF50);
      case DocumentCategory.identification:
        return const Color(0xFF2196F3);
      case DocumentCategory.discharge:
        return const Color(0xFF9C27B0);
      case DocumentCategory.insurance:
        return const Color(0xFFFF9800);
      case DocumentCategory.other:
        return const Color(0xFF607D8B);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatFileSize(int size) {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  void _handleMenuAction(String action, UserDocument document) {
    switch (action) {
      case 'edit':
        _showEditDialog(document);
        break;
      case 'delete':
        _showDeleteDialog(document);
        break;
    }
  }

  void _showEditDialog(UserDocument document) {
    final nameController = TextEditingController(text: document.name);
    DocumentCategory selectedCategory = document.category;
    DateTime? selectedExpiryDate = document.expiryDate;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Edit Document'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Document Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<DocumentCategory>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            DocumentCategory.values.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(DocumentService.getCategoryDisplayName(category)),
                              );
                            }).toList(),
                        onChanged: (value) => setDialogState(() => selectedCategory = value!),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedExpiryDate != null
                                  ? 'Expires: ${_formatDate(selectedExpiryDate!)}'
                                  : 'No expiry date',
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedExpiryDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                              );
                              if (date != null) {
                                setDialogState(() => selectedExpiryDate = date);
                              }
                            },
                            child: const Text('Set Date'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () async {
                        final success = await _documentService.updateDocument(
                          documentId: document.id,
                          name: nameController.text.trim(),
                          category: selectedCategory,
                          expiryDate: selectedExpiryDate,
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success ? 'Document updated successfully' : 'Failed to update document',
                              ),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                      child: const Text('Save', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteDialog(UserDocument document) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Document'),
            content: Text(
              'Are you sure you want to delete "${document.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  final success = await _documentService.deleteDocument(document.id);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success ? 'Document deleted successfully' : 'Failed to delete document',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}
