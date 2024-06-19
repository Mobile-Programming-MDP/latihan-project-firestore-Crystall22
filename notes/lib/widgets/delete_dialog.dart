import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/services/note_service.dart';

class DeleteDialog extends StatelessWidget {
  final Note note;

  const DeleteDialog({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Notes'),
      content: Text('Hapus note ${note.title}?'),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            NoteService.deleteNote(note);
            Navigator.of(context).pop();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
