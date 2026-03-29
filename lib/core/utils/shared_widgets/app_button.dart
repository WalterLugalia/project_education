import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

enum AppButtonSize {
  small,
  medium,
  large,
}

enum AppButtonType {
  primary,
  outlined,
  text,
}

class AppButton extends StatelessWidget{
  final String text;
  final VoidCallback? onPressed;

  final AppButtonType type;
  final AppButtonSize size;

  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  final IconData? icon;
  final bool iconFirst;

  final double? fontSize;
  final FontWeight? fontWeight;

  final bool isFullWidth;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  final bool isLoading;
  final double? elevation;

  const AppButton({
    super.key,

    required this.text,
    this.onPressed,

    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,

    this.backgroundColor,
    this.textColor,
    this.borderColor,

    this.icon,
    this.iconFirst = true,

    this.fontSize,
    this.fontWeight,

    this.isFullWidth = false,
    this.width,
    this.borderRadius,
    this.padding,
    this.isLoading = false,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =  _resolveColors(theme);
    final resolvedPadding = padding ?? _getPadding();
    final resolveRadius = borderRadius ?? _getDefaultRadius();
    final Widget innerContent = isLoading? _buildSpinner(colors.text) : _buildContent(colors.text);
    final Widget button = _buildButton(
        theme: theme,
        colors: colors,
        padding: resolvedPadding,
        radius: resolveRadius,
        child : innerContent
    );
    return _wrapWithSize(button);
  }

  Widget _buildButton({
    required ThemeData theme,
    required _AppButtonColors colors,
    required EdgeInsetsGeometry padding,
    required double radius,
    required Widget child,
  }) {
    // Shared shape used by all types
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );

    switch (type) {

      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.background,
            foregroundColor: colors.text,
            padding: padding,
            shape: shape,
            elevation: elevation ?? 6,
            shadowColor: (colors.background ?? theme.primaryColor)
                .withOpacity(0.35),
            disabledBackgroundColor: colors.background?.withOpacity(0.5),
            disabledForegroundColor: colors.text?.withOpacity(0.5),
          ),
          child: child,
        );


      case AppButtonType.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.text,
            padding: padding,
            shape: shape,
            side: BorderSide(
              color: colors.border ?? theme.primaryColor,
              width: 1.8,
            ),
          ),
          child: child,
        );


      case AppButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: colors.text,
            padding: padding,
            shape: shape,
          ),
          child: child,
        );
    }
  }


  Widget _buildContent(Color? resolvedTextColor) {
    final style = TextStyle(
      fontSize: fontSize ?? _getFontSize(),
      fontWeight: fontWeight ?? FontWeight.w700,
      color: resolvedTextColor,
      letterSpacing: 0.4,
    );

    // No icon → just text
    if (icon == null) return Text(text, style: style);

    // With icon → Row of [icon + gap + text] or [text + gap + icon]
    final iconWidget = Icon(icon, size: _getIconSize());
    final textWidget = Text(text, style: style);
    const gap = SizedBox(width: 8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: iconFirst
          ? [iconWidget, gap, textWidget]
          : [textWidget, gap, iconWidget],
    );
  }


  Widget _buildSpinner(Color? resolvedTextColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _getIconSize(),
          height: _getIconSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              resolvedTextColor ?? Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize ?? _getFontSize(),
            fontWeight: fontWeight ?? FontWeight.w700,
            color: resolvedTextColor,
          ),
        ),
      ],
    );
  }


  Widget _wrapWithSize(Widget button) {
    final h = _getHeight();

    // Full width → stretch to infinity
    if (isFullWidth) {
      return SizedBox(width: double.infinity, height: h, child: button);
    }

    // Custom exact width
    if (width != null) {
      return SizedBox(width: width, height: h, child: button);
    }

    // Natural width — just control height
    return SizedBox(height: h, child: button);
  }


  _AppButtonColors _resolveColors(ThemeData theme) {
    switch (type) {
      case AppButtonType.primary:
        return _AppButtonColors(
          background: backgroundColor ?? AppColors.accent,
          text: textColor ?? AppColors.surface,
          border: null,
        );
      case AppButtonType.outlined:
        return _AppButtonColors(
          background: backgroundColor ?? Colors.transparent,
          text: textColor ?? AppColors.accent,
          border: borderColor ?? AppColors.accent,
        );
      case AppButtonType.text:
        return _AppButtonColors(
          background: null,
          text: textColor ?? AppColors.accent,
          border: null,
        );
    }
  }

  // Padding based on size
  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  // Height based on size
  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:  return 38;
      case AppButtonSize.medium: return 48;
      case AppButtonSize.large:  return 56;
    }
  }

  // Font size based on size
  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:  return 13;
      case AppButtonSize.medium: return 15;
      case AppButtonSize.large:  return 17;
    }
  }

  // Icon size based on size
  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:  return 15;
      case AppButtonSize.medium: return 18;
      case AppButtonSize.large:  return 22;
    }
  }

  // Border radius based on size
  double _getDefaultRadius() {
    switch (size) {
      case AppButtonSize.small:  return 8;
      case AppButtonSize.medium: return 12;
      case AppButtonSize.large:  return 30; // pill shape for large
    }
  }
}


class _AppButtonColors {
  final Color? background;
  final Color? text;
  final Color? border;

  const _AppButtonColors({
    this.background,
    this.text,
    this.border,
  });
}