import 'package:flutter/material.dart';

class MainForm extends StatefulWidget{
  @override
  _MainFormState createState() => _MainFormState();
}

class _MainFormState extends State<MainForm>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book an Appointment"),
      ),

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            //TODO: Different background photo here?
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
          //TODO: Should the sign-up include name?
          // How anonymous should it be?
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

            ],
          ),
        ),
      ),
    );
  }
}