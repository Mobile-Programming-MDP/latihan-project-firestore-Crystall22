import 'dart:html';
import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/screens/google_maps_screen.dart';
import 'package:notes/screens/map_screen.dart';
import 'package:notes/services/note_service.dart';
import 'package:notes/widgets/note_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: const NoteList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return NoteDialog();
            },
          );
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteList extends StatelessWidget {
  const NoteList({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: NoteService.getNoteList(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          default:
            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: snapshot.data!.map((document) {
                return Card(
                  child: ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return NoteDialog(note: document);
                        },
                      );
                    },
                    title: Text(document.title),
                    subtitle: Text(document.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        document.lat != null && document.lng != null
                            ? InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GoogleMapScreen(
                                          document.lat, document.lng),
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Icon(Icons.map),
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Icon(
                                  Icons.map,
                                  color: Colors.grey,
                                ),
                              ),
                        InkWell(
                          onTap: () {
                            showAlertDialog(context, document);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Icon(Icons.delete),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
        }
      },
    );
  }

  Future<void> openMap(String? lat, String? lng) async {
    Uri uri =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat, $lng");
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  showAlertDialog(BuildContext context, Note document) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = ElevatedButton(
      child: const Text("Yes"),
      onPressed: () {
        NoteService.deleteNote(document).whenComplete(() {
          Navigator.of(context).pop();
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete Note"),
      content: const Text("Are you sure to delete Note?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
