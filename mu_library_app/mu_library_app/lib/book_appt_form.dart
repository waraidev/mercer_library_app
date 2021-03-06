import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'fire_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainForm extends StatefulWidget{
  @override
  _MainFormState createState() => _MainFormState();
}

class _MainFormState extends State<MainForm>{

  ApptData _entry;

  final mainReference = Firestore
      .instance.collection('appointments');
  final String _prefsKey = "get_appts_pls";

  DateTime _selectedDate;
  TimeOfDay _selectedTime;
  final double _pad = 10;
  String _selDateTimeStr, _selectedLocation,
      _specificLoc, _errorText, _emailError,
      _meetingType;
  bool _isLocChosen, _isDateChosen;
  bool _isSubmitting;
  static final List<String> _dropdownItems = <String>[
    'Connell Student Center', 'Mercer Village', 'University Center',
    'Tarver Library', "Einstein's", 'Stetson Computer Labs'
  ];
  static List<String> _specificLocItems;
  int _videoMeeting = 0;

  TextEditingController _nameInput = TextEditingController();
  TextEditingController _muidInput = TextEditingController();
  TextEditingController _emailInput = TextEditingController();
  TextEditingController _majorInput = TextEditingController();
  TextEditingController _detailInput = TextEditingController();

  @override
  void dispose(){
    super.dispose();
    _nameInput.dispose();
    _muidInput.dispose();
    _emailInput.dispose();
    _majorInput.dispose();
    _detailInput.dispose();
  }

  @override
  void initState(){
    super.initState();
    _isLocChosen = false;
    _isDateChosen = false;
    _errorText = null;
    _emailError = null;
    _selDateTimeStr = "No date selected.";
    _selectedDate = null;
    _selectedTime = null;
    _selectedLocation = null;
    _specificLoc = null;
    _isSubmitting = false;
  }

  @override
  Widget build(BuildContext context) {
    final formWidgets = <Widget>[
      Text(_errorText ==  null ? "" : _errorText,
        textScaleFactor: 1.4,
        style: TextStyle(
          color: Colors.red,
          //fontStyle: FontStyle.italic,
        ),
      ),

      SizedBox(height: _pad),

      TextField(
        controller: _nameInput,
        onEditingComplete: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: "Please enter your name",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange[700]),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          labelText: "Name",
        ),
      ),

      SizedBox(height: _pad),

