import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'admin_landing_page.dart';

class LandingPage extends StatefulWidget{
  LandingPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>{

  final String _adminKey = "admin_mode";
  final String pass = "underwoodmoney";

  TextEditingController passCtrl = new TextEditingController();

  @override
  void dispose() {
    passCtrl.dispose();
    super.dispose();
  }

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
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _navToAdminLandingPage2,
          )
        ],
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
                  onPressed: null,
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

  void _turnOnAdmin() async{
    final FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.write(key: _adminKey, value: "true");
    _navToAdminLandingPage();
  }

  void _navToAdminLandingPage2(){
    AlertDialog error = new AlertDialog(
      content: Text("Wrong Password!"),
    );
    SimpleDialog login = new SimpleDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(10.0))),
      title: Center(child: Text('LOGIN')),
      children: <Widget>[
        Center(child: Text('Enter the admin password below:')),

        GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus( FocusNode());
          },
          child: TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: "Password",
                  contentPadding: EdgeInsets.symmetric(vertical: 6.0,
                      horizontal: 8.0),
                  hintText: "Enter Admin Password"
              ),
          )
        ),
        RaisedButton(
          child: Text("Done"),
          onPressed: () {
            String inputPass = passCtrl.text;
            passCtrl.clear();
            if(inputPass == pass){
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AdminLandingPage())
              );
            } else if(inputPass != pass && inputPass != '') {
              Navigator.of(context).pop();
              showDialog(
                  context: context,
                  builder: (context) { return error; }
              );
            }
          },
        ),

        RaisedButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );

    showDialog(
      //barrierDismissible: false,
        context: context,
        builder: (context) { return login; }
    );
  }
}

