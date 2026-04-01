// lib/features/chat/presentation/widgets/code_block_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

import '../../../../core/theme/app_colors.dart';

class CodeBlockWidget extends StatefulWidget {
  const CodeBlockWidget({
    super.key,
    required this.code,
    this.language = 'dart',
  });

  final String code;
  final String language;

  @override
  State<CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<CodeBlockWidget> {
  bool _copied = false;

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF12132A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  widget.language,
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _copy,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _copied
                        ? Row(
                            key: const ValueKey('copied'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_rounded,
                                  size: 14, color: AppColors.success),
                              const SizedBox(width: 4),
                              Text(
                                'Copied!',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            key: const ValueKey('copy'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.copy_rounded,
                                  size: 14, color: AppColors.darkTextSecondary),
                              const SizedBox(width: 4),
                              Text(
                                'Copy',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.darkTextSecondary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          // Highlighted code
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14),
            child: HighlightView(
              widget.code,
              language: widget.language,
              theme: atomOneDarkTheme,
              textStyle: GoogleFonts.firaCode(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
