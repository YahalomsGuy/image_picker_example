import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as pck;
import 'dart:io';
import 'package:image/image.dart' as image;
import 'package:image_picker_example/cam_page.dart';

class ImagePickerScreen extends StatefulWidget {
  static const routeName = "/image_picker_page";
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
                    processImg01(img, "png");
                  } catch (e) {
                    print(e);
                  }
                },
                label: const Text('Choose Image'),
                icon: const Icon(Icons.image),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, CamPage.routeName);
                  // final pck.ImagePicker picker = pck.ImagePicker();
                  // final img =
                  //     await picker.pickImage(source: pck.ImageSource.camera);
                  // processImg01(img, "jpg");
                  // setState(() {
                  //   importedImage = img;
                  // });
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

  processImg01(pck.XFile? img, String pngJpg) async {
    try {
      Uint8List imageBytes = await img?.readAsBytes() as Uint8List;

      var decoder = pngJpg == "png" ? image.PngDecoder() : image.JpegDecoder();
      image.Image? decodedImage = decoder.decode(imageBytes);
      print(decodedImage);
      int pixelsPerRow = decodedImage!.width;
      int rows = decodedImage.height;
      bool foundFirstPixel = false;
      bool lastWasBlack = false;
      int blacksInRow = 0;
      Uint8List dImgList = decodedImage.getBytes();

      List<Pixel> myList = [];
      Pixel thePixel = Pixel(R: 0, G: 0, B: 0, A: 0);
      int i = 0;

      while (i < dImgList.length - 4) {
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
        if (pixel.R == 0 && pixel.G == 0 && pixel.B == 0 && lastWasBlack) {
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
      debugPrint("ERROR: $e");
    }
  }

  void processImg02(pck.XFile? img) async {
    Uint8List imageBytes = await img?.readAsBytes() as Uint8List;

    var decoder = image.PngDecoder();
    image.Image? decodedImage = decoder.decode(imageBytes);
    print(decodedImage);
  }

  getFirstBlack(image.Image decodedImage) {}
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
