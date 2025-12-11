import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permissions
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permissions
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print('Location services are disabled');
        }
        return null;
      }

      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied');
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('Location permissions are permanently denied');
        }
        return null;
      }

      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current position: $e');
      }
      return null;
    }
  }

  // Update user location in Firestore
  Future<bool> updateUserLocation() async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return false;

      final position = await getCurrentPosition();
      if (position == null) return false;

      await _firestore.collection('users').doc(currentUserId).update({
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user location: $e');
      }
      return false;
    }
  }

  // Calculate distance between two coordinates in kilometers
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convert to km
  }

  // Get nearby users within specified distance (in kilometers)
  Future<List<Map<String, dynamic>>> getNearbyUsers({double maxDistance = 50.0}) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return [];

      // Get current user's location
      final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
      final currentUserData = currentUserDoc.data();

      if (currentUserData == null || currentUserData['location'] == null) {
        return [];
      }

      final currentLat = currentUserData['location']['latitude'] as double;
      final currentLon = currentUserData['location']['longitude'] as double;

      // Get all users with device discovery enabled
      final usersSnapshot =
          await _firestore
              .collection('users')
              .where('preferences.deviceDiscoveryEnabled', isEqualTo: true)
              .get();

      final nearbyUsers = <Map<String, dynamic>>[];

      for (final doc in usersSnapshot.docs) {
        if (doc.id == currentUserId) continue; // Skip current user

        final userData = doc.data();
        final userLocation = userData['location'];

        if (userLocation == null) continue;

        final userLat = userLocation['latitude'] as double;
        final userLon = userLocation['longitude'] as double;

        final distance = calculateDistance(currentLat, currentLon, userLat, userLon);

        if (distance <= maxDistance) {
          nearbyUsers.add({
            'id': doc.id,
            'firstName': userData['firstName'] ?? 'Unknown',
            'lastName': userData['lastName'] ?? '',
            'email': userData['email'] ?? '',
            'profilePicture': userData['profilePicture'],
            'distance': distance,
            'location': userLocation,
            'preferences': userData['preferences'] ?? {},
          });
        }
      }

      // Sort by distance
      nearbyUsers.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      return nearbyUsers;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting nearby users: $e');
      }
      return [];
    }
  }

  // Stream of nearby users (real-time updates)
  Stream<List<Map<String, dynamic>>> getNearbyUsersStream({double maxDistance = 50.0}) {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .where('preferences.deviceDiscoveryEnabled', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
          try {
            // Get current user's location
            final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
            final currentUserData = currentUserDoc.data();

            if (currentUserData == null || currentUserData['location'] == null) {
              return <Map<String, dynamic>>[];
            }

            final currentLat = currentUserData['location']['latitude'] as double;
            final currentLon = currentUserData['location']['longitude'] as double;

            final nearbyUsers = <Map<String, dynamic>>[];

            for (final doc in snapshot.docs) {
              if (doc.id == currentUserId) continue; // Skip current user

              final userData = doc.data();
              final userLocation = userData['location'];

              if (userLocation == null) continue;

              final userLat = userLocation['latitude'] as double;
              final userLon = userLocation['longitude'] as double;

              final distance = calculateDistance(currentLat, currentLon, userLat, userLon);

              if (distance <= maxDistance) {
                nearbyUsers.add({
                  'id': doc.id,
                  'firstName': userData['firstName'] ?? 'Unknown',
                  'lastName': userData['lastName'] ?? '',
                  'email': userData['email'] ?? '',
                  'profilePicture': userData['profilePicture'],
                  'distance': distance,
                  'location': userLocation,
                  'preferences': userData['preferences'] ?? {},
                });
              }
            }

            // Sort by distance
            nearbyUsers.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

            return nearbyUsers;
          } catch (e) {
            if (kDebugMode) {
              print('Error in nearby users stream: $e');
            }
            return <Map<String, dynamic>>[];
          }
        });
  }

  // Enable/disable device discovery for current user
  Future<bool> updateDeviceDiscoveryStatus(bool enabled) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return false;

      await _firestore.collection('users').doc(currentUserId).update({
        'preferences.deviceDiscoveryEnabled': enabled,
        'preferences.lastUpdated': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating device discovery status: $e');
      }
      return false;
    }
  }

  // Update discovery preferences (distance, age range, etc.)
  Future<bool> updateDiscoveryPreferences({
    double? maxDistance,
    int? minAge,
    int? maxAge,
    String? gender,
  }) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return false;

      final updates = <String, dynamic>{'preferences.lastUpdated': FieldValue.serverTimestamp()};

      if (maxDistance != null) {
        updates['preferences.discoveryDistance'] = maxDistance;
      }
      if (minAge != null) {
        updates['preferences.discoveryMinAge'] = minAge;
      }
      if (maxAge != null) {
        updates['preferences.discoveryMaxAge'] = maxAge;
      }
      if (gender != null) {
        updates['preferences.discoveryGender'] = gender;
      }

      await _firestore.collection('users').doc(currentUserId).update(updates);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating discovery preferences: $e');
      }
      return false;
    }
  }
}
