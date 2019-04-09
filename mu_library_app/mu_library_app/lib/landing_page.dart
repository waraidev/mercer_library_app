import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'admin_landing_page.dart';
import 'book_appt_form.dart';

class LandingPage extends StatefulWidget{
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>{

  final String _adminKey = "admin_mode";

  @override
  void initState(){
    super.initState();
    _getMode().then((result){
      if(result)
        _navToAdminLandingPage();
    });
  }

  Future<bool> _getMode() async{
    final FlutterSecureStorage storage = FlutterSecureStorage();
    String _admin = await storage.read(key: _adminKey);
    if(_admin != null || _admin == "true")
      return true;
    else
      return false;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
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
          //TODO: Make this look better
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //TODO: Take a look at this and compare to other page
                // which is better?
                Center(child: Text("Welcome", textScaleFactor: 3.0,),),

                RaisedButton(
                  child: _buttonText("Book an Appointment"),
                  onPressed: _navToForm,
                ),

                RaisedButton(
                  child: _buttonText("View Your Appointments"),
                  onPressed: null,
                ),

                //TODO: Turn this into a login page. This works for debug.
                RaisedButton(
                    child: _buttonText("Turn On Admin Mode"),
                    onPressed: _turnOnAdmin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Text _buttonText(String s) {
    return Text(
      s,
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _navToAdminLandingPage(){
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AdminLandingPage())
    );
  }

  void _navToForm(){
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => MainForm())
    );
  }

  void _turnOnAdmin() async{
    final FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.write(key: _adminKey, value: "true");
    _navToAdminLandingPage();
  }
}

