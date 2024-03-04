import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image/image.dart' as image;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart' as pck;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ImagePickerScreen(),
    );
  }
}

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({Key? key}) : super(key: key);

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  pck.XFile? importedImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Image Picker Example'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final pck.ImagePicker picker = pck.ImagePicker();
                    final img =
                        await picker.pickImage(source: pck.ImageSource.gallery);
                    print(img);

                    // ///implement image_cropper
                    // var croppedFile = await ImageCropper().cropImage(
                    //   sourcePath: img!.path,
                    //   aspectRatioPresets: [
                    //     CropAspectRatioPreset.square,
                    //   ],
                    //   androidUiSettings: const AndroidUiSettings(
                    //       toolbarTitle: 'Cropper',
                    //       toolbarColor: Colors.deepOrange,
                    //       toolbarWidgetColor: Colors.white,
                    //       initAspectRatio: CropAspectRatioPreset.original,
                    //       lockAspectRatio: false),
                    // );

                    // List<int> imageBase64 = croppedFile.readAsBytesSync();
                    // String imageAsString = base64Encode(imageBase64);
                    //Uint8List imageBytes = base64.decode(imageAsString);
                    Uint8List imageBytes =
                        await img?.readAsBytes() as Uint8List;

                    var decoder = image.PngDecoder();
                    image.Image? decodedImage = decoder.decode(imageBytes);
                    print(decodedImage);
                    int pixelsPerRow = decodedImage!.width;
                    int rows = decodedImage!.height;
                    bool foundFirstPixel = false;
                    bool lastWasBlack = false;
                    int blacksInRow = 0;
                    Uint8List dImgList = decodedImage!.getBytes();

                    List<Pixel> myList = [];
                    Pixel thePixel = Pixel(R: 0, G: 0, B: 0, A: 0);
                    int i = 0;

                    while (i < dImgList.length) {
                      thePixel = Pixel(
                        R: dImgList[i],
                        G: dImgList[i + 1],
                        B: dImgList[i + 2],
                        A: 0, //dImgList[i + 3],
                      );
                      myList.add(thePixel);
                      i = i + 3;
                    }

                    for (Pixel pixel in myList) {
                      if (pixel.R == 0 &&
                          pixel.G == 0 &&
                          pixel.B == 0 &&
                          lastWasBlack) {
                        blacksInRow++;
                        print(
                            "Found Another Black Pixel in Row: ${myList.indexOf(pixel) ~/ pixelsPerRow + 1}, Pixel: ${myList.indexOf(pixel) % pixelsPerRow + 1}, Blacks in Row $blacksInRow");
                      }

                      if (pixel.R == 0 && pixel.G == 0 && pixel.B == 0) {
                        if (!foundFirstPixel) {
                          print(
                              "Found the 1st Black Pixel in Row: ${myList.indexOf(pixel) ~/ pixelsPerRow + 1}, Pixel: ${myList.indexOf(pixel) % pixelsPerRow + 1}");
                          foundFirstPixel = true;
                          lastWasBlack = true;
                          blacksInRow++;
                        }
                      } else {
                        lastWasBlack = false;
                        blacksInRow = 0;
                      }
                    }
                    setState(() {
                      importedImage = img;
                    });
                  } catch (e) {
                    print(e);
                  }
                },
                label: const Text('Choose Image'),
                icon: const Icon(Icons.image),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final pck.ImagePicker picker = pck.ImagePicker();
                  final img =
                      await picker.pickImage(source: pck.ImageSource.camera);
                  setState(() {
                    importedImage = img;
                  });
                },
                label: const Text('Take Photo'),
                icon: const Icon(Icons.camera_alt_outlined),
              ),
            ],
          ),
          if (importedImage != null)
            Expanded(
              child: Column(
                children: [
                  Expanded(child: Image.file(File(importedImage!.path))),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        importedImage = null;
                      });
                    },
                    label: const Text('Remove Image'),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }
}

class Pixel {
  Pixel({
    required this.R,
    required this.G,
    required this.B,
    required this.A,
  });

  int R;
  int G;
  int B;
  int A;
}
