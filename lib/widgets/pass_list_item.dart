import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class passListItem extends StatelessWidget {
  final int index;
  final ScreenshotController sscontroller;
  const passListItem(
      {super.key,
      required this.passes,
      required this.index,
      required this.sscontroller});

  final List<Map<String, dynamic>> passes;

  @override
  Widget build(BuildContext context) {
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Would you like to delete this pass"),
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  await Supabase.instance.client
                                      .from("passes")
                                      .delete()
                                      .match({"id": passes[index]["id"]});
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
                                          style: TextStyle(fontSize: 28)),
                                      SizedBox(
                                        height: 200,
                                        width: 200,
                                        child: Center(
                                          child: QrImageView(
                                            data: passes[index]["id"],
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
                                        await sscontroller.capture();
                                    final tempDir =
                                        await getTemporaryDirectory();
                                    File file =
                                        await File('${tempDir.path}/image.png')
                                            .create();
                                    file.writeAsBytesSync(image);
                                    await Share.shareXFiles(
                                      [XFile('${tempDir.path}/image.png')],
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
  }
}
