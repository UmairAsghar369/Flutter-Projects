import 'package:flutter/material.dart';
import '../providers/cv_provider.dart';

/// Profile header shown in CvViewScreen — reads name from CvProvider.
class ProfileHeader extends StatelessWidget {
  final bool isProfessional;

  const ProfileHeader({
    super.key,
    required this.isProfessional,
  });

  @override
  Widget build(BuildContext context) {
    final provider = CvProvider.of(context);
    final cv = provider.cv;

    // Derive initials from name (up to 2 letters)
    final nameParts = cv.name.trim().split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : cv.name.isNotEmpty
            ? cv.name[0].toUpperCase()
            : '?';

    return Column(
      children: [
        // ─── Avatar ───
        Hero(
          tag: 'cv-avatar',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ─── Name ───
        Text(
          cv.name.isNotEmpty ? cv.name : 'Your Name',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.4,
            fontStyle: cv.name.isEmpty ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        const SizedBox(height: 4),

        // ─── Subtitle toggles with animation ───
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            isProfessional ? 'Professional CV' : 'Hobby-Based CV',
            key: ValueKey(isProfessional),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.78),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // ─── Contact chips ───
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (cv.email.isNotEmpty) _contactChip(Icons.email_rounded, cv.email),
            if (cv.email.isNotEmpty && cv.phone.isNotEmpty) const SizedBox(width: 10),
            if (cv.phone.isNotEmpty) _contactChip(Icons.phone_rounded, cv.phone),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _contactChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
