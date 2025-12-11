import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/document_service.dart';

class DocumentDetailScreen extends StatefulWidget {
  final UserDocument document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  final DocumentService _documentService = DocumentService();

  @override
  Widget build(BuildContext context) {
    final isExpiringSoon =
        widget.document.expiryDate != null &&
        widget.document.expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Document Details',
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D2D2D)),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')]),
                  ),
                  const PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [Icon(Icons.download, size: 18), SizedBox(width: 8), Text('Download')],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(children: [Icon(Icons.share, size: 18), SizedBox(width: 8), Text('Share')]),
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document preview card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Document icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(widget.document.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/${DocumentService.getCategoryIcon(widget.document.category)}',
                        width: 40,
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          _getCategoryColor(widget.document.category),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Document name
                  Text(
                    widget.document.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2D2D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(widget.document.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DocumentService.getCategoryDisplayName(widget.document.category),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryColor(widget.document.category),
                      ),
                    ),
                  ),

                  if (isExpiringSoon) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning, size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Expiring Soon',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _viewDocument,
                          icon: const Icon(Icons.visibility, color: Colors.white),
                          label: const Text(
                            'View',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _downloadDocument,
                          icon: const Icon(Icons.download),
                          label: const Text('Download', style: TextStyle(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4CAF50),
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Document information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Document Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
                  ),
                  const SizedBox(height: 20),

                  _buildInfoRow(icon: Icons.description, label: 'File Name', value: widget.document.fileName),

                  _buildInfoRow(
                    icon: Icons.storage,
                    label: 'File Size',
                    value: _formatFileSize(widget.document.size),
                  ),

                  _buildInfoRow(
                    icon: Icons.file_present,
                    label: 'File Type',
                    value: widget.document.mimeType,
                  ),

                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Uploaded',
                    value: _formatDate(widget.document.uploadedAt),
                  ),

                  if (widget.document.expiryDate != null)
                    _buildInfoRow(
                      icon: Icons.event_available,
                      label: 'Expires',
                      value: _formatDate(widget.document.expiryDate!),
                      valueColor: isExpiringSoon ? Colors.orange : null,
                    ),
                ],
              ),
            ),

            if (widget.document.metadata != null && widget.document.metadata!.isNotEmpty) ...[
              const SizedBox(height: 24),

              // Metadata
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
                    ),
                    const SizedBox(height: 20),

                    ...widget.document.metadata!.entries.map(
                      (entry) => _buildInfoRow(
                        icon: Icons.info_outline,
                        label: _formatMetadataKey(entry.key),
                        value: entry.value.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Security notice
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Color(0xFF4CAF50), size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Secure Storage',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This document is encrypted and stored securely in the cloud. Only you can access it.',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF757575)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF757575), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor ?? const Color(0xFF2D2D2D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  String _formatMetadataKey(String key) {
    // Convert snake_case to Title Case
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : word)
        .join(' ');
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _showEditDialog();
        break;
      case 'download':
        _downloadDocument();
        break;
      case 'share':
        _shareDocument();
        break;
      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  Future<void> _viewDocument() async {
    try {
      // Since we're using base64 storage, viewing documents requires a different approach
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document viewing will be implemented in a future update'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _downloadDocument() async {
    try {
      // Since we're using base64 storage, downloading documents requires a different approach
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document download will be implemented in a future update'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading document: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _shareDocument() {
    // For now, just copy the URL to clipboard
    // In a real app, you might use the share package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon'), backgroundColor: Colors.blue),
    );
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: widget.document.name);
    DocumentCategory selectedCategory = widget.document.category;
    DateTime? selectedExpiryDate = widget.document.expiryDate;

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
                          documentId: widget.document.id,
                          name: nameController.text.trim(),
                          category: selectedCategory,
                          expiryDate: selectedExpiryDate,
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          if (success) {
                            Navigator.pop(context); // Go back to documents list
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Document updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to update document'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Document'),
            content: Text(
              'Are you sure you want to delete "${widget.document.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  final success = await _documentService.deleteDocument(widget.document.id);

                  if (mounted) {
                    if (success) {
                      Navigator.pop(context); // Go back to documents list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Document deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to delete document'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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
