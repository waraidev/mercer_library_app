import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewAdminAppt extends StatefulWidget {
  @override
  createState() => _ViewAdminState();
}

class _ViewAdminState extends State<ViewAdminAppt> {

  final mainReference = Firestore.instance.collection('appointments');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin View Appointments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: mainReference.snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return CircularProgressIndicator();

          List<DocumentSnapshot> docList = snapshot.data.documents;

          return ListView.builder(
            itemBuilder: (context, index) =>
                _buildAdminList(docList, context, index),
            itemCount: docList.length,
          );
        },
      ),
    );
  }

  Widget _buildAdminList(List<DocumentSnapshot> list,
        BuildContext context, int index) {
    DocumentSnapshot ds = list[index];

    var dateTime = DateFormat("MMM dd, yyyy 'at' hh:mm a")
        .format(ds['datetime'].toDate());

    return ExpansionTile(
      key: PageStorageKey<int>(0),
      title: Text(ds['name'] + '  |  ' + dateTime),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RichText(   //Name and MUID
                text: TextSpan(
                    style: TextStyle(       //Rich Text allows the first part to
                        color: Colors.black           //be bold
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Name, MUID: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ds['name'] + ', ' + ds['muid'])
                    ]
                ),
              ),
              RichText(     //Email
                text: TextSpan(
                    style: TextStyle(
                        color: Colors.black
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Email: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ds['email'])
                    ]
                ),
              ),
              RichText(     //Major
                text: TextSpan(
                    style: TextStyle(
                        color: Colors.black
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Major: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ds['major'])
                    ]
                ),
              ),
              RichText(     //Date and Time
                text: TextSpan(
                    style: TextStyle(
                        color: Colors.black
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Date and Time: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: dateTime)
                    ]
                ),
              ),
              RichText(     //Location
                text: TextSpan(
                    style: TextStyle(
                        color: Colors.black
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Location: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ds['location'] + ', ' + ds['specloc'])
                    ]
                ),
              ),
              RichText(     //Meeting Type
                text: TextSpan(
                    style: TextStyle(
                        color: Colors.black
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Meeting Type: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ds['meeting-type'])
                    ]
                ),
              ),
              RichText(     //Details
                text: TextSpan(
                    style: TextStyle(
                        color: Colors.black
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Details: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ds['details'])
                    ]
                ),
              ),
              SizedBox(height: 14)
            ],
          ),
        )
      ],
    );

    //Add expansion panels.
  }
}