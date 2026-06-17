import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Gestion centralisée des permissions Android (point 10).
class PermissionHelper {
  PermissionHelper._();

  // ─── Galerie ──────────────────────────────────────────────────────────────
  static Future<bool> requestPhotos(BuildContext context) async {
    // Android 13+ : READ_MEDIA_IMAGES ; inférieur : READ_EXTERNAL_STORAGE
    final status = await Permission.photos.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied && context.mounted) {
      _openSettingsDialog(
        context,
        'Accès à la galerie',
        'L\'application a besoin d\'accéder à vos photos pour ajouter '
            'une photo de profil. Activez cette permission dans les paramètres.',
      );
    }
    return false;
  }

  // ─── Caméra ───────────────────────────────────────────────────────────────
  static Future<bool> requestCamera(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied && context.mounted) {
      _openSettingsDialog(
        context,
        'Accès à la caméra',
        'Activez l\'accès à la caméra dans les paramètres de l\'application.',
      );
    }
    return false;
  }

  // ─── Appel téléphonique ───────────────────────────────────────────────────
  static Future<bool> requestPhone(BuildContext context) async {
    final status = await Permission.phone.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied && context.mounted) {
      _openSettingsDialog(
        context,
        'Permission d\'appel',
        'Activez la permission d\'émission d\'appels dans les paramètres.',
      );
    }
    return false;
  }

  // ─── SMS ──────────────────────────────────────────────────────────────────
  static Future<bool> requestSms(BuildContext context) async {
    final status = await Permission.sms.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied && context.mounted) {
      _openSettingsDialog(
        context,
        'Permission SMS',
        'Activez la permission SMS dans les paramètres de l\'application.',
      );
    }
    return false;
  }

  // ─── Dialogue d'invitation aux paramètres système ────────────────────────
  static void _openSettingsDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Paramètres'),
          ),
        ],
      ),
    );
  }
}