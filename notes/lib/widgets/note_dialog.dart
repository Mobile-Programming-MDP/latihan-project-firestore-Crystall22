import 'dart:html' as html;  // Import for web-specific code
import 'dart:js' as js;      // Import for JavaScript interop
import 'package:flutter/foundation.dart';  // For kIsWeb check
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/models/note.dart';
import 'package:notes/services/location_service.dart';
import 'package:notes/services/note_service.dart';

class NoteDialog extends StatefulWidget {
  final Note? note;

  NoteDialog({super.key, this.note});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _imageFile;
  String? _imageUrl;
  Position? _position;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
      _imageUrl = widget.note!.imageUrl;
    }
  }

  Future<void> _getLocation() async {
    final location = await LocationService().getCurrentLocaton();
    setState(() {
      _position = location;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (kIsWeb && source == ImageSource.camera) {
      // For web, we need to use HTML5 API to open the camera
      await _pickImageFromCameraWeb();
    } else {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _isUploading = true; // Show loading indicator
        });
        await _uploadImage(pickedFile);
      }
    }
  }

  Future<void> _pickImageFromCameraWeb() async {
    final picker = html.FileUploadInputElement()
      ..accept = 'image/*';
    
    // Set the capture attribute using JavaScript
    js.context.callMethod('setAttribute', [picker, 'capture', 'environment']);
    
    picker.click();
    picker.onChange.listen((event) {
      final files = picker.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((e) async {
          final bytes = reader.result as List<int>;
          setState(() {
            _imageFile = XFile(file.name, bytes: Uint8List.fromList(bytes));
            _isUploading = true; // Show loading indicator
          });
          await _uploadImage(_imageFile!);
        });
      }
    });
  }

  Future<void> _uploadImage(XFile imageFile) async {
    final imageUrl = await NoteService.uploadImage(imageFile);
    setState(() {
      _imageUrl = imageUrl;
      _isUploading = false; // Hide loading indicator
    });
    print('Uploaded Image URL: $_imageUrl'); // Debugging line
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.note == null ? 'Add Notes' : 'Update Notes'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Title: ', textAlign: TextAlign.start),
          TextField(
            controller: _titleController,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text('Description: '),
          ),
          TextField(
            controller: _descriptionController,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text('Image: '),
          ),
          _isUploading
              ? const Center(child: CircularProgressIndicator())
              : _imageUrl != null
                  ? Image.network(_imageUrl!, fit: BoxFit.cover)
                  : Container(),
          TextButton(
            onPressed: () => _showImageSourceActionSheet(context),
            child: const Text('Pick Image: '),
          ),
          TextButton(
            onPressed: _getLocation,
            child: const Text('Get Location: '),
          ),
          Text(
            _position?.latitude != null && _position?.longitude != null
                ? "Current Location: ${_position!.latitude}, ${_position!.longitude}"
                : "Current Location: ${widget.note?.lat}, ${widget.note?.lng}",
            textAlign: TextAlign.start,
          ),
        ],
      ),
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
          onPressed: () async {
            // Get the image URL from the uploaded image
            String? imageUrl = _imageUrl ?? widget.note?.imageUrl;

            // Get the current location if no location is available
            String latitude = _position?.latitude.toString() ?? widget.note?.lat.toString() ?? "";
            String longitude = _position?.longitude.toString() ?? widget.note?.lng.toString() ?? "";

            // Create a Note object based on the current state
            Note note = Note(
              id: widget.note?.id,
              title: _titleController.text,
              description: _descriptionController.text,
              imageUrl: imageUrl, // imageUrl can be null if no image is selected
              lat: latitude,
              lng: longitude,
              createdAt: widget.note?.createdAt,
            );

            if (widget.note == null) {
              await NoteService.addNote(note);
              Navigator.of(context).pop();
            } else {
              await NoteService.updateNote(note);
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.note == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
