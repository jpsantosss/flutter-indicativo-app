import 'package:flutter/material.dart';

class PersistentTabItem {
  final Widget tab;
  final GlobalKey<NavigatorState>? navigatorkey;
  final String title;
  final IconData icon;

  PersistentTabItem({
    required this.tab,
    this.navigatorkey,
    required this.title,
    required this.icon,
  });
}

class PersistentBottomBarScaffold extends StatefulWidget {
  final List<PersistentTabItem> items;
  const PersistentBottomBarScaffold({super.key, required this.items});

  @override
  State<PersistentBottomBarScaffold> createState() =>
      _PersistentBottomBarScaffoldState();
}

class _PersistentBottomBarScaffoldState
    extends State<PersistentBottomBarScaffold> {
  int _selectedTab = 1;
  Widget _buildNavItem(PersistentTabItem item, int index) {
    final bool isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 26,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 12,
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (widget.items[_selectedTab].navigatorkey?.currentState?.canPop() ??
            false) {
          widget.items[_selectedTab].navigatorkey?.currentState?.pop();
        } else {
          // Se não puder dar pop na aba atual, fecha o app/tela
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedTab,
          children:
              widget.items
                  .map(
                    (page) => Navigator(
                      key: page.navigatorkey,
                      onGenerateInitialRoutes: (navigator, initialRoute) {
                        return [
                          MaterialPageRoute(builder: (context) => page.tab),
                        ];
                      },
                    ),
                  )
                  .toList(),
        ),
        bottomNavigationBar: Container(
          height: 70,
          padding: const EdgeInsets.only(
            bottom: 0,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF12385D),
            border: Border(
              top: BorderSide(color: Color(0xFF2E95AC), width: 8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Item 0 (Busca)
              Expanded(child: _buildNavItem(widget.items[0], 0)),
              // Item 1 (Mapa)
              Expanded(child: _buildNavItem(widget.items[1], 1)),
              // Item 2 (Agenda)
              Expanded(child: _buildNavItem(widget.items[2], 2)),
            ],
          ),
        ),
      ),
    );
  }
}
