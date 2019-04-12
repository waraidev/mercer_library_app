import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'fire_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainForm extends StatefulWidget{
  @override
  _MainFormState createState() => _MainFormState();
}

String dropdownValue;

class _MainFormState extends State<MainForm>{

  ApptData _entry;

  final mainReference = Firestore
      .instance.collection('appointments').document();

  DateTime _selectedDate;
  TimeOfDay _selectedTime;
  final double _pad = 10;
  String _selDateTimeStr, _selectedLocation,
      _specificLoc, _errorText, _emailError;
  bool _isLocChosen, _isDateChosen;
  static final List<String> _dropdownItems = <String>[
    'Connell Student Center', 'Mercer Village', 'University Center',
    'Tarver Library', "Einstein's", 'Stetson Computer Labs'
  ];
  static List<String> _specificLocItems;

  TextEditingController _nameInput = TextEditingController();
  TextEditingController _muidInput = TextEditingController();
  TextEditingController _emailInput = TextEditingController();
  TextEditingController _majorInput = TextEditingController();

  @override
  void dispose(){
    super.dispose();
    _nameInput.dispose();
    _muidInput.dispose();
    _emailInput.dispose();
    _majorInput.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
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

                  SizedBox(height: _pad - 1),

                  Container(
                    height: 50,
                    child: RaisedButton(
                      child: Text("Select a date/time..."),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());

                        _selectDateTime(context);
                      },
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
    if(_emailInput.text.contains("@") && _emailInput.text.contains(".") &&
        _emailInput.text.lastIndexOf(".") > _emailInput.text.indexOf("@"))
      _emailError = null;
    else
      _emailError = "Invalid email address";
  }

  void _selectDateTime(BuildContext context) async {
    DateTime today = DateTime.now();
    final DateTime datePicked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2101),
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
    if(_isLocChosen) {
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
        _specificLocItems = <String>["ZBeans", "Outside Bookstore"];
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

  Widget _timePicker(BuildContext context){
    if(_isDateChosen){
      List<TimeOfDay> _availableTimes = new List<TimeOfDay>();
      _availableTimes.add(TimeOfDay.now());
      //TODO: Populate times here
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
              }).toList(), //TODO: populate times once Firebase is online
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

  //TODO: complete submit function (check all fields filled out)
  void _submit(BuildContext context){
    if(_nameInput.text.isEmpty || _muidInput.text.isEmpty ||
        _emailInput.text.isEmpty || _emailError != null ||
        _majorInput.text.isEmpty ||
        _selectedDate == null || _selectedTime == null ||
        _selectedLocation == null)
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
      });
    else {
      _selectedDate = new DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,    //Adds time to DateTime for Firebase
        _selectedTime.hour,
        _selectedTime.minute
      );
      _entry = ApptData(
          _selectedDate,
          _selectedLocation,
          _muidInput.text,
          _nameInput.text,
          _emailInput.text,
          _majorInput.text,
          _specificLoc
      );

      mainReference.setData(_entry.toJson());

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