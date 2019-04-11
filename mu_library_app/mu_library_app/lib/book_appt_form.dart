import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';

class MainForm extends StatefulWidget{
  @override
  _MainFormState createState() => _MainFormState();
}

String dropdownValue;

class _MainFormState extends State<MainForm>{

  DateTime _selectedDateTime;
  final double _pad = 10;
  String _selDateTimeStr, _dropdownValue, _dropdownValue2, _errorText;
  bool _locChosen;
  static final List<String> _dropdownItems = <String>[
    'Connell Student Center', 'Mercer Village', 'University Center'
  ];
  static List<String> _dropdownItems2;

  TextEditingController _nameInput = TextEditingController();
  TextEditingController _muidInput = TextEditingController();

  @override
  void dispose(){
    super.dispose();
    _nameInput.dispose();
    _muidInput.dispose();
  }

  @override
  void initState(){
    super.initState();
    _locChosen = false;
    _errorText = null;
    _selDateTimeStr = "No date selected.";
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
        },

        child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(_errorText ==  null ? "" : _errorText,
                    textScaleFactor: 1.4,
                    style: TextStyle(
                      color: Colors.red,
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
                    textScaleFactor: 1.35,),

                  DropdownButtonHideUnderline(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: _dropdownValue == null ?
                          'Please select a location...' : 'Location',
                      ),
                      isEmpty: _dropdownValue == null,
                      child: new DropdownButton<String>(
                        value: _dropdownValue,
                        isDense: true,
                        onChanged: (String newValue) {
                          setState(() {
                            _locChosen = false;
                            _dropdownValue = newValue;
                            _dropdownValue2 = null;
                            _locChosen = true;
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

                 _miniMap(context),
                ],
              ),
            ),
          ),
        ),
      ),

      //TODO: Fix the way this looks, or remove the trashcan button entirely
      floatingActionButton: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton(
            child: Icon(Icons.delete),
            heroTag: null,
            onPressed: _submit,
          ),

          Spacer(),

          FloatingActionButton(
            child: Icon(Icons.check),
            heroTag: null,
            onPressed: _submit,
          ),
        ],
      ),
    );
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
    //TODO: Change this to a drop down (since they are in discrete time slots)
    //Also it'll be easier to populate the available/taken time slots that way
    final TimeOfDay timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
    );
    if (timePicked != null && datePicked != null)
      setState(() {
        _selectedDateTime = DateTime(
          datePicked.year, datePicked.month, datePicked.day,
          timePicked.hour, timePicked.minute,
        );
        _selDateTimeStr = "Selected: ";
        switch(datePicked.weekday){
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
        _selDateTimeStr += ", ${_selectedDateTime.month}/${_selectedDateTime.day} at ";
        int hr = timePicked.hour;
        bool PM = false;
        if(hr > 12){
          PM = true;
          hr = hr - 12;
        }
        else if(hr == 12)
          PM = true;
        _selDateTimeStr += sprintf("%02d:%02d", [hr, timePicked.minute]);
        if(PM)
          _selDateTimeStr += " PM";
        else
          _selDateTimeStr += " AM";
      });
  }

  Widget _miniMap(BuildContext context){
    if(_locChosen) {
      if(_dropdownValue == "Connell Student Center")
        _dropdownItems2 = <String>["one"];
      else if(_dropdownValue == "Mercer Village")
        _dropdownItems2 = <String>["two"];
      else if(_dropdownValue == "University Center")
        _dropdownItems2 = <String>["three"];
      else
        _dropdownItems2 = <String>["null"];

      return DropdownButtonHideUnderline(
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: _dropdownValue2 == null ?
              'Specifically...' : 'Room',
          ),
          isEmpty: _dropdownValue2 == null,
          child: new DropdownButton<String>(
            value: _dropdownValue2,
            isDense: true,
            onChanged: (String newValue) {
              setState(() {
                _dropdownValue2 = newValue;
              });
            },
            items: _dropdownItems2.map((String value) {
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

  void _submit() async{
    if(_nameInput.text.isEmpty)
      setState((){
        _errorText = "ERROR";
      });
    else
      Navigator.pop(context);
  }
}