import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/app_theme.dart';

class StartupAvatar extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final double size;

  const StartupAvatar({super.key, required this.name, this.logoUrl, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();

    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: CachedNetworkImage(
          imageUrl: logoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _Fallback(initials: initials, size: size),
          errorWidget: (_, __, ___) => _Fallback(initials: initials, size: size),
        ),
      );
    }
    return _Fallback(initials: initials, size: size);
  }
}

class _Fallback extends StatelessWidget {
  final String initials;
  final double size;
  const _Fallback({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
