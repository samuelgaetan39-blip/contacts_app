import 'dart:io';
import 'package:flutter/material.dart';
import 'package:contacts_app/models/contact.dart';

class ContactAvatar extends StatelessWidget {
  final Contact contact;
  final double radius;
  final VoidCallback? onTap;

  const ContactAvatar({
    super.key,
    required this.contact,
    this.radius = 28,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final image  = contact.imagePath;

    ImageProvider? provider;
    if (image != null && image.isNotEmpty) {
      if (image.startsWith('http')) {
        provider = NetworkImage(image);
      } else {
        provider = FileImage(File(image));
      }
    }

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: _avatarColor(contact.initials, scheme),
      backgroundImage: provider,
      child: provider == null
          ? Text(
              contact.initials,
              style: TextStyle(
                fontSize: radius * 0.6,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )
          : null,
    );

    return onTap != null
        ? GestureDetector(onTap: onTap, child: avatar)
        : avatar;
  }

  static Color _avatarColor(String initials, ColorScheme scheme) {
    const colors = [
      Color(0xFF007AFF),
      Color(0xFF34C759),
      Color(0xFFFF9500),
      Color(0xFFFF3B30),
      Color(0xFF5856D6),
      Color(0xFFFF2D55),
      Color(0xFF00C7BE),
      Color(0xFFAF52DE),
    ];
    if (initials.isEmpty) return colors[0];
    return colors[initials.codeUnitAt(0) % colors.length];
  }
}