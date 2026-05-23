import 'package:flutter/material.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../shared/widgets/surveyor_logo.dart';
import '../../features/exports/presentation/export_screen.dart';
import '../../features/surveys/presentation/survey_history_screen.dart';
import '../../shared/widgets/placeholder_feature_page.dart';
import 'app_destination.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const double _railBreakpoint = 720;
  static const double _extendedRailBreakpoint = 1040;

  int _selectedIndex = 0;
  int _surveyRefreshTick = 0;

  static const List<AppDestination> _destinations = [
    AppDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    AppDestination(
      label: 'Surveys',
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment,
    ),
    AppDestination(
      label: 'Map',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
    ),
    AppDestination(
      label: 'Exports',
      icon: Icons.download_outlined,
      selectedIcon: Icons.download,
    ),
  ];

  List<Widget> get _pages => [
        const HomeScreen(),
        SurveyHistoryScreen(refreshToken: _surveyRefreshTick),
        const PlaceholderFeaturePage(
          title: 'Map',
          subtitle: 'GPS capture and road segment context will be added here.',
          icon: Icons.map_outlined,
        ),
        ExportScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= _railBreakpoint;
        final useExtendedRail = constraints.maxWidth >= _extendedRailBreakpoint;

        return Scaffold(
          body: Row(
            children: [
              if (useRail)
                NavigationRail(
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: SurveyorLogo(
                      layout: useExtendedRail
                          ? SurveyorLogoLayout.wordmark
                          : SurveyorLogoLayout.icon,
                      height: useExtendedRail ? 28 : 36,
                    ),
                  ),
                  selectedIndex: _selectedIndex,
                  extended: useExtendedRail,
                  labelType: useExtendedRail
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.selected,
                  onDestinationSelected: _onDestinationSelected,
                  destinations: _destinations
                      .map(
                        (destination) => NavigationRailDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(destination.selectedIcon),
                          label: Text(destination.label),
                        ),
                      )
                      .toList(),
                ),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
              ),
            ],
          ),
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                  destinations: _destinations
                      .map(
                        (destination) => NavigationDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(destination.selectedIcon),
                          label: destination.label,
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        _surveyRefreshTick++;
      }
    });
  }
}
