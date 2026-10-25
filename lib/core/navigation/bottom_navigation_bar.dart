import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Container(
            height: 64, 
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2C2C2E).withOpacity(0.85)
                  : const Color(0xFFF2F2F7).withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.black.withOpacity(0.06),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: !isDark
                      ? SvgPicture.asset(
                          'assets/images/nav/dark_chat_outlined.svg',
                        )
                      : SvgPicture.asset('assets/images/nav/chat_outlined.svg'),
                  activeIcon: !isDark
                      ? SvgPicture.asset('assets/images/nav/dark_chat.svg')
                      : SvgPicture.asset('assets/images/nav/chat.svg'),
                  label: 'Chats',
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => navigationShell.goBranch(
                    0,
                    initialLocation: navigationShell.currentIndex == 0,
                  ),
                ),
                _NavBarItem(
                  icon: const Icon(Icons.settings_outlined),
                  activeIcon: const Icon(Icons.settings_rounded),
                  label: 'Settings',
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => navigationShell.goBranch(
                    1,
                    initialLocation: navigationShell.currentIndex == 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final Widget icon;
  final Widget activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = isDark ? Colors.white : Colors.black;
    final Color inactiveColor = isDark ? Colors.white38 : Colors.black38;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior
          .opaque, 
      child: SizedBox(
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedTheme(
              data: ThemeData(
                iconTheme: IconThemeData(
                  color: isSelected ? activeColor : inactiveColor,
                  size: 24,
                ),
              ),
              child: isSelected ? activeIcon : icon,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
