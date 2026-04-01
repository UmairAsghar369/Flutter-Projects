import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralised text-style definitions for the TaskFlow application.
///
/// Headings use **Poppins**; body / caption text uses **Inter**.
class AppTextStyles {
  AppTextStyles._();

  // ── Heading Styles (Poppins) ───────────────────────────────────
  /// H1 – 28 px Bold Poppins.
  static TextStyle h1({Color? color}) => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
      );

  /// H2 – 22 px SemiBold Poppins.
  static TextStyle h2({Color? color}) => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      );

  /// H3 – 18 px SemiBold Poppins.
  static TextStyle h3({Color? color}) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // ── Body Styles (Inter) ────────────────────────────────────────
  /// Body – 15 px Regular Inter.
  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color,
      );

  /// Caption – 12 px Regular Inter.
  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      );

  /// Button – 14 px SemiBold Poppins.
  static TextStyle button({Color? color}) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      );
}
