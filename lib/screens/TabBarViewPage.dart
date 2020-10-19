import 'package:dairy_app_owner/screens/MilkDistributorPage.dart';

import '../screens/TabBarViewProducts.dart';
import '../screens/TabBarViewUser.dart';
import '../screens/TabBarViewMilkman.dart';
import '../screens/TabBarViewAreas.dart';
import 'package:flutter/material.dart';
import '../screens/UserDetailsPage.dart';
import '../screens/AreaDetailsPage.dart';
import '../screens/MilkManDetailsPage.dart';
import '../screens/ProductsDetailsPage.dart';
import 'TabBarViewPageMilkDistrirbutor.dart';

class TabBarViewPage extends StatelessWidget {
  var className;
  BuildContext context;

  TabBarViewPage(BuildContext context) {
    this.context = context;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: SizedBox(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.blue,
              child: TabBar(
                indicatorColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 3,
                tabs: <Widget>[
                  Tab(
                    child: Container(
                      child: Text(
                        "List",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    icon: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  Tab(
                    child: Container(
                      child: Text(
                        "Add",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                  Tab(
                    child: Container(
                      child: Text(
                        "Update",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    icon: Icon(
                      Icons.update,
                      color: Colors.white,
                    ),
                  ),
                  Tab(
                    child: Container(
                      child: Text(
                        "Delete",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    icon: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            Expanded(child: checkClassName(this.context.widget)),
          ],
        ),
      ),
    );
  }

  Widget checkClassName(className) {
    print(className);
    if (className is UserDetailsPage) {
      return TabBarViewUser();
    } else if (className is AreaDetailsPage) {
      return TabBarViewAreas();
    } else if (className is MilkmanDetailsPage) {
      return TabBarViewMilkman();
    } else if (className is ProductDetailsPage) {
      return TabBarViewProducts();
    }
     else if (className is MilkDistributorpage) {
      return TabBarViewMilkDistributor();
    }
  }
}
