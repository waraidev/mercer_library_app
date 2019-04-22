import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fire_model.dart';

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

    return ExpansionTile(
      key: PageStorageKey<int>(0),
      title: Text(ds['name'] + ', ' + ds['datetime'].toDate().toString()),
      children: <Widget>[
        Text(ds['name'] + ', ' + ds['muid']),
        Text(ds['email']),
        Text(ds['major']),
        Text(ds['datetime'].toDate().toString()),
        Text(ds['location'] + ', ' + ds['specloc']),
        Text(ds['meeting-type']),
        Text(ds['details'])
      ],
    );

    //Add expansion panels.
  }
}