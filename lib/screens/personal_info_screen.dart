import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/loading_service.dart';
import '../services/snackbar_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  bool _isLoading = true;
  bool _isVeteran = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserData();
      if (mounted && userData != null) {
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _dobController.text = userData['dateOfBirth'] ?? '';
          _isVeteran = userData['isVeteran'] ?? true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        SnackBarService.showError(context, 'Failed to load personal information');
      }
    }
  }

  Future<void> _savePersonalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      LoadingService.show(context, message: 'Saving information...');

      final updatedData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dateOfBirth': _dobController.text.trim(),
        'isVeteran': _isVeteran,
      };

      final success = await _authService.updateUserData(updatedData);
      LoadingService.hide();

      if (mounted) {
        if (success) {
          SnackBarService.showSuccess(context, 'Personal information updated successfully');
          Navigator.pop(context);
        } else {
          SnackBarService.showError(context, 'Failed to update personal information');
        }
      }
    } catch (e) {
      LoadingService.hide();
      if (mounted) {
        SnackBarService.showError(context, 'Error updating information');
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)), // 25 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFE91E63))),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
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
          'Personal Information',
          style: TextStyle(color: Color(0xFF2D2D2D), fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter your full name',
                            hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF9E9E9E)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE91E63)),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Email Field (Read Only)
                        TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF9E9E9E)),
                            suffixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9E9E9E)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            fillColor: const Color(0xFFF5F5F5),
                            filled: true,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),

                        const SizedBox(height: 8),
                        const Text(
                          'Email cannot be changed for security reasons',
                          style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                        ),

                        const SizedBox(height: 20),

                        // Phone Field
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'Enter your phone number',
                            hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                            prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF9E9E9E)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE91E63)),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Date of Birth Field
                        TextFormField(
                          controller: _dobController,
                          readOnly: true,
                          onTap: _selectDate,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please select your date of birth';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            hintText: 'Select your date of birth',
                            hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                            prefixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF9E9E9E)),
                            suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF9E9E9E)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE91E63)),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Veteran Status
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.military_tech_outlined, color: Color(0xFF9E9E9E)),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  'Veteran Status',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF2D2D2D)),
                                ),
                              ),
                              Switch(
                                value: _isVeteran,
                                onChanged: (value) {
                                  setState(() {
                                    _isVeteran = value;
                                  });
                                },
                                activeTrackColor: const Color(0xFFE91E63),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _savePersonalInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
