import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class StatsBanner extends StatelessWidget {
  const StatsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.horizontalPadding,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _StatItem(value: '500+', label: 'Petani\nMitra'),
          _Divider(),
          _StatItem(value: '50+', label: 'Jenis\nJagung'),
          _Divider(),
          _StatItem(value: '4.9★', label: 'Rating\nPlatform'),
          _Divider(),
          _StatItem(value: '10rb+', label: 'Pelanggan\nPuas'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: Colors.white.withOpacity(0.8),
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }
}
