import 'package:flutter/material.dart';
import 'package:flutter_tcc/presentation/screens/map/map_screen.dart';
import 'package:flutter_tcc/presentation/screens/schedule/schedule_screen.dart';
import 'package:flutter_tcc/presentation/screens/search/search_screen.dart';
import 'package:flutter_tcc/presentation/widgets/persistent_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  final _tab1navigatorKey = GlobalKey<NavigatorState>();
  final _tab2navigatorKey = GlobalKey<NavigatorState>();
  final _tab3navigatorKey = GlobalKey<NavigatorState>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentBottomBarScaffold(
      items: [
        // Aba 1 - Ativos
        PersistentTabItem(
          tab: const SearchScreen(),
          icon: Icons.build,
          title: 'Ativos',
          navigatorkey: _tab2navigatorKey,
        ),
        // Aba 2 - Mapa
        PersistentTabItem(
          tab: const MapScreen(),
          icon: Icons.map,
          title: 'Mapa',
          navigatorkey: _tab1navigatorKey,
        ),
        // Aba 3 - Agenda
        PersistentTabItem(
          tab: const ScheduleScreen(),
          icon: Icons.schedule,
          title: 'Agenda',
          navigatorkey: _tab3navigatorKey,
        ),
      ],
    );
  }
}
