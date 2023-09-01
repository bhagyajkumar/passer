import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScannedPassPage extends StatefulWidget {
  final String data;
  ScannedPassPage({Key? key, required this.data}) : super(key: key);

  @override
  State<ScannedPassPage> createState() => _ScannedPassPageState();
}

class _ScannedPassPageState extends State<ScannedPassPage> {
  late Future<List<Map<String, dynamic>>> passData;

  @override
  void initState() {
    super.initState();
    passData = fetchPassData();
  }

  Future<List<Map<String, dynamic>>> fetchPassData() async {
    final response = await Supabase.instance.client
        .from("passes")
        .select("*")
        .eq("id", widget.data)
        .execute();

    final dataList = response.data as List<dynamic>;
    final typedDataList = dataList.cast<Map<String, dynamic>>();

    return typedDataList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: passData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.yellow,
              title: Text("Loading Ticket Data"),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.red,
              title: Text("Error loading ticket data"),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.red,
              title: Text("Invalid Ticket"),
            ),
          );
        } else {
          final data = snapshot.data![0];
          print(data.toString());
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: Text(data["name"]),
            ),
            body: Container(
              child: Column(
                children: [
                  Spacer(flex: 1),
                  Center(
                    heightFactor: 2,
                    child: ElevatedButton(
                        onPressed: () async {
                          print(data["id"]);
                          await Supabase.instance.client.from("passes").update(
                              {"is_used": true}).match({"id": data["id"]});
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                children: [Text("verified")],
                              );
                            },
                          );
                        },
                        child: Text("Close Pass")),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
