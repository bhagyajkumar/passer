import 'package:flutter/material.dart';

class EventsListItem extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventsListItem({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed("/passes", arguments: {"eventId": event["id"]});
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.event,
              size: 36, // Adjust icon size as needed
            ),
            const SizedBox(width: 16), // Add spacing between icon and text
            Text(
              event["name"],
              style: const TextStyle(
                fontSize: 18, // Adjust text size as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}
