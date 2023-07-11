import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../inner_screens/all_orders.dart';
import '../inner_screens/all_products.dart';
import '../providers/dark_theme_provider.dart';
import '../services/utils.dart';
import '../widgets/text_widget.dart';

import '../screens/home.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = Utils(context).getTheme;
    final themeState = Provider.of<DarkThemeProvider>(context);

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset(
              "assets/images/shop.png",
            ),
          ),
          DrawerListTile(
            title: "Accueil",
            press: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const Home(),
                ),
              );
            },
            icon: Icons.home_filled,
          ),
          // AllProductsScreen
          DrawerListTile(
            title: "Voir tous les produits",
            press: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AllProductsScreen()));
            },
            icon: Icons.store,
          ),

          // AllOrdersScreen
          DrawerListTile(
            title: "Voir toutes les commandes",
            press: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AllOrdersScreen()));
            },
            icon: IconlyBold.bag_2,
          ),

          SwitchListTile(
              title: const Text(
                'Theme', overflow: TextOverflow.ellipsis
              ),
              secondary: Icon(themeState.getDarkTheme
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined),
              value: theme,
              onChanged: (value) {
                setState(() {
                  themeState.setDarkTheme = value;
                });
              })
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.press,
    required this.icon,
  }) : super(key: key);

  final String title;
  final VoidCallback press;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = Utils(context).color;

    return ListTile(
        onTap: press,
        horizontalTitleGap: 0.0,
        leading: Icon(
          icon,
          size: 18,
        ),
        title: TextWidget(
          text: title,
          color: color,
        ));
  }
}