      TextField(
        controller: _muidInput,
        keyboardType: TextInputType.number,
        maxLength: 8,
        maxLengthEnforced: true,
        onEditingComplete: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        decoration: InputDecoration(
          hintText: "Please enter your MUID",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange[700]),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          labelText: "MUID",
          counterText: "",
        ),
      ),

      SizedBox(height: _pad),

      TextField(
        controller: _emailInput,
        onEditingComplete: () {
          FocusScope.of(context).requestFocus(FocusNode());
          _validateEmail();
        },
        keyboardType: TextInputType.emailAddress,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          hintText: "Please enter your Mercer email address",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange[700]),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          labelText: "Email",
        ),
      ),

      Text(_emailError ==  null ? "" : _emailError,
        style: TextStyle(
          color: Colors.red,
          fontStyle: FontStyle.italic,
        ),
      ),

      SizedBox(height: _pad),

      TextField(
        controller: _majorInput,
        onEditingComplete: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          hintText: "What is your major?",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange[700]),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          labelText: "Major/Dept.",
        ),
      ),

      SizedBox(height: _pad - 1),

      Container(
        height: 50,
        child: RaisedButton(
          child: Text("Select a date/time..."),
          onPressed: () => _selectDateTime(context),
        ),
      ),

      SizedBox(height: _pad/2,),

      Text(_selDateTimeStr,
        textScaleFactor: 1.3,
        style: TextStyle(fontWeight: FontWeight.bold,),
      ),

      SizedBox(height: _pad - 1,),

      _timePicker(context),

      SizedBox(height: _pad/2),

      Column(
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text("Meeting Type"),
          ),

          Row(
            children: <Widget>[
              Radio(
                value: 0,
                groupValue: _videoMeeting,
                onChanged: _onRadioChange,
              ),

              FlatButton(
                child: Text("In-Person"),
                onPressed: () => _onRadioChange(0),
              ),

              Spacer(),

              Radio(
                value: 1,
                groupValue: _videoMeeting,
                onChanged: _onRadioChange,
              ),

              FlatButton(
                child: Text("Video Call"),
                onPressed: () => _onRadioChange(1),
              ),
            ],
          ),

        ],
      ),

      _selectLoc(context),  //Created method to deal with Video Call select

      SizedBox(height: _pad/2),

      _chooseSpecificLoc(context),

      SizedBox(height: _pad/2),

      TextField( //Additional Details box
        controller: _detailInput,
        keyboardType: TextInputType.multiline,
        maxLines: 4,
        onEditingComplete: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: "Please describe your research needs...",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange[700]),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          labelText: "Additional Details",
        ),
      ),
    ];

    return Scaffold(

      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Book an Appointment"),
      ),

      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
          _validateEmail();
        },

        child: Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/willingham.jpg"),
              fit: BoxFit.cover,
              matchTextDirection: true,
              //Reduce opacity of background image
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.15),
                  BlendMode.dstATop
              ),
            ),
          ),

          child: Padding(
            padding: EdgeInsets.all(_pad),
            child: Center(
              //TODO: Should the sign-up include name?
              // How anonymous should it be?
              child: ListView(
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(_errorText ==  null ? "" : _errorText,
                    textScaleFactor: 1.4,
                    style: TextStyle(
                      color: Colors.red,
                      //fontStyle: FontStyle.italic,
                    ),
                  ),

                  TextField(
                    controller: _nameInput,
                    onEditingComplete: (){
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: "Please enter your name",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange[700]),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      labelText: "Name",
                    ),
                  ),

                  SizedBox(height: _pad),

                  TextField(
                    controller: _muidInput,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    maxLengthEnforced: true,
                    onEditingComplete: (){
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    decoration: InputDecoration(
                      hintText: "Please enter your MUID",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange[700]),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      labelText: "MUID",
                      counterText: "",
                    ),
                  ),

                  SizedBox(height: _pad,),

                  TextField(
                    controller: _emailInput,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      _validateEmail();
                    },
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      hintText: "Please enter your email address",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange[700]),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      labelText: "Email",
                    ),
                  ),

                  Text(_emailError ==  null ? "" : _emailError,
                    style: TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  SizedBox(height: _pad,),

                  TextField(
                    controller: _majorInput,
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      hintText: "What is your major?",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange[700]),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      labelText: "Major/Dept.",
                    ),
                  ),

                  SizedBox(height: _pad - 1,),

                  Container(
                    height: 50,
                    child: RaisedButton(
                      child: Text("Select a date/time..."),
                      onPressed: () => _selectDateTime(context),
                    ),
                  ),

                  SizedBox(height: _pad/2,),

                  Text(_selDateTimeStr,
                    textScaleFactor: 1.3,
                    style: TextStyle(fontWeight: FontWeight.bold,),
                  ),

                  SizedBox(height: _pad - 1,),

                  _timePicker(context),

                  DropdownButtonHideUnderline(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: _selectedLocation == null ?
                          'Please select a location...' : 'Location',
                      ),
                      isEmpty: _selectedLocation == null,
                      child: new DropdownButton<String>(
                        value: _selectedLocation,
                        isDense: true,
                        onChanged: (String newValue) {
                          setState(() {
                            if(newValue != _selectedLocation || _selectedLocation == null) {
                              _isLocChosen = false;
                              _selectedLocation = newValue;
                              _specificLoc = null;
                              _isLocChosen = true;
                            }
                          });
                        },
                        items: _dropdownItems.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  SizedBox(height: _pad,),

                 _chooseSpecificLoc(context),

                  //TODO: Add one more text field describing research needs
                ],
              ),
            ),
          ),
        ),
      ),
      //Submit Button
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        heroTag: null,
        tooltip: "Submit Form",
        onPressed: () => _submit(context),
      ),
    );
  }

  void _validateEmail(){
    if(_emailInput.text.isEmpty) return;
    if(_emailInput.text.contains("@") &&
        _emailInput.text.toLowerCase().endsWith("mercer.edu"))
      _emailError = null;
    else
      _emailError = "Please provide a valid Mercer email address.";
  }

  void _selectDateTime(BuildContext context) async {
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
        _selectedDate = DateTime(
          datePicked.year, datePicked.month, datePicked.day,
        );
        _selectedTime = null;
        _rebuildSelDateTimeStr();
        _isDateChosen = true;
      });
  }

  Widget _chooseSpecificLoc(BuildContext context){
    if(_videoMeeting != 0)
      return Container();
    else if(_isLocChosen) {
      /*
      Possible locations:
        Connell Student Center
        Mercer Village
        University Center
        Tarver Library
        Einstein's
        Stetson Computer Labs
       */
      //TODO: Verify these specific locations with the librarians
      if(_selectedLocation == "Connell Student Center")
        _specificLocItems = <String>["Which Wich"];
      else if(_selectedLocation == "Mercer Village")
        _specificLocItems = <String>["Z Beans", "Outside Bookstore"];
      else if(_selectedLocation == "University Center")
        _specificLocItems = <String>["Food Court", "Main Hallway"];
      else if(_selectedLocation == "Tarver Library")
        _specificLocItems = <String>["1st Floor", "2nd Floor", "3rd Floor"];
      else if(_selectedLocation == "Einstein's") //No specifics necessary
        return Container();
      else if(_selectedLocation == "Stetson Computer Labs")
        //TODO: Find the room numbers and choose which computer lab
        _specificLocItems = <String>["Temp 1", "Temp 2", "Temp 3"];
      else
        _specificLocItems = <String>["null"];

      return DropdownButtonHideUnderline(
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Specifically...',
          ),
          isEmpty: _specificLoc == null,
          child: new DropdownButton<String>(
            value: _specificLoc,
            isDense: true,
            onChanged: (String newValue) {
              setState(() {
                _specificLoc = newValue;
              });
            },
            items: _specificLocItems.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      );
    }
    else
      return Container();
  }

  Widget _selectLoc(BuildContext context) {
    if(_videoMeeting != 0)  //if video call is selected, the selectLocation
      return Container();         //option will not appear
    else {
      return DropdownButtonHideUnderline(
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: _selectedLocation == null ?
            'Please select a location...' : 'Location',
          ),
          isEmpty: _selectedLocation == null,
          child: new DropdownButton<String>(
            value: _selectedLocation,
            isDense: true,
            onChanged: (String newValue) {
              setState(() {
                if(newValue != _selectedLocation || _selectedLocation == null) {
                  _isLocChosen = false;
                  _selectedLocation = newValue;
                  _specificLoc = null;
                  _isLocChosen = true;
                }
              });
            },
            items: _dropdownItems.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  Widget _timePicker(BuildContext context){
    var apptDocs, libDocs, apptTime, libTime;
    List<TimeOfDay> _availableTimes = new List();
    for(int i = 9; i <= 16; i++)
      _availableTimes.add(TimeOfDay(hour: i, minute: 0));

    Stream<QuerySnapshot> appts = Firestore.instance.collection('appointments').snapshots();
    Stream<QuerySnapshot> lib = Firestore.instance.collection('librarian').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: appts,
      builder: (context, snapAppt) {
        return StreamBuilder<QuerySnapshot>(
          stream: lib,
          builder: (context, snapLib) {
            if(_isSubmitting) return Container(); //Avoids null call when firebase refreshes
            else if(!snapAppt.hasData || !snapLib.hasData)
              return CircularProgressIndicator();      //loads

            apptDocs = snapAppt.data.documents;
            libDocs = snapLib.data.documents;

            for(int i = 0; i < apptDocs.length; i++) {
              for(int j = 0; j < libDocs.length; j++) {
                apptTime = apptDocs.elementAt(i)['datetime'].toDate();
                libTime = libDocs.elementAt(j)['datetime'].toDate();
                if(_selectedDate != null) {
                  if(_selectedDate.day == apptTime.day &&
                      _selectedDate.month == apptTime.month){
                    if(_availableTimes.contains(TimeOfDay.fromDateTime(apptTime)))
                      _availableTimes.remove(TimeOfDay.fromDateTime(apptTime));
                  }
                            //Removes times
                  if(_selectedDate.day == libTime.day &&
                      _selectedDate.month == libTime.month){
                    if(_availableTimes.contains(TimeOfDay.fromDateTime(libTime)))
                      _availableTimes.remove(TimeOfDay.fromDateTime(libTime));
                  }
                }
              }
            }

            //Dropdown functionality below
            if(_isDateChosen){
              if(_availableTimes.isEmpty){
                return DropdownButtonHideUnderline(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'No times available for the chosen day.',
                    ),
                    isEmpty: true,
                    child: null,
                  ),
                );
              }
              else {
                return DropdownButtonHideUnderline(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: _selectedTime == null ?
                      'Please select a time...' : 'Time',
                    ),
                    isEmpty: _selectedTime == null,
                    child: new DropdownButton<TimeOfDay>(
                      value: _selectedTime,
                      isDense: true,
                      onChanged: (TimeOfDay newValue) {
                        setState(() {
                          if(newValue != _selectedTime || _selectedTime == null){
                            _selectedTime = newValue;
                            _rebuildSelDateTimeStr();
                          }
                        });
                      },
                      items: _availableTimes.map((TimeOfDay value){
                        return DropdownMenuItem<TimeOfDay>(
                          value: value,
                          child: Text(_timeOfDayToString(value)),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }
            }
            else
              return DropdownButtonHideUnderline(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Please select a date first.',
                  ),
                  isEmpty: true,
                  child: null,
                ),
              );
          },
        );




      },
    );
  }

  String _timeOfDayToString(TimeOfDay tod){
    int hr = tod.hour;
    String outStr = "";
    bool PM = false;
    if(hr > 12){
      PM = true;
      hr = hr - 12;
    }
    else if(hr == 12)
      PM = true;
    outStr += sprintf("%02d:%02d", [hr, tod.minute]);
    if(PM)
      outStr += " PM";
    else
      outStr += " AM";

    return outStr;
  }

  void _rebuildSelDateTimeStr(){
    if (_selectedDate != null) {
      setState(() {
        _selDateTimeStr = "Selected: ";
        switch (_selectedDate.weekday) {
          case 1:
            _selDateTimeStr += "Monday";
            break;
          case 2:
            _selDateTimeStr += "Tuesday";
            break;
          case 3:
            _selDateTimeStr += "Wednesday";
            break;
          case 4:
            _selDateTimeStr += "Thursday";
            break;
          case 5:
            _selDateTimeStr += "Friday";
            break;
          case 6:
            _selDateTimeStr += "Saturday";
            break;
          case 7:
            _selDateTimeStr += "Sunday";
            break;
          default:
            _selDateTimeStr += "ERROR";
            break;
        }
        _selDateTimeStr += ", ${_selectedDate.month}/${_selectedDate.day}";
      });
    }
    if(_selectedTime != null) {
      setState(() {
        _selDateTimeStr += " at ";
        _selDateTimeStr += _timeOfDayToString(_selectedTime);
      });
    }
  }

  void _onRadioChange(int value){
    setState((){
      _videoMeeting = value;
    });
  }

  //TODO: complete submit function (check all fields filled out)
  void _submit(BuildContext context){
    DateTime submitDate;
    String videoLoc, noSpecLoc;

    setState((){
      _errorText = "";
      _isSubmitting = true;
    });

    //Verify the user input is complete.
    if(_nameInput.text.isEmpty || _muidInput.text.isEmpty ||
        _emailInput.text.isEmpty || _emailError != null ||
        _majorInput.text.isEmpty || _selectedDate == null ||
        _selectedTime == null ||
        (_selectedLocation == null && _videoMeeting == 0) ||
        _detailInput.text.isEmpty) {

      setState((){
        _errorText = "Please complete the following fields:\n";
        if(_nameInput.text.isEmpty)
          _errorText += "Name, ";
        if(_muidInput.text.isEmpty)
          _errorText += "MUID, ";
        if(_emailInput.text.isEmpty)
          _errorText += "Email, ";
        if(_majorInput.text.isEmpty)
          _errorText += "Major, ";
        if(_selectedDate == null)
          _errorText += "Date, ";
        if(_selectedTime == null)
          _errorText += "Time, ";
        if(_selectedLocation == null)
          _errorText += "Location, ";
        if(_detailInput.text.isEmpty)
          _errorText += "Additional Details";
      });
    }
    else {
      submitDate = new DateTime(  //changed to avoid exception
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,    //Adds time to DateTime for Firebase
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if(_videoMeeting != 0)
        videoLoc = "N/A";

      if(_specificLoc == null)  //To avoid null call, didn't fix it
        noSpecLoc = "No further info.";

      switch(_videoMeeting){
        case 0:
          _meetingType = "In-Person";
          break;
        case 1:
          _meetingType = "Video Conference";
          break;
        default:
          _meetingType = "Unknown";
          break;
      }

      _checkMeetingType(submitDate, videoLoc, noSpecLoc);
    }
  }

  Future<void> _checkMeetingType(DateTime submit, String vLoc, String sLoc) async{
    if(_videoMeeting == 1){
      SimpleDialog check = new SimpleDialog(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                    child: Text('NOTE: You and the assisting librarian are '
                        'responsible for arranging a video conference. '
                        'You will be contacted shortly to work this out. '
                        'Do you wish to proceed?')
                ),

                RaisedButton(
                  child: Text("Cancel"),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),

                RaisedButton(
                  child: Text("Proceed"),
                  onPressed: () async{
                      _entry = ApptData(
                        submit,   //changed to avoid exception
                        _selectedLocation == null ? vLoc : _selectedLocation,
                        _muidInput.text,
                        _nameInput.text,
                        _emailInput.text,
                        _majorInput.text,
                        _specificLoc == null ? sLoc : _specificLoc,
                        _detailInput.text,
                        _meetingType,
                      );

                      DocumentReference docRef = await mainReference.add(_entry.toJson());
                      //Store ID of newly made doc into shared prefs
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      List<String> keysList = prefs.getStringList(_prefsKey) ?? new List<String>();
                      keysList.add(docRef.documentID);
                      prefs.setStringList(_prefsKey, keysList);
                      setState((){
                        _specificLocItems = null;
                        _specificLoc = null;
                        _selectedLocation = null;
                      });
                      //get outta that page
                      Navigator.pop(context);
                      Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      );

      showDialog(
        barrierDismissible: false,
          context: context,
          builder: (context) { return check; }
      );
    }
    else {
      _entry = ApptData(
        submit,
        //changed to avoid exception
        _selectedLocation == null ? vLoc : _selectedLocation,
        _muidInput.text,
        _nameInput.text,
        _emailInput.text,
        _majorInput.text,
        _specificLoc == null ? sLoc : _specificLoc,
        _detailInput.text,
        _meetingType,
      );

      DocumentReference docRef = await mainReference.add(_entry.toJson());
      //Store ID of newly made doc into shared prefs
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keysList = prefs.getStringList(_prefsKey) ?? new List<String>();
      keysList.add(docRef.documentID);
      prefs.setStringList(_prefsKey, keysList);
      setState((){
        _specificLocItems = null;
        _specificLoc = null;
        _selectedLocation = null;
      });
      //get outta that page
      Navigator.pop(context);
    }
  }

  //TODO: Find a way to use this function?
  void _clear(){
    setState(() {
      _nameInput.clear();
      _muidInput.clear();
      _emailInput.clear();
      _majorInput.clear();
      _isLocChosen = false;
      _isDateChosen = false;
      _errorText = null;
      _selDateTimeStr = "No date selected.";
      _selectedDate = null;
      _selectedTime = null;
      _selectedLocation = null;
      _specificLoc = null;
    });
  }
}