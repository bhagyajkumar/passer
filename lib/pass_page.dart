import 'package:flutter/material.dart';
import 'package:passer/scanned_ticket.dart';
import 'package:passer/widgets/pass_list_item.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class PassPage extends StatefulWidget {
  const PassPage({super.key});

  @override
  State<PassPage> createState() => _PassPageState();
}

class _PassPageState extends State<PassPage> {
  String _name = "";
  String _details = "";
  QRViewController? controller;
  String _result = "";
  final _formKey = GlobalKey<FormState>();
  final ScreenshotController sscontroller = ScreenshotController();

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
        title: Text("Passer"),
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
                return passListItem(
                  passes: passes,
                  index: index,
                  sscontroller: sscontroller,
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
                            controller?.scanInvert(true);
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
