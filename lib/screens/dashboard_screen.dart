import 'package:flutter/material.dart'hide MenuController;
import 'package:provider/provider.dart';
import '../controllers/menu_controller.dart';
import '../inner_screens/add_prod.dart';
import '../responsive.dart';
import '../services/utils.dart';
import '../widgets/buttons.dart';
import '../widgets/header.dart';
import '../widgets/orders_list.dart';
import '../widgets/text_widget.dart';

import '../widgets/grid_products.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //   MenuController
    final menuProvider = Provider.of<MenuController>(context);
    Size size = Utils(context).getScreenSize;
    Color color = Utils(context).color;
    return SafeArea(
      child: SingleChildScrollView(
        controller: ScrollController(),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // header
            Header(
              title: 'Tableau de bord',
              fct: () {
                menuProvider.controlDashboarkMenu();
              },
            ),

            const SizedBox(
              height: 20,
            ),
            TextWidget(
              text: 'Derniers produits',
              color: color,
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ButtonsWidget(
                      onPressed: () {},
                      text: 'Voir tout',
                      icon: Icons.store,
                      backgroundColor: Colors.blue),
                  const Spacer(),
                  ButtonsWidget(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddProducts(),
                          ),
                        );
                      },
                      text: 'Ajouter un produit',
                      icon: Icons.add,
                      backgroundColor: Colors.blue),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const SizedBox(height: 10.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Responsive(
                        mobile: ProductGridWidget(
                          crossAxisCount: size.width < 650 ? 2 : 4,
                          childAspectRatio:
                              size.width < 650 && size.width > 350 ? 1.1 : 0.8,
                        ),
                        desktop: ProductGridWidget(
                          childAspectRatio: size.width < 1400 ? 0.8 : 1.05,
                        ),
                      ),
                      //   OrdersList
                      const OrdersList(),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
