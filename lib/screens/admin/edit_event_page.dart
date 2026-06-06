import 'package:flutter/material.dart';
import 'package:nexevent/models/event_model.dart';
import 'package:nexevent/services/firestore_service.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage({super.key, required this.docId});

  final String docId;

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();
  final TextEditingController _controller5 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Event'),
        centerTitle: true,
        backgroundColor: Colors.blue[200],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Container(
          // color: Colors.pink[300],
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                  controller: _controller1,
                  decoration: InputDecoration(
                    hintText: 'name',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: _controller2,
                  decoration: InputDecoration(
                    hintText: 'description',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: _controller3,
                  decoration: InputDecoration(
                    hintText: 'venue',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: _controller4,
                  decoration: InputDecoration(
                    hintText: 'category',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.black),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  onPressed: () async {
                    await FirestoreService().updateEvent(
                      EventModel(
                        eventId: widget.docId,
                        name: _controller1.text.trim(),
                        description: _controller2.text.trim(),
                        venue: _controller3.text.trim(),
                        category: _controller4.text.trim(),
                      ),
                      widget.docId,
                    );
                    final snackbar = SnackBar(content: Text('Event Updated'));
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  },
                  child: Text('update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
