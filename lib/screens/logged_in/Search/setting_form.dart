import 'package:flutter/material.dart';
import 'package:unico/shared/style.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();

  final List<String> types = ["T-shirt","Sun Dress", "Undershirt","button shirt"];
  final List<String> designedByList = ["Unico Users","Professional Designer", "Celebrity"];
  // form values
  String? _type;
  String? _designBy;
  final fromPriceController = TextEditingController();
  final toPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          const Text("Add Search Settings", style: TextStyle(fontSize: 18),),
          const SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(child:
              TextFormField(
                decoration: textInputDecoration,
                validator: (value){},
                controller: fromPriceController,
              ),),
              const SizedBox(width: 5,),
              Flexible(child:
              TextFormField(
                decoration: textInputDecoration,
                validator: (value){},
                controller: toPriceController,
              ),),
            ],
          ),
          const SizedBox(height: 15,),
          // dropdown
          DropdownButtonFormField(
            decoration: textInputDecoration,
            value: _type,
            items: types.map((type) => DropdownMenuItem(value: type,child: Text(type))).toList(),
            onChanged: (val) => setState(() => _type = val.toString()),
          ),
          // slider
          ElevatedButton(child: const Text("Update",),
            onPressed: () async {},
              )
        ],
      ),
    );
  }
}
