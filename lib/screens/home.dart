import 'package:flutter/material.dart'hide MenuController;
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../widgets/side_menu.dart';

import '../responsive.dart';
import 'dashboard_screen.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key
      key: context.read<MenuController>().getScaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              const Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            const Expanded(
              // It takes 5/6 part of the screen
              flex: 6,
              child: DashboardScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
