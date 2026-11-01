import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';

class VendorStatusTabs extends StatelessWidget {
  const VendorStatusTabs({
    super.key,
    required this.height,
    required this.leftPadding,
    required this.tabWidth,
    required this.tabs,
    required this.tabCounts,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final double height;
  final double leftPadding;
  final double tabWidth;
  final List<String> tabs;
  final Map<String, int> tabCounts;
  final String selectedTab;
  final ValueChanged<String> onTabChanged;

  Color _tabColor(String tab) {
    if (tab == "Pending") return const Color(0xFFF59E0B);
    if (tab == "Accepted" || tab == "Ready" || tab == "On Going") {
      return const Color(0xFF22C55E);
    }
    if (tab == "Delivered") return const Color(0xFF15803D);
    if (tab == "Preparing") return const Color(0xFF60A5FA);
    if (tab == "Cancelled") return const Color(0xFFEF4444);
    return const Color(0xFFFF5216);
  }

  String _tabCount(String tab) {
    final count = tabCounts[tab] ?? 0;
    return count.toString().padLeft(2, '0');
  }

  String _tabLabel(BuildContext context, String tab) {
    if (tab == "Pending") return S.of(context).pending;
    if (tab == "Accepted") return S.of(context).accepted;
    if (tab == "Preparing") return S.of(context).preparing;
    if (tab == "Ready") return S.of(context).ready;
    if (tab == "On Going") return S.of(context).ongoing;
    if (tab == "Delivered") return S.of(context).delivered;
    if (tab == "Cancelled") return S.of(context).cancelled;
    return tab;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        padding: EdgeInsets.only(left: leftPadding),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = selectedTab == tab;
          final tabColor = _tabColor(tab);
          return GestureDetector(
            onTap: () => onTabChanged(tab),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: tabWidth,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? tabColor : Colors.white,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: isSelected ? tabColor : const Color(0xFFE5E5E5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _tabLabel(context, tab),
                      style: appFont('Rubik', 
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                if (isSelected && tab != "Delivered" && tab != "Cancelled")
                  Positioned(
                    top: 1,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _tabCount(tab),
                        style: appFont('Rubik', 
                          color: tabColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
