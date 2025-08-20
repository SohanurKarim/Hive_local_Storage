import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';


class Example extends StatefulWidget {
  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  Box? notepad;

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _updateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    notepad = Hive.box('notepad');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Notepad++', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
        child: Column(
          children: [
            // Input field
            TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: 'Write something...'),
            ),

            // Add button
            Container(
              width: 400,
              margin: EdgeInsets.symmetric(vertical: 12),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final userInput = _controller.text.trim();
                    if (userInput.isEmpty) return;

                    final now = DateTime.now();

                    await notepad!.add({
                      'text': userInput,
                      'timestamp': now.toIso8601String(),
                    });

                    _controller.clear();
                    Fluttertoast.showToast(msg: 'Added successfully');
                  } catch (e) {
                    Fluttertoast.showToast(msg: e.toString());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Add new data"),
              ),
            ),

            // Notes list
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box('notepad').listenable(),
                builder: (context, box, widget) {
                  final keys = box.keys.toList();

                  if (keys.isEmpty) {
                    return Center(
                      child: Text(
                        "No notes yet!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: keys.length,
                    itemBuilder: (_, index) {
                      final key = keys[index];
                      final item = box.get(key);

                      // Handle old String data
                      if (item is String) {
                        return _buildOldNoteCard(item);
                      }

                      // Handle new Map data
                      else if (item is Map) {
                        return _buildNewNoteCard(item, key, box);
                      }

                      // Unknown data type
                      else {
                        return SizedBox.shrink();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card for old notes (String only, no timestamp)
  Widget _buildOldNoteCard(String text) {
    return Card(
      elevation: 5,
      child: ListTile(
        title: Text(text),
        subtitle: Text("Old data (no timestamp)"),
      ),
    );
  }

  /// Card for new notes (Map with text + timestamp)
  Widget _buildNewNoteCard(Map item, dynamic key, Box box) {
    final text = item['text'] ?? '';
    final timestamp = item['timestamp'];

    String formattedDate = '';
    if (timestamp != null) {
      formattedDate =
          DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(timestamp));
    }

    return Dismissible(
      key: ValueKey(key),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        await box.delete(key);
        Fluttertoast.showToast(msg: 'Deleted successfully');
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 5,
        child: ListTile(
          title: Text(text),
          subtitle: Text(formattedDate),
          onLongPress: () {
            _updateController.text = text;
            showDialog(
              context: context,
              builder: (_) {
                return Dialog(
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _updateController,
                          decoration: InputDecoration(hintText: 'Update data'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final updatedData = _updateController.text.trim();
                            if (updatedData.isEmpty) return;

                            await box.put(key, {
                              'text': updatedData,
                              'timestamp': DateTime.now().toIso8601String(),
                            });
                            _updateController.clear();
                            Navigator.pop(context);
                          },
                          child: Text('Update'),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

