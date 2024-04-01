import 'dart:ffi';
import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/NotesModel.dart';
import 'package:notesapp/logIn.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  var list = <NotesModel>[];
  @override
  void initState() {
    super.initState();
    getValues();
  }

  getValues() {
    _firebaseFirestore.collection("notes").get().then((value) {
      print("value $value");
      for (int i = 0; i < value.docs.length; i++) {
        var note = value.docs[i].data() as Map<String, dynamic>;
        var notesModel = NotesModel.fromJson(note);
        notesModel.id = value.docs[i].id;
        list.add(notesModel);
        setState(() {});
        print("note ${notesModel.toJson()}");
      }
    });
  }

  void _showDialogFunction() {
    var formKey = GlobalKey<FormState>();
    var titlecontroller = TextEditingController();
    var descriptioncontroller = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext Context) {
          return AlertDialog(
            title: Text(
              "enter Note",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            content: Form(
                child: Column(
              children: [
                TextFormField(
                  controller: titlecontroller,
                ),
                TextFormField(
                  controller: descriptioncontroller,
                )
              ],
            )),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    var notes = NotesModel(
                        title: titlecontroller.toString(),
                        description: descriptioncontroller.toString());
                    _firebaseFirestore
                        .collection("notes")
                        .add(notes.toJson())
                        .then((value) {
                      Navigator.pop(context);
                      getValues();
                    }).onError((error, stackTrace) {
                      print("error $error");
                    });
                  },
                  child: Text("Add notes")),
            ],
          );
        });
  }

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "log out ",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          ElevatedButton(
              onPressed: () {
                firebaseAuth.signOut().then((value) => Navigator.of(context)
                    .pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LogIn()),
                        (route) => false));
              },
              child: Text("log out")),
        ],
      ),
      body: ListView.builder(
          itemCount: list.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                print("list[index].id ${list[index].id}");
                _firebaseFirestore
                    .collection("notes")
                    .doc(list[index].id ?? "")
                    .delete()
                    .then((value) => getValues());
              },
              onDoubleTap: () {
                var titlecontroller = TextEditingController();
                var descriptioncontroller = TextEditingController();
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("update data"),
                        content: Form(
                            child: Column(
                          children: [
                            TextFormField(
                              controller: titlecontroller,
                            ),
                            TextFormField(
                              controller: descriptioncontroller,
                            )
                          ],
                        )),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                var notes = NotesModel(
                                    title: titlecontroller.toString(),
                                    description:
                                        descriptioncontroller.toString());
                                _firebaseFirestore
                                    .collection("notes")
                                    .doc(list[index].id)
                                    .set(notes.toJson())
                                    .then((value) {
                                  Navigator.of(context).pop();
                                  getValues();
                                }).onError((error, stackTrace) {
                                  print("error $error");
                                });
                              },
                              child: Text("update notes")),
                        ],
                      );
                    });
              },
              child: Text("list ${list[index].title ?? ""}"),
            );
          }),
      floatingActionButton: FloatingActionButton(onPressed: () {
        _showDialogFunction();
      }),
    );
  }
}
