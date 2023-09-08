// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:passer/widgets/events_list_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _eventNameController = TextEditingController();
    final TextEditingController _eventDescriptionController =
        TextEditingController();

    // final _eventsStream = Supabase.instance.client
    //     .from("events")
    //     .stream(primaryKey: ["id"]).eq(
    //         "user_id", Supabase.instance.client.auth.currentSession?.user.id);

    final _eventsStream =
        Supabase.instance.client.from("events").stream(primaryKey: ["id"]);

    return Scaffold(
      appBar: AppBar(
        title: Text("Events"),
        backgroundColor: Colors.cyan,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return EventsListItem(
                  event: events[index],
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => {
                showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Text("Create Event",
                                  style: TextStyle(fontSize: 20)),
                              TextField(
                                decoration: const InputDecoration(
                                    hintText: "Enter event name"),
                                controller: _eventNameController,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                    hintText: "Enter description"),
                                controller: _eventDescriptionController,
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    await Supabase.instance.client
                                        .from("events")
                                        .insert({
                                      "name": _eventNameController.text,
                                      "description":
                                          _eventDescriptionController.text
                                    });
                                  },
                                  child: const Text("Create event")),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                )
              },
          child: const Icon(Icons.add)),
    );
  }
}
