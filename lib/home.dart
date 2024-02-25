import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_firebasereal/firebase_init.dart';

class HomePage extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final CollectionReference _notesRef =
  FirebaseFirestore.instance.collection('notes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore CRUD Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _notesRef.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text(doc['title']),
                      subtitle: Text(doc['content']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _notesRef.doc(doc.id).delete();
                        },
                      ),
                      onTap: () {
                        _showEditDialog(context, doc.id, doc['title'], doc['content']);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(labelText: 'Content'),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _notesRef.add({
                      'title': _titleController.text,
                      'content': _contentController.text,
                    });
                    _titleController.clear();
                    _contentController.clear();
                  },
                  child: Text('Add Note'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String docId, String title, String content) {
    _titleController.text = title;
    _contentController.text = content;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _notesRef.doc(docId).update({
                  'title': _titleController.text,
                  'content': _contentController.text,
                });
                _titleController.clear();
                _contentController.clear();
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}