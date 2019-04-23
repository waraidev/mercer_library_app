import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminEventSchedule extends StatefulWidget {
  @override
  createState() => _EventScheduleState();
}

class _EventScheduleState extends State<AdminEventSchedule> {

  TimeOfDay _startTime, _endTime;
  DateTime _selectedDate;

  final mainReference = Firestore.instance.collection('librarian');

  @override
  void initState() {
    super.initState();
    _selectedDate = null;
    _startTime = null;
    _endTime = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Schedule an Event")),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 50),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.7,
              child: RaisedButton(
                child: Text("Select a date..."),
                onPressed: () => _selectDate(context),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              height: 30,
              child: Text(_selectedDate == null ?
              'No date selected.' :
              DateFormat("'Date: 'MMM dd, yyyy").format(_selectedDate))
            ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.7,
              child: RaisedButton(
                child: Text("Select a start time..."),
                onPressed: () => _selectTime(
                    context,
                    TimeOfDay(hour: 9, minute: 0),
                    true
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.all(8.0),
                height: 30,
                child: Text(_startTime == null ?
                'No start time selected.' :
                'Start Time: ' + _startTime.format(context))
            ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.7,
              child: RaisedButton(
                child: Text("Select a end time..."),
                onPressed: () => _selectTime(
                    context,
                    _startTime,
                    false
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.all(8.0),
                height: 30,
                child: Text(_endTime == null ?
                'No end time selected.' :
                'End Time: ' + _endTime.format(context))
            ),

            SizedBox(height: 30),
            _selectedDate == null || _startTime == null || _endTime == null
                ? Container() :
            Container(
              height: MediaQuery.of(context).size.height * 0.165,
              width: MediaQuery.of(context).size.width * 0.6,
              padding: EdgeInsets.all(15),
              color: Colors.orange,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(         //Rich Text allows the first part to
                    color: Colors.black,               //be bold
                    height: 1.3,
                    fontWeight: FontWeight.bold
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 
                      DateFormat("MMM dd, yyyy").format(_selectedDate) + '\n'
                    ),
                    TextSpan(text: "from\n",),
                    TextSpan(text: _startTime.format(context) + ' to ' +
                      _endTime.format(context))
                  ]
                )
              ),
            ),
          ]
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        heroTag: null,
        tooltip: "Submit Form",
        onPressed: () => _submit(context),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();
    bool wDay = today.weekday == 6 || today.weekday == 7 ? false : true;

    final DateTime datePicked = await showDatePicker(
      context: context,
      firstDate: today,
      initialDate: wDay ? today : today.add(
          new Duration(days: 8 - today.weekday)),
      //initialDate bool is so that there is no error while making an
      //appointment on the weekend
      lastDate: DateTime(today.year + 1),
      selectableDayPredicate: (DateTime val) =>
      val.weekday == 6 || val.weekday == 7 ? false : true,
    );
    if (datePicked != null)
      setState(() {
        _selectedDate = datePicked;
      });
  }

  void _selectTime(BuildContext context, TimeOfDay start, bool first) async {
    TimeOfDay now = TimeOfDay.now();
    TimeOfDay timePicked;

    if(_selectedDate.day == DateTime.now().day && start.hour < now.hour) {
      start = now;
    }

    timePicked = await showTimePicker(
        context: context,
        initialTime: start    //During the 2nd run of this, start will
    );                            //be the start time

    if(timePicked != null) {
      timePicked = TimeOfDay(hour: timePicked.hour, minute: 0);

      setState(() {
        if (first) //determines if it is 1st run or not
          _startTime = timePicked;
        else
          _endTime = timePicked;
      });
    }
  }

  void _submit(BuildContext context) {

    for(int i = _startTime.hour; i < _endTime.hour; i++) {

      if(i >= 9 && i <= 16) {
        mainReference.add({
          'datetime': DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              i
          )
        });
      }
    }
    Navigator.pop(context);
  }
}