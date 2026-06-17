import 'package:flutter/material.dart';
import 'package:contacts_app/models/contact.dart';
import 'package:contacts_app/widgets/contact_avatar.dart';

class ContactListItem extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ContactListItem({
    super.key,
    required this.contact,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            ContactAvatar(contact: contact, radius: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.fullName,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  if (contact.primaryPhone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      contact.primaryPhone,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}