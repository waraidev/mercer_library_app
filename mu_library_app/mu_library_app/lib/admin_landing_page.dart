import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'admin_appt_view.dart';
import 'admin_event_schedule.dart';

class AdminLandingPage extends StatefulWidget{
  @override
  _AdminLandingPageState createState() => _AdminLandingPageState();
}

class _AdminLandingPageState extends State<AdminLandingPage>{

  final String _adminKey = "admin_mode";

  @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: ()async => false,
      child: Scaffold(
        appBar: AppBar(
          //TODO: Make this look better, or make it look good without
          leading: Container(),
          title: Text("Admin Mode"),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/tarver.jpeg"),
              fit: BoxFit.cover,
              matchTextDirection: true,
              //Reduce opacity of background image
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.dstATop
              ),
            ),
          ),

          child: Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Welcome, Admin", textScaleFactor: 2.5,),

                  RaisedButton(
                    child: _buttonText("View All Appointments"),
                    onPressed: () => _navToPage(ViewAdminAppt()),
                  ),

                  RaisedButton(
                    child: _buttonText("Schedule an Event"),
                    onPressed: () => _navToPage(AdminEventSchedule()),
                  ),

                  RaisedButton(
                    child: _buttonText("Turn Off Admin Mode"),
                    onPressed: () => _turnOffAdmin(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _turnOffAdmin(BuildContext context) async{
    final FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.write(key: _adminKey, value: "false");
    Navigator.of(context).pop();
  }

  void _navToPage(Widget widget) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => widget)
    );
  }
}

Text _buttonText(String s) {
  return Text(
    s,
    style: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  );
}

