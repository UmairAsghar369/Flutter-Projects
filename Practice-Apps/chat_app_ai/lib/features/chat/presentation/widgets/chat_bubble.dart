// lib/features/chat/presentation/widgets/chat_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../features/chat/domain/message_model.dart';
import 'code_block_widget.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final MessageModel message;

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    return _isUser ? _UserBubble(message: message) : _AiBubble(message: message);
  }
}

// ─── User bubble ──────────────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});
  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => Helpers.copyToClipboard(context, message.content),
      child: Padding(
        padding: const EdgeInsets.only(left: 60, right: 16, top: 4, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.purplePrimary, AppColors.accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purplePrimary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                message.content,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const Gap(4),
            Text(
              Helpers.formatTime(message.timestamp),
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.15, end: 0, curve: Curves.easeOut);
  }
}

// ─── AI bubble ────────────────────────────────────────────────────────────────

class _AiBubble extends StatelessWidget {
  const _AiBubble({required this.message});
  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return GestureDetector(
      onLongPress: () => Helpers.copyToClipboard(context, message.content),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 60, top: 4, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // AI avatar
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.purplePrimary, AppColors.accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 16),
            ),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border.all(color: border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: message.content.isEmpty
                        ? _shimmerPlaceholder(isDark)
                        : MarkdownBody(
                            data: message.content,
                            selectable: false,
                            builders: {
                              'code': _CodeBlockBuilder(),
                            },
                            extensionSet: md.ExtensionSet(
                              md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                              [
                                md.EmojiSyntax(),
                                ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
                              ],
                            ),
                            styleSheet: MarkdownStyleSheet(
                              p: GoogleFonts.poppins(
                                fontSize: 14,
                                color: textColor,
                                height: 1.6,
                              ),
                              strong: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                              em: GoogleFonts.poppins(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: textColor,
                              ),
                              h1: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                              h2: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                              h3: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                              listBullet: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.purplePrimary,
                              ),
                              code: GoogleFonts.firaCode(
                                fontSize: 13,
                                backgroundColor: isDark
                                    ? const Color(0xFF1A1B2E)
                                    : const Color(0xFFEEEEFF),
                                color: AppColors.purpleLight,
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: const Color(0xFF1A1B2E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              blockquoteDecoration: BoxDecoration(
                                color: AppColors.purplePrimary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: const Border(
                                  left: BorderSide(
                                    color: AppColors.purplePrimary,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  const Gap(4),
                  Text(
                    Helpers.formatTime(message.timestamp),
                    style: GoogleFonts.poppins(fontSize: 10, color: textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _shimmerPlaceholder(bool isDark) {
    final color = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < 2; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 12,
            width: i == 0 ? 180 : 120,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(begin: 0.3, end: 0.8, duration: 800.ms),
      ],
    );
  }
}

// ─── Custom markdown code block builder ───────────────────────────────────────

class _CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = element.textContent;
    final lang = element.attributes['class']?.replaceFirst('language-', '') ?? 'code';
    return CodeBlockWidget(code: code.trim(), language: lang);
  }
}
