import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';

/// Category color palette
const List<Color> categoryColors = [
  Color(0xFF5C6BC0), // Personal – Indigo
  Color(0xFFFF7043), // Work – Deep Orange
  Color(0xFFAB47BC), // Ideas – Purple
  Color(0xFF66BB6A), // Todo – Green
  Color(0xFF26C6DA), // Other – Cyan
];

const List<Color> categoryColorsLight = [
  Color(0xFFE8EAF6), // Personal
  Color(0xFFFBE9E7), // Work
  Color(0xFFF3E5F5), // Ideas
  Color(0xFFE8F5E9), // Todo
  Color(0xFFE0F7FA), // Other
];

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = categoryColors[note.category.colorIndex];
    final bgColor = isDark
        ? catColor.withOpacity(0.15)
        : categoryColorsLight[note.category.colorIndex];
    final dateFormatted = DateFormat('MMM d, yyyy').format(note.createdAt);

    return Hero(
      tag: 'note_${note.id}',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: catColor.withOpacity(isDark ? 0.4 : 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: catColor.withOpacity(isDark ? 0.1 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag & priority
                  Row(
                    children: [
                      _buildCategoryChip(catColor, isDark),
                      const Spacer(),
                      Text(
                        note.priority.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    note.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Body preview
                  Expanded(
                    child: Text(
                      note.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? Colors.white60
                            : Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Bottom row: date + delete
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormatted,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: isDark ? Colors.white30 : Colors.black26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(Color catColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: catColor.withOpacity(isDark ? 0.3 : 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        note.category.label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: catColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
