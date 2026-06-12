import 'package:corn_market/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CornAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? leading;
  final Color? backgroundColor;

  const CornAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.leading,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColors.darkBackground : AppColors.background);
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  size: 20, color: textColor),
              onPressed: () => Navigator.pop(context),
            )
          : leading,
      title: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(color: textColor),
      ),
      actions: actions,
    );
  }
}
