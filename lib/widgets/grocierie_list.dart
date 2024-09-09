import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_list/data/categories.dart';
import 'package:shop_list/models/crocery_item.dart';
import 'package:shop_list/widgets/grocierie_inputs.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groseryitems = [];
  var _isloading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    _loaddata();
  }

  void _loaddata() async {
    final url = Uri.https(
        'flutter-prep-fee16-default-rtdb.firebaseio.com', "shopping-list.json");
    try{
      final response = await http.get(url);
    if (response.statusCode >= 400) {
      setState(() {
        error = "Faield to Fetch data. please try again later.";
      });
        return;

    }
    if(response.body == 'null'){
      setState(() {
  _isloading=false;
});
      return;
    }
    final Map<String, dynamic> listdata = json.decode(response.body);
    final List<GroceryItem> loaditems = [];
    for (final item in listdata.entries) {
      final category = categories.entries
          .firstWhere(
              (catitem) => catitem.value.title == item.value['category'])
          .value;
      loaditems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    setState(() {
      _groseryitems = loaditems;
      _isloading = false;
    });
    }catch(e){
       setState(() {
        error = "Something went wrong!. please try again later.";
      });
    }
  }

  void _additem() async {
    final newitem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const GrocieriInputs()));
    if (newitem == null) {
      return;
    }
    setState(() {
      _groseryitems.add(newitem);
    });
  }

  void _remoiveitem(GroceryItem item) async{
    final index = _groseryitems.indexOf(item);
     setState(() {
      _groseryitems.remove(item);
    });
    final url = Uri.https(
        'flutter-prep-fee16-default-rtdb.firebaseio.com', 'shopping-list/${item.id}.json');
   final response= await http.delete(url);
   if (response.statusCode >= 400) {
     snackbar();
     setState(() {
      _groseryitems.insert(index, item);
    });
   } 
   
  }

  void snackbar() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sorry you can not delet item now!")));
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        "No items add yet.",
        style: TextStyle(color: Colors.white),
      ),
    );
    if (_isloading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groseryitems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groseryitems.length,
        itemBuilder: (ctx, index) {
          return Dismissible(
              background: Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onDismissed: (direction) {
                _remoiveitem(_groseryitems[index]);
              },
              key: ValueKey(_groseryitems[index].id),
              child: ListTile(
                leading: SizedBox(
                  height: 20,
                  width: 20,
                  child: Container(color: _groseryitems[index].category.color),
                ),
                title: Text(
                  _groseryitems[index].name,
                ),
                trailing: Text(_groseryitems[index].quantity.toString()),
              ));
        },
      );
    }

    if (error != null) {
      content = Center(
        child: Text(error!, style: const TextStyle(color: Colors.white)),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Grocieres"),
          actions: [
            IconButton(onPressed: _additem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}
