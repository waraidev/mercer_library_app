import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewAppts extends StatefulWidget {
  @override
  createState() => _ViewState();
}

class _ViewState extends State<ViewAppts> {

  final mainReference = Firestore.instance.collection('appointments');
  final String _prefsKey = "get_appts_pls";
  List<String> keysList;

  @override
  void initState(){
    super.initState();
    _getKeysList();
  }

  Future<void> _getKeysList() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    keysList = prefs.getStringList(_prefsKey) ?? new List<String>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Appointments')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/quad.jpg"),
            fit: BoxFit.cover,
            matchTextDirection: true,
            //Reduce opacity of background image
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.12),
                BlendMode.dstATop
            ),
          ),
        ),

        child: StreamBuilder<QuerySnapshot>(
          stream: mainReference.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator()
                ],
              );

            List<DocumentSnapshot> docList = snapshot.data.documents;

            return ListView.builder(
              itemBuilder: (context, index) =>
                  _buildApptList(docList, context, index),
              itemCount: docList.length,
            );
          },
        ),
      ),
    );
  }

  Widget _buildApptList(List<DocumentSnapshot> list,
      BuildContext context, int index) {
    DocumentSnapshot ds = list[index];
    if (keysList.contains(ds.documentID)) {
      var dateTime = DateFormat("MMM dd, yyyy 'at' hh:mm a")
          .format(ds['datetime'].toDate());

      return ExpansionTile(
        key: PageStorageKey<int>(1),
        title: Text(dateTime,
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _createRichText(
                    'Name, MUID: ', ds['name'] + ', ' + ds['muid']),

                _createRichText('Email: ', ds['email']),
                _createRichText('Major: ', ds['major']),
                _createRichText('Date and Time: ', dateTime),
                _createRichText('Location: ',
                    ds['location'] + ', ' + ds['specloc']),

                _createRichText('Meeting Type: ', ds['meeting-type']),
                _createRichText('Details: ', ds['details']),
                SizedBox(height: 14)
              ],
            ),
          )
        ],
      );
    }
    else
      return Container();
  }

  Widget _createRichText(String bold, String text) {
    return RichText(
      text: TextSpan(
          style: TextStyle(         //Rich Text allows the first part to
              color: Colors.black               //be bold
          ),
          children: <TextSpan>[
            TextSpan(text: bold,
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: text,)
          ]
      ),
    );
  }
}