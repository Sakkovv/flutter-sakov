import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _savePickedPhoto(XFile? picked) async {
    if (picked == null) return; // Cancel нажали -> выходим без `!`
    final docsDir = await getApplicationDocumentsDirectory();
    final savedFile = await File(
      picked.path,
    ).copy('${docsDir.path}/avatar.jpg');
    await FileImage(savedFile).evict();
    if (!mounted) return;
    await context.read<SettingsModel>().setAvatarPath(savedFile.path);
  }

  Future<void> _choosePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    await _savePickedPhoto(picked);
  }

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        final picked = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          imageQuality: 85,
        );
        await _savePickedPhoto(picked);
      case PermissionStatus.denied:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Camera permission is needed to take a profile photo.',
            ),
          ),
        );
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        await _showPermissionDialog();
    }
  }

  Future<void> _showPermissionDialog() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Camera permission required'),
        content: const Text(
          'Camera access was permanently denied. Open settings to enable it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await openAppSettings();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarPath = context.watch<SettingsModel>().avatarPath;
    final avatarFile = avatarPath != null ? File(avatarPath) : null;
    final hasFile = avatarFile != null && avatarFile.existsSync();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 56,
                backgroundImage: hasFile ? FileImage(avatarFile) : null,
                child: hasFile
                    ? null
                    : const Text('Z', style: TextStyle(fontSize: 36)),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take photo'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _choosePhoto,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose photo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
