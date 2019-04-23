import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminEventSchedule extends StatefulWidget {
  @override
  createState() => _EventScheduleState();
}

class _EventScheduleState extends State<AdminEventSchedule> {

  TextEditingController _dateCtrl = TextEditingController();
  TextEditingController _startTimeCtrl = TextEditingController();
  TextEditingController _endTimeCtrl = TextEditingController();

  final mainReference = Firestore.instance.collection('appointments');

  @override
  void dispose(){
    super.dispose();
    _dateCtrl.dispose();
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Schedule an Event")),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => _selectDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateCtrl,
                  onEditingComplete: (){
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  decoration: InputDecoration(
                    hintText: "Select the date that you are busy",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange[700]),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    labelText: "Date",
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => null,
              child: AbsorbPointer(
                child: TextField(
                  controller: _startTimeCtrl,
                  onEditingComplete: (){
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  decoration: InputDecoration(
                    hintText: "Select the start time that you are busy",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange[700]),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    labelText: "Start Time",
                  ),
                ),
              ),
            )
          ]
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();
    bool wDay = today.weekday == 6 || today.weekday == 7 ? false : true;

    final DateTime datePicked = await showDatePicker(
      context: context,
      firstDate: today,
      initialDate: wDay ? today : today.add(new Duration(days: 8-today.weekday)),
      //initialDate bool is so that there is no error while making an
      //appointment on the weekend
      lastDate: DateTime(today.year + 1),
      selectableDayPredicate: (DateTime val) =>
      val.weekday == 6 || val.weekday == 7 ? false : true,
    );
    if (datePicked != null)
      setState(() {
        _dateCtrl.text = DateFormat("'Date:' MMM dd, yyyy").format(datePicked);
      });
  }



}