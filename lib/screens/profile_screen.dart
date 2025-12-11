import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/loading_service.dart';
import '../services/snackbar_service.dart';
import '../services/profile_picture_service.dart';
import '../widgets/notification_summary_widget.dart';
import 'personal_info_screen.dart';
import 'emergency_contacts_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ProfilePictureService _profilePictureService = ProfilePictureService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserData();
      if (mounted) {
        setState(() {
          _userData = userData;
          _profileImageUrl = userData?['profileImageUrl'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        SnackBarService.showError(context, 'Failed to load profile data');
      }
    }
  }

  Future<void> _updateProfilePicture() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfilePicture();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      LoadingService.show(context, message: 'Picking image...');
      final imageFile = await _profilePictureService.pickImage(source: source);
      LoadingService.hide();

      if (imageFile != null) {
        LoadingService.show(context, message: 'Uploading image...');
        final imageUrl = await _profilePictureService.uploadProfilePicture(imageFile);
        LoadingService.hide();

        if (imageUrl != null) {
          if (mounted) {
            setState(() {
              _profileImageUrl = imageUrl;
            });
            SnackBarService.showSuccess(context, 'Profile picture updated successfully');
          }
        } else {
          if (mounted) {
            SnackBarService.showError(context, 'Failed to upload profile picture');
          }
        }
      }
    } catch (e) {
      LoadingService.hide();
      if (mounted) {
        SnackBarService.showError(context, 'Error updating profile picture');
      }
    }
  }

  Future<void> _removeProfilePicture() async {
    try {
      LoadingService.show(context, message: 'Removing photo...');
      final success = await _profilePictureService.deleteProfilePicture();
      LoadingService.hide();

      if (success && mounted) {
        setState(() {
          _profileImageUrl = '';
        });
        SnackBarService.showSuccess(context, 'Profile picture removed successfully');
      } else if (mounted) {
        SnackBarService.showError(context, 'Failed to remove profile picture');
      }
    } catch (e) {
      LoadingService.hide();
      if (mounted) {
        SnackBarService.showError(context, 'Error removing profile picture');
      }
    }
  }

  Future<void> _signOut() async {
    try {
      LoadingService.show(context, message: 'Signing out...');
      await _authService.signOut();
      LoadingService.hide();

      if (mounted) {
        SnackBarService.showSuccess(context, 'Signed out successfully');
        // Navigation will be handled by AuthWrapper in main.dart
      }
    } catch (e) {
      LoadingService.hide();
      if (mounted) {
        SnackBarService.showError(context, 'Failed to sign out');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63))),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D)),
              ),

              const SizedBox(height: 24),

              // User Info Card
              if (_userData != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                      // Profile Picture
                      GestureDetector(
                        onTap: _updateProfilePicture,
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color:
                                    _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                        ? Colors.transparent
                                        : const Color(0xFFE91E63).withOpacity(0.1),
                                shape: BoxShape.circle,
                                image:
                                    _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                        ? DecorationImage(
                                          image: NetworkImage(_profileImageUrl!),
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                              ),
                              child:
                                  _profileImageUrl == null || _profileImageUrl!.isEmpty
                                      ? Center(
                                        child: Text(
                                          (_userData!['name'] as String? ?? 'U')
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFE91E63),
                                          ),
                                        ),
                                      )
                                      : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE91E63),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      Text(
                        _userData!['name'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Email
                      Text(
                        _userData!['email'] ?? 'No email',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
                      ),
                      const SizedBox(height: 8),

                      // Veteran Badge
                      if (_userData!['isVeteran'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Veteran',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Menu Items
              Expanded(
                child: ListView(
                  children: [
                    // Notification Summary
                    const NotificationSummaryWidget(),
                    const SizedBox(height: 16),
                    
                    _buildMenuItem('Personal Information', Icons.person_outline, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
                      ).then((_) => _loadUserData()); // Reload data when returning
                    }),
                    _buildMenuItem('Emergency Contacts', Icons.emergency_outlined, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmergencyContactsScreen()),
                      );
                    }),
                    _buildMenuItem('Settings', Icons.settings_outlined, () {
                      // TODO: Navigate to settings screen
                      SnackBarService.showInfo(context, 'Settings available in Settings tab');
                    }),
                    _buildMenuItem('Help & Support', Icons.help_outline, () {
                      // TODO: Navigate to help screen
                      SnackBarService.showInfo(context, 'Feature coming soon');
                    }),
                    _buildMenuItem('Privacy Policy', Icons.privacy_tip_outlined, () {
                      // TODO: Navigate to privacy policy screen
                      SnackBarService.showInfo(context, 'Feature coming soon');
                    }),
                    _buildMenuItem('Sign Out', Icons.logout, _signOut, isDestructive: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF757575)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isDestructive ? Colors.red : const Color(0xFF2D2D2D),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: isDestructive ? Colors.red : const Color(0xFF9E9E9E)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white,
      ),
    );
  }
}
