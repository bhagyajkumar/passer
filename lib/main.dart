import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:passer/scanned_ticket.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _formKey = GlobalKey<FormState>();
ScreenshotController sscontroller = ScreenshotController();

Future<void> main() async {
  await Supabase.initialize(
      url: 'https://gitqqdlhyjvkcaarhoqk.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdpdHFxZGxoeWp2a2NhYXJob3FrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTMzODEwOTksImV4cCI6MjAwODk1NzA5OX0.RCJlX83-zxbjPl4XlUf_tSXz83d3FT_4s8DwPYivk_Q');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passer',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Passer'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _name = "";
  String _details = "";
  QRViewController? controller;
  String _result = "";

  final _passesStream =
      Supabase.instance.client.from("passes").stream(primaryKey: ["id"]);

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _passesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final passes = snapshot.data!;
            return ListView.builder(
              itemCount: passes.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                          "Would you like to delete this pass"),
                                    ),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                            onPressed: () async {
                                              await Supabase.instance.client
                                                  .from("passes")
                                                  .delete()
                                                  .match({
                                                "id": passes[index]["id"]
                                              });
                                              Navigator.maybePop(context);
                                            },
                                            child: const Text("Delete")),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).maybePop();
                                            },
                                            child: const Text("Cancel")),
                                      ],
                                    )
                                  ]),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Ink(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person),
                              !passes[index]["is_used"]
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : const Icon(Icons.wrong_location)
                            ],
                          ),
                          Text(
                            passes[index]["name"],
                          ),
                          ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        title: const Text("Food Pass"),
                                        children: [
                                          Screenshot(
                                            controller: sscontroller,
                                            child: Container(
                                              color: Colors.white,
                                              child: Column(
                                                children: [
                                                  const Text("Food Pass",
                                                      style: TextStyle(
                                                          fontSize: 28)),
                                                  SizedBox(
                                                    height: 200,
                                                    width: 200,
                                                    child: Center(
                                                      child: QrImageView(
                                                        data: passes[index]
                                                            ["id"],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: () async {
                                                dynamic image =
                                                    await sscontroller
                                                        .capture();
                                                final tempDir =
                                                    await getTemporaryDirectory();
                                                File file = await File(
                                                        '${tempDir.path}/image.png')
                                                    .create();
                                                file.writeAsBytesSync(image);
                                                final _result =
                                                    await Share.shareXFiles(
                                                  [
                                                    XFile(
                                                        '${tempDir.path}/image.png')
                                                  ],
                                                );
                                              },
                                              icon: const Icon(Icons.share))
                                        ],
                                      );
                                    });
                              },
                              child: const Text("Get pass"))
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: Row(
        children: [
          const Spacer(),
          FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller?.toggleFlash();
                          },
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: QRView(
                                key: GlobalKey(debugLabel: 'QR'),
                                onQRViewCreated: (QRViewController controller) {
                                  this.controller = controller;
                                  controller.scannedDataStream
                                      .listen((scanData) {
                                    controller.dispose();
                                    controller.stopCamera();
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return ScannedPassPage(
                                        data: scanData.code ?? "",
                                      );
                                    }));
                                  });
                                }),
                          ),
                        ),
                        Text(_result)
                      ],
                    );
                  });
            },
            child: const Icon(Icons.camera),
          ),
          FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: const Text("Create a new Pass"),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  decoration:
                                      const InputDecoration(hintText: "Name"),
                                  onChanged: (value) => setState(() {
                                    _name = value;
                                  }),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter a value";
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                      hintText: "Details"),
                                  onChanged: (value) => setState(() {
                                    _details = value;
                                  }),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter a value";
                                    }
                                    return null;
                                  },
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        await Supabase.instance.client
                                            .from("passes")
                                            .insert({
                                          "name": _name,
                                          "details": _details
                                        });
                                      }
                                    },
                                    child: const Text("Create a pass"))
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  });
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
