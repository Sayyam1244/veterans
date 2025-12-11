import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/document_service.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final DocumentService _documentService = DocumentService();
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  File? _selectedFile;
  DocumentCategory _selectedCategory = DocumentCategory.other;
  DateTime? _expiryDate;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Upload Document',
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D2D2D)),
      ),
      body: _isUploading ? _buildUploadingState() : _buildUploadForm(),
    );
  }

  Widget _buildUploadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4CAF50)),
          SizedBox(height: 20),
          Text(
            'Uploading Document...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait while your document is being uploaded securely.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File selection area
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedFile != null ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    if (_selectedFile != null) ...[
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle, size: 40, color: Color(0xFF4CAF50)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedFile!.path.split('/').last,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatFileSize(File(_selectedFile!.path).lengthSync()),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Choose Different File'),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF4CAF50)),
                      ),
                    ] else ...[
                      const Icon(Icons.cloud_upload_outlined, size: 80, color: Color(0xFF757575)),
                      const SizedBox(height: 20),
                      const Text(
                        'Select a Document',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to browse files from your device\nSupported: PDF, DOC, DOCX, JPG, PNG',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Text(
                          'Browse Files',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Document details form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Document Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
                  ),
                  const SizedBox(height: 20),

                  // Document name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Document Name *',
                      hintText: 'Enter a descriptive name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a document name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Category selection
                  DropdownButtonFormField<DocumentCategory>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items:
                        DocumentCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/${DocumentService.getCategoryIcon(category)}',
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(_getCategoryColor(category), BlendMode.srcIn),
                                ),
                                const SizedBox(width: 12),
                                Text(DocumentService.getCategoryDisplayName(category)),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Expiry date (optional)
                  GestureDetector(
                    onTap: _selectExpiryDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF757575)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Expiry Date (Optional)',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _expiryDate != null ? _formatDate(_expiryDate!) : 'No expiry date',
                                  style: const TextStyle(fontSize: 16, color: Color(0xFF2D2D2D)),
                                ),
                              ],
                            ),
                          ),
                          if (_expiryDate != null)
                            IconButton(
                              onPressed: () => setState(() => _expiryDate = null),
                              icon: const Icon(Icons.clear, color: Color(0xFF757575)),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Security notice
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.security, color: Color(0xFF4CAF50), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Secure Storage',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your documents are encrypted and stored securely in the cloud.',
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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

            const SizedBox(height: 32),

            // Upload button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _selectedFile != null ? _uploadDocument : null,
                icon: const Icon(Icons.cloud_upload, color: Colors.white),
                label: const Text(
                  'Upload Document',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //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
  //pk_live_51SG1yGP5mHW8t9OZfN7o1XLnK78qLQmA0Hd1zp2ChK4LNb6ruYeaSmXwnU88VrlEm8CyhuVb8WIeYDHIrEvjCVY500CXUtn33L
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);

        // Check file size (max 500KB)
        final fileSize = await file.length();
        if (fileSize > 500 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'File size must be less than 500KB. Current size: ${(fileSize / 1024).toStringAsFixed(1)}KB',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFile = file;
          // Auto-fill document name from file name if not already set
          if (_nameController.text.isEmpty) {
            final fileName = result.files.first.name;
            final nameWithoutExtension = fileName.substring(0, fileName.lastIndexOf('.'));
            _nameController.text = nameWithoutExtension.replaceAll('_', ' ').replaceAll('-', ' ');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error selecting file: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
    );

    if (date != null) {
      setState(() {
        _expiryDate = date;
      });
    }
  }

  Future<void> _uploadDocument() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final documentId = await _documentService.uploadDocument(
        file: _selectedFile!,
        documentName: _nameController.text.trim(),
        category: _selectedCategory,
        expiryDate: _expiryDate,
        metadata: {'uploadedFromApp': true, 'originalFileName': _selectedFile!.path.split('/').last},
      );

      if (mounted) {
        if (documentId != null) {
          Navigator.pop(context, true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document uploaded successfully!'), backgroundColor: Colors.green),
          );
        } else {
          setState(() {
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload document. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading document: $e'), backgroundColor: Colors.red));
      }
    }
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
}
