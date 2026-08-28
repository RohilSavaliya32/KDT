import 'package:flutter/material.dart';

class AppColors {
    // ===== Core Brand Colors =====
    static const Color background = Color(0xFFFFFFFF);
    static const Color foreground = Color(0xFF0D0D0D);
    static const Color appBack = Color(0xFFF7F7F7);
    static const Color accent = Color(0xFF005234);
    static const Color accentDisabled = Color(0xFF89A99A);

    // ===== UI Elements =====
    static const Color primaryDark = Color(0xFF111111);
    static const Color cardBg = Color(0xFFFDFDFD);
    static const Color border = Color(0xFFE5E5E5);
    static const Color borderGray = Color(0xFFE0E0E0);
    static const Color lightBorder = Color(0xFFDCDCDC);
    static const Color input = Color(0xFFE5E5E5);
    static const Color divider = Color(0xFFEEEEEE);

    // ===== Text Colors =====
    static const Color textPrimary = Color(0xFF1A1A1A);
    static const Color textSecondary = Color(0xFF4A4A4A);
    static const Color mutedForeground = Color(0xFF737373);
    static const Color darkGray = Color(0xFF9E9E9E);
    static const Color iconGray = Color(0xFF757575);
    static const Color disabledGray = Color(0xFFBDBDBD);
    static const Color lightGray = Color(0xFFF5F5F5);

    // ===== Status Colors =====
    static const Color success = Color(0xFF2E7D32);
    static const Color verifiedGreen = Color(0xFF16A34A);
    static const Color error = Color(0xFFF43F5E);
    static const Color warning = Color(0xFFE88900);
    static const Color starColor = Color(0xFFFFB300);
    static const Color rating = Colors.amberAccent;

    // ===== Specialized Colors =====
    static const Color giaBlue = Color(0xFF005B9F);
    static const Color lightGreen = Color(0xFFEAF8F0);
    static const Color platinum = Color(0xFFBFBFBF);
    static const Color gold = Color(0xFFD4AF37);
    static const Color glassWhite = Color(0x1AFFFFFF);
    static const Color transparent = Colors.transparent;
    static const Color white = Colors.white;
    static const Color black = Colors.black;

    // Legacy mappings for backward compatibility during transition
    static const Color app_back = appBack;
    static const Color accent_disabel = accentDisabled;
    static const Color lightgreen = lightGreen;
    static const Color lightgray = borderGray;
    static final Color Border = Colors.black.withOpacity(0.3);
}