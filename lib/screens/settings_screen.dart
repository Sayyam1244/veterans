import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/loading_service.dart';
import '../services/snackbar_service.dart';
import '../services/location_service.dart';
import 'nearby_users_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  bool _isLoading = true;

  // Settings state
  bool _notificationsEnabled = true;
  bool _deviceDiscoveryEnabled = true;
  String _profileVisibility = 'public';
  String _postVisibility = 'public';
  double _discoveryDistance = 50.0;
  int _minAge = 18;
  int _maxAge = 65;
  String _discoveryGender = 'all';

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    try {
      final userData = await _authService.getUserData();
      if (mounted && userData != null) {
        final preferences = userData['preferences'] ?? {};
        setState(() {
          _notificationsEnabled = preferences['notifications'] ?? true;
          _deviceDiscoveryEnabled = preferences['deviceDiscoveryEnabled'] ?? true;
          _profileVisibility = preferences['profileVisibility'] ?? 'public';
          _postVisibility = preferences['postVisibility'] ?? 'public';
          _discoveryDistance = (preferences['discoveryDistance'] ?? 50.0).toDouble();
          _minAge = preferences['discoveryMinAge'] ?? 18;
          _maxAge = preferences['discoveryMaxAge'] ?? 65;
          _discoveryGender = preferences['discoveryGender'] ?? 'all';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        SnackBarService.showError(context, 'Failed to load settings');
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      LoadingService.show(context, message: 'Saving settings...');

      final settingsData = {
        'preferences': {
          'notifications': _notificationsEnabled,
          'deviceDiscoveryEnabled': _deviceDiscoveryEnabled,
          'profileVisibility': _profileVisibility,
          'postVisibility': _postVisibility,
          'discoveryDistance': _discoveryDistance,
          'discoveryMinAge': _minAge,
          'discoveryMaxAge': _maxAge,
          'discoveryGender': _discoveryGender,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
      };

      final success = await _authService.updateUserData(settingsData);

      // Also update location service preferences
      if (_deviceDiscoveryEnabled) {
        await _locationService.updateDeviceDiscoveryStatus(true);
        await _locationService.updateDiscoveryPreferences(
          maxDistance: _discoveryDistance,
          minAge: _minAge,
          maxAge: _maxAge,
          gender: _discoveryGender,
        );
      } else {
        await _locationService.updateDeviceDiscoveryStatus(false);
      }

      LoadingService.hide();

      if (mounted) {
        if (success) {
          SnackBarService.showSuccess(context, 'Settings saved successfully');
        } else {
          SnackBarService.showError(context, 'Failed to save settings');
        }
      }
    } catch (e) {
      LoadingService.hide();
      if (mounted) {
        SnackBarService.showError(context, 'Error saving settings');
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement password change logic
                Navigator.of(context).pop();
                SnackBarService.showInfo(context, 'Password change feature coming soon');
              },
              child: const Text('Change'),
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
        automaticallyImplyLeading: false,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Settings Section
                  _buildSectionHeader('Personal Settings'),
                  const SizedBox(height: 16),
                  _buildSettingItem('Change Password', Icons.chevron_right, _showChangePasswordDialog),
                  _buildToggleSettingItem('Notification Preferences', _notificationsEnabled, (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  }),

                  const SizedBox(height: 32),

                  // Discovery Settings Section
                  _buildSectionHeader('Discovery Settings'),
                  const SizedBox(height: 16),
                  _buildToggleSettingItem(
                    'Device Discovery',
                    _deviceDiscoveryEnabled,
                    (value) async {
                      setState(() {
                        _deviceDiscoveryEnabled = value;
                      });
                      await _locationService.updateDeviceDiscoveryStatus(value);
                      if (value) {
                        await _locationService.updateUserLocation();
                      }
                    },
                    subtitle: 'Allow other veterans to find you nearby',
                  ),
                  if (_deviceDiscoveryEnabled)
                    _buildSettingItem('View Nearby Veterans', Icons.people, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NearbyUsersScreen()),
                      );
                    }, subtitle: 'See veterans near you'),
                  _buildSettingItem(
                    'Distance',
                    Icons.chevron_right,
                    _showDistanceDialog,
                    subtitle: 'Max distance: ${_discoveryDistance.toInt()} km',
                  ),
                  _buildSettingItem(
                    'Age Range',
                    Icons.chevron_right,
                    _showAgeRangeDialog,
                    subtitle: 'Ages $_minAge - $_maxAge',
                  ),
                  _buildDropdownSettingItem(
                    'Gender Preference',
                    _discoveryGender,
                    ['all', 'male', 'female', 'other'],
                    (value) {
                      setState(() {
                        _discoveryGender = value!;
                      });
                    },
                    subtitle: 'Show veterans of selected gender',
                  ),

                  const SizedBox(height: 32),

                  // Privacy Settings Section
                  _buildSectionHeader('Privacy Settings'),
                  const SizedBox(height: 16),
                  _buildDropdownSettingItem(
                    'Profile Visibility',
                    _profileVisibility,
                    ['public', 'private', 'friends'],
                    (value) {
                      setState(() {
                        _profileVisibility = value!;
                      });
                    },
                    subtitle: 'Control who can see your profile',
                  ),
                  _buildDropdownSettingItem(
                    'Post Visibility',
                    _postVisibility,
                    ['public', 'private', 'friends'],
                    (value) {
                      setState(() {
                        _postVisibility = value!;
                      });
                    },
                    subtitle: 'Control who can see your posts',
                  ),

                  const SizedBox(height: 32),

                  // Save Changes Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE879A6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
    );
  }

  Widget _buildSettingItem(String title, IconData trailingIcon, VoidCallback onTap, {String? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
        ),
        subtitle:
            subtitle != null
                ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))
                : null,
        trailing: Icon(trailingIcon, color: const Color(0xFF9CA3AF), size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleSettingItem(String title, bool value, ValueChanged<bool> onChanged, {String? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
        ),
        subtitle:
            subtitle != null
                ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))
                : null,
        trailing: Switch(value: value, onChanged: onChanged, activeTrackColor: const Color(0xFFE91E63)),
      ),
    );
  }

  Widget _buildDropdownSettingItem(
    String title,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged, {
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
        ),
        subtitle:
            subtitle != null
                ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))
                : null,
        trailing: DropdownButton<String>(
          value: value,
          items:
              options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option.substring(0, 1).toUpperCase() + option.substring(1),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
          underline: Container(),
        ),
      ),
    );
  }

  void _showDistanceDialog() {
    double tempDistance = _discoveryDistance;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Discovery Distance'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Show veterans within ${tempDistance.round()} km',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: tempDistance,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '${tempDistance.round()} km',
                    onChanged: (value) {
                      setState(() {
                        tempDistance = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _discoveryDistance = tempDistance;
                    });
                    _saveSettings();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAgeRangeDialog() {
    double tempMinAge = _minAge.toDouble();
    double tempMaxAge = _maxAge.toDouble();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Age Range'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Show veterans aged ${tempMinAge.round()} - ${tempMaxAge.round()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text('Minimum Age:'),
                  Slider(
                    value: tempMinAge,
                    min: 18,
                    max: 80,
                    divisions: 62,
                    label: '${tempMinAge.round()}',
                    onChanged: (value) {
                      setState(() {
                        tempMinAge = value;
                        if (tempMinAge >= tempMaxAge) {
                          tempMaxAge = tempMinAge + 1;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text('Maximum Age:'),
                  Slider(
                    value: tempMaxAge,
                    min: 18,
                    max: 80,
                    divisions: 62,
                    label: '${tempMaxAge.round()}',
                    onChanged: (value) {
                      setState(() {
                        tempMaxAge = value;
                        if (tempMaxAge <= tempMinAge) {
                          tempMinAge = tempMaxAge - 1;
                        }
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _minAge = tempMinAge.round();
                      _maxAge = tempMaxAge.round();
                    });
                    _saveSettings();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
