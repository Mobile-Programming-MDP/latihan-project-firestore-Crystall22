import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/models/note.dart';
import 'package:path/path.dart' as path;
import 'dart:io' as io;

class NoteService {
  static final FirebaseFirestore _database = FirebaseFirestore.instance;
  static final CollectionReference _notesCollection = _database.collection('notes');
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      String fileName = path.basename(imageFile.path);
      Reference ref = _storage.ref().child('images/$fileName');

      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = ref.putData(await imageFile.readAsBytes());
      } else {
        uploadTask = ref.putFile(io.File(imageFile.path));
      }

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('Upload complete: $downloadUrl'); // Debugging line
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e'); // Debugging line
      return null;
    }
  }

  static Future<void> addNote(Note note) async {
    try {
      Map<String, dynamic> newNote = {
        'title': note.title,
        'description': note.description,
        'image_url': note.imageUrl,
        'lat': note.lat,
        'lng': note.lng,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };
      await _notesCollection.add(newNote);
      print('Note added successfully'); // Debugging line
    } catch (e) {
      print('Error adding note: $e'); // Debugging line
    }
  }

  static Future<void> updateNote(Note note) async {
    try {
      Map<String, dynamic> updatedNote = {
        'title': note.title,
        'description': note.description,
        'image_url': note.imageUrl,
        'lat': note.lat,
        'lng': note.lng,
        'created_at': note.createdAt,
        'updated_at': FieldValue.serverTimestamp(),
      };
      await _notesCollection.doc(note.id).update(updatedNote);
      print('Note updated successfully'); // Debugging line
    } catch (e) {
      print('Error updating note: $e'); // Debugging line
    }
  }

  static Future<void> deleteNote(Note note) async {
    try {
      await _notesCollection.doc(note.id).delete();
      print('Note deleted successfully'); // Debugging line
    } catch (e) {
      print('Error deleting note: $e'); // Debugging line
    }
  }

  static Future<QuerySnapshot> retrieveNotes() async {
    try {
      return await _notesCollection.get();
    } catch (e) {
      print('Error retrieving notes: $e'); // Debugging line
      rethrow;
    }
  }

  static Stream<List<Note>> getNoteList() {
    return _notesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Note(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          imageUrl: data['image_url'],
          lat: data['lat'],
          lng: data['lng'],
          createdAt: data['created_at'] != null ? data['created_at'] as Timestamp : null,
          updatedAt: data['updated_at'] != null ? data['updated_at'] as Timestamp : null,
        );
      }).toList();
    });
  }
}
