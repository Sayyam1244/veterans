import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/loading_service.dart';
import '../services/snackbar_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _emergencyContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      final userData = await _authService.getUserData();
      if (mounted && userData != null) {
        setState(() {
          _emergencyContacts = List<Map<String, dynamic>>.from(userData['emergencyContacts'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        SnackBarService.showError(context, 'Failed to load emergency contacts');
      }
    }
  }

  Future<void> _saveEmergencyContacts() async {
    try {
      LoadingService.show(context, message: 'Saving contacts...');

      final updatedData = {'emergencyContacts': FieldValue.arrayUnion(_emergencyContacts)};

      final success = await _authService.updateUserData(updatedData);
      LoadingService.hide();

      if (mounted) {
        if (success) {
          SnackBarService.showSuccess(context, 'Emergency contacts updated successfully');
        } else {
          SnackBarService.showError(context, 'Failed to update emergency contacts');
        }
      }
    } catch (e) {
      LoadingService.hide();
      if (mounted) {
        SnackBarService.showError(context, 'Error updating contacts');
      }
    }
  }

  void _addEmergencyContact() {
    _showContactDialog();
  }

  void _editEmergencyContact(int index) {
    _showContactDialog(contact: _emergencyContacts[index], index: index);
  }

  void _deleteEmergencyContact(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Contact'),
          content: Text('Are you sure you want to delete ${_emergencyContacts[index]['name']}?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                setState(() {
                  _emergencyContacts.removeAt(index);
                });
                Navigator.of(context).pop();
                _saveEmergencyContacts();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog({Map<String, dynamic>? contact, int? index}) {
    final nameController = TextEditingController(text: contact?['name'] ?? '');
    final phoneController = TextEditingController(text: contact?['phone'] ?? '');
    final relationshipController = TextEditingController(text: contact?['relationship'] ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(contact == null ? 'Add Emergency Contact' : 'Edit Emergency Contact'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter contact name';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: relationshipController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter relationship';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    hintText: 'e.g., Spouse, Parent, Sibling',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newContact = {
                    'name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'relationship': relationshipController.text.trim(),
                  };

                  setState(() {
                    if (index != null) {
                      _emergencyContacts[index] = newContact;
                    } else {
                      _emergencyContacts.add(newContact);
                    }
                  });

                  Navigator.of(context).pop();
                  _saveEmergencyContacts();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E63)),
              child: Text(contact == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63))),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
        ),
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(color: Color(0xFF2D2D2D), fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _addEmergencyContact, icon: const Icon(Icons.add, color: Color(0xFFE91E63))),
        ],
      ),
      body: SafeArea(child: _emergencyContacts.isEmpty ? _buildEmptyState() : _buildContactsList()),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.contact_emergency_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'No Emergency Contacts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              'Add emergency contacts for quick access during critical situations.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.4),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _addEmergencyContact,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add First Contact',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _emergencyContacts.length,
            itemBuilder: (context, index) {
              final contact = _emergencyContacts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        contact['name'].substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    contact['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(contact['phone'], style: const TextStyle(fontSize: 14, color: Color(0xFF757575))),
                      const SizedBox(height: 2),
                      Text(
                        contact['relationship'],
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editEmergencyContact(index);
                      } else if (value == 'delete') {
                        _deleteEmergencyContact(index);
                      }
                    },
                    itemBuilder:
                        (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                  ),
                ),
              );
            },
          ),
        ),

        // Add Contact Button
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _addEmergencyContact,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Emergency Contact',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
