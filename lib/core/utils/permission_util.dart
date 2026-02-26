import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  static Future<bool> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.location,
      // Add other permissions here if needed
    ].request();

    // Check if all permissions are granted
    return statuses.values.every((status) => status.isGranted);
  }

  static Future<void> showPermissionDeniedDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
            'This app needs camera and location permissions to function. Please grant them in the app settings.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Open Settings'),
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  static Future<bool> handlePermissions(BuildContext context) async {
     Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.location,
    ].request();

    final cameraStatus = statuses[Permission.camera];
    final locationStatus = statuses[Permission.location];

    if (cameraStatus == PermissionStatus.granted && locationStatus == PermissionStatus.granted) {
      return true;
    }

    if (cameraStatus == PermissionStatus.permanentlyDenied || locationStatus == PermissionStatus.permanentlyDenied) {
      await showPermissionDeniedDialog(context);
      return false;
    }
    
    // If we are here, it means permissions were denied but not permanently. 
    // The request() call above already prompted the user.
    // We can show a less intrusive snackbar or just return false.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera and Location permissions are required.')),
    );
    return false;
  }
}
