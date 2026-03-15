import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rockster/core/theme/app_colors.dart';



/// Glassmorphism Bottom Navigation Bar
/// Features: Frosted glass effect, line-art icons, orange fill when active
class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.0,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    items.length,
                    (index) => _NavButton(
                      item: items[index],
                      isSelected: currentIndex == index,
                      onTap: () => onTap(index),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

class _NavButton extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? (item.activeIcon ?? item.icon) : item.icon,
              color: isSelected
                  ? AppColors.burntTerracotta
                  : AppColors.textSecondaryLight,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.burntTerracotta
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
