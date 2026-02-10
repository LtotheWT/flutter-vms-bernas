import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.info,
  });

  final Color success;
  final Color warning;
  final Color info;

  @override
  AppSemanticColors copyWith({Color? success, Color? warning, Color? info}) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppSemanticColors lerp(
    covariant ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) {
      return this;
    }

    return AppSemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
    );
  }
}

class AppTheme {
  const AppTheme._();

  static final ColorScheme lightColorScheme = const ColorScheme.light(
    primary: AppColors.brand500,
    onPrimary: AppColors.neutral0,
    primaryContainer: AppColors.brand100,
    onPrimaryContainer: AppColors.brand900,
    secondary: AppColors.info500,
    onSecondary: AppColors.neutral0,
    secondaryContainer: Color(0xFFD9E4FA),
    onSecondaryContainer: Color(0xFF1C3E85),
    tertiary: AppColors.warning500,
    onTertiary: AppColors.neutral0,
    tertiaryContainer: Color(0xFFF9E8CC),
    onTertiaryContainer: Color(0xFF6E4200),
    error: AppColors.error500,
    onError: AppColors.neutral0,
    errorContainer: Color(0xFFF7D8D5),
    onErrorContainer: Color(0xFF7A201A),
    surface: AppColors.neutral50,
    onSurface: AppColors.neutral900,
    surfaceContainerHighest: AppColors.neutral200,
    onSurfaceVariant: AppColors.neutral700,
    outline: AppColors.neutral300,
    shadow: AppColors.neutral900,
    scrim: AppColors.neutral900,
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: AppColors.neutral50,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      tabBarTheme: TabBarThemeData(dividerHeight: 0),
      extensions: const [
        AppSemanticColors(
          success: AppColors.success500,
          warning: AppColors.warning500,
          info: AppColors.info500,
        ),
      ],
    );
  }
}
