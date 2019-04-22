import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fire_model.dart';

class ViewAdminAppt extends StatelessWidget {

  final mainReference = Firestore.instance.collection('appointments');
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: mainReference.snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return CircularProgressIndicator();

        List<DocumentSnapshot> docList = snapshot.data.documents;
        return ListView.builder(
          itemBuilder: null,
          itemCount: docList.length,
        );
      },
    );
  }

  Widget _buildAdminList(List<DocumentSnapshot> list,
        BuildContext context, int index) {
    DocumentSnapshot ds = list[index];

    return null;  //Finish this later

    //Add expansion panels.
  }
}