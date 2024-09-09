import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shop_list/data/categories.dart';
import 'package:shop_list/models/crocery_item.dart';

class GrocieriInputs extends StatefulWidget {
  const GrocieriInputs({super.key});

  @override
  State<GrocieriInputs> createState() => _GrocieriInputsState();
}

class _GrocieriInputsState extends State<GrocieriInputs> {
  final _formlkey = GlobalKey<FormState>();
  var _enteredname = "";
  var _enteredquantity = 1;
  var _selectedcategory = categories.entries.first.value;
  var issending = false;
  void _saveitem() async {
    if (_formlkey.currentState!.validate()) {
      _formlkey.currentState!.save();
      setState(() {
        issending = true;
      });
      final url = Uri.https('flutter-prep-fee16-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': _enteredname,
            'quantity': _enteredquantity,
            'category': _selectedcategory.title
          }));
      final Map<String, dynamic> res = json.decode(response.body);
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(GroceryItem(
          id: res['name'],
          name: _enteredname,
          quantity: _enteredquantity,
          category: _selectedcategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formlkey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  label: Text("Name"),
                ),
                maxLength: 50,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.length > 50) {
                    return " Must be between 1 and 50 charchters";
                  }
                  _enteredname = value;
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Quantity"),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return " Must be vaild, positive number";
                        }
                        _enteredquantity = int.tryParse(value)!;
                        return null;
                      },
                      initialValue: "1",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        hint: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Container(
                                height: 16,
                                width: 16,
                                color: categories.entries.first.value.color,
                              ),
                            ),
                            Text(categories.entries.first.value.title)
                          ],
                        ),
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Container(
                                        height: 16,
                                        width: 16,
                                        color: category.value.color,
                                      ),
                                    ),
                                    Text(category.value.title)
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          _selectedcategory = value!;
                        }),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: issending
                          ? null
                          : () {
                              _formlkey.currentState!.reset();
                            },
                      icon: const Icon(Icons.refresh)),
                  ElevatedButton(
                      onPressed: _saveitem,
                      child: issending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator())
                          : const Text("Add Item"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
