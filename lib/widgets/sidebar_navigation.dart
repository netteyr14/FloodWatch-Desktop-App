// lib/widgets/sidebar_navigation.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final width = isCollapsed ? 72.0 : 230.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Light: keep original green.
    // Dark: use much darker sidebar from AppTheme.
    final Color sidebarColor =
        isDark ? AppTheme.darkSidebar : const Color(0xFFE4EEBC);

    final Color footerTextColor =
        isDark ? AppTheme.darkSidebarText : Colors.black54;

    final Color toggleColor =
        isDark ? AppTheme.darkSidebarText : Colors.black87;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      color: sidebarColor,
      child: Column(
        children: [
          const SizedBox(height: 24),

          // App icon / logo area
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.water_drop, color: Colors.black87),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'FloodWatch',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          else
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(Icons.water_drop, color: Colors.black87),
            ),

          const SizedBox(height: 24),

          // NAV ITEMS
          _NavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            index: 0,
            selected: selectedIndex == 0,
            collapsed: isCollapsed,
            onTap: () => onSelect(0),
          ),
          _NavItem(
            icon: Icons.engineering,
            label: 'Operations',
            index: 1,
            selected: selectedIndex == 1,
            collapsed: isCollapsed,
            onTap: () => onSelect(1),
          ),
          _NavItem(
            icon: Icons.person,
            label: 'Profile',
            index: 2,
            selected: selectedIndex == 2,
            collapsed: isCollapsed,
            onTap: () => onSelect(2),
          ),

          const Spacer(),

          // Footer text (hidden when collapsed)
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "FloodWatch v1.0",
                  style: TextStyle(
                    fontSize: 12,
                    color: footerTextColor,
                  ),
                ),
              ),
            ),

          // Collapse / expand button
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Align(
              alignment:
                  isCollapsed ? Alignment.center : Alignment.centerRight,
              child: IconButton(
                onPressed: onToggleCollapse,
                icon: Icon(
                  isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                  size: 24,
                  color: toggleColor,
                ),
                tooltip: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color accent = Color(0xFF7EA531);

    final Color bgColor = selected
        ? (isDark ? AppTheme.darkSidebarActive : accent.withOpacity(0.25))
        : Colors.transparent;

    final Color color = selected
        ? accent
        : (isDark ? AppTheme.darkSidebarText : Colors.black87);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: collapsed ? 0 : 20,
        ),
        decoration: BoxDecoration(
          color: bgColor,
        ),
        child: collapsed
            ? Center(
                child: Icon(icon, size: 22, color: color),
              )
            : Row(
                children: [
                  Icon(icon, size: 22, color: color),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      color: color,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
