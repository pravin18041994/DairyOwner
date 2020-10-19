import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'MilkmanDrawer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// class MilkmanDashboard extends StatefulWidget {
//   @override
//   _MilkmanDashboardState createState() => _MilkmanDashboardState();
// }

// class _MilkmanDashboardState extends State<MilkmanDashboard> {
//   Material MyItems(IconData icon, String title, int color) {
//     return

//     Material(
//       color: Colors.white,
//       elevation: 0.8,
//       shadowColor: Colors.green,
//       borderRadius: BorderRadius.circular(10.0),
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         title,
//                         style: TextStyle(
//                           color: new Color(color),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Material(
//                     color: new Color(color),
//                     borderRadius: BorderRadius.circular(24.0),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Icon(
//                         icon,
//                         color: Colors.white,
//                         size: 20.0,
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   var connectivityResult;
//   var isConnectionActive = true;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     checkInternetConnection();
//   }

//   checkInternetConnection() async {
//     connectivityResult = await (Connectivity().checkConnectivity());
//     setState(() {
//       if (connectivityResult == ConnectivityResult.mobile ||
//           connectivityResult == ConnectivityResult.wifi) {
//         isConnectionActive = true;
//       } else {
//         isConnectionActive = false;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isConnectionActive == false
//         ? Scaffold(
//             body: Center(
//                 child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 Text('No Internet Connection !'),
//                 RaisedButton(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                       side: BorderSide(color: Colors.black)),
//                   onPressed: () {
//                     checkInternetConnection();
//                   },
//                   child: Text('Refresh'),
//                 )
//               ],
//             )),
//           )
//         : Scaffold(
//             appBar: AppBar(
//               centerTitle: true,
//               backgroundColor: Colors.transparent,
//               elevation: 0.0,
//               iconTheme: new IconThemeData(color: Colors.green),
//               title: Text(
//                 "Milkman Dashboard",
//                 style: TextStyle(
//                   color: Colors.green,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             drawer: MilkmanDrawer(),
//             body: ListView(
//               children: <Widget>[
//                 StaggeredGridView.count(
//                   shrinkWrap: true,
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 5.0,
//                   mainAxisSpacing: 5.0,
//                   padding:
//                       EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                   children: <Widget>[
//                     MyItems(Icons.graphic_eq, "Total Liters of \n milk sold",
//                         0xff48d147),
//                     MyItems(Icons.bookmark, "Total Nuber of\n customers",
//                         0xff48d147),
//                     MyItems(Icons.format_list_numbered,
//                         "Total Money \nrecieved today", 0xff48d147),
//                     MyItems(Icons.confirmation_number,
//                         "Monthly Total\n Collection", 0xff48d147),
//                     MyItems(Icons.person, "Numbers of guest", 0xff48d147),
//                     MyItems(Icons.details, "Total nuber of \nguest in Month",
//                         0xff48d147),
//                     MyItems(
//                         Icons.graphic_eq, "Reviews of \nCustomer", 0xff48d147),
//                   ],
//                   staggeredTiles: [
//                     StaggeredTile.extent(2, 130),
//                     StaggeredTile.extent(1, 130),
//                     StaggeredTile.extent(1, 130),
//                     StaggeredTile.extent(1, 130),
//                     StaggeredTile.extent(1, 130),
//                     StaggeredTile.extent(1, 130),
//                     StaggeredTile.extent(1, 130),
//                     StaggeredTile.extent(1, 130),
//                   ],
//                 )
//               ],
//             ),
//           );
//   }
// }

class MilkmanDashboard extends StatefulWidget {
  @override
  _MilkmanDashboardState createState() => _MilkmanDashboardState();
}

class _MilkmanDashboardState extends State<MilkmanDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Dashboard",
          style: TextStyle(),
        ),
      ),
      drawer: MilkmanDrawer(),
      body:
       Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
              Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Card(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Card(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
               Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Card(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Card(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Card(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
              Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Card(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
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
