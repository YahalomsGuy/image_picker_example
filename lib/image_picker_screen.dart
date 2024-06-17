import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as pck;
import 'dart:io';
import 'package:image/image.dart' as im;
import 'package:image_picker_example/cam_page.dart';
import 'package:image_picker_example/cam_red_page.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker_example/models/pixel.dart';

import 'base/glob.dart';

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
              const SizedBox(width: 60),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, CamPage.routeName);
                },
                label: const Text('Take Photo'),
                icon: const Icon(Icons.camera_alt_outlined),
              ),
            ],
          ),
          const SizedBox(height: 20),

          /// select and Crop
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () async => pickAndCrop(),
                label: const Text('Crop Photo'),
                icon: const Icon(Icons.crop),
              ),
              const SizedBox(width: 60),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, CamRedPage.routeName);
                },
                label: const Text('Take Red Photo'),
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

  pickAndCrop() async {
    try {
      final pck.ImagePicker picker = pck.ImagePicker();
      final img = await picker.pickImage(
        source: pck.ImageSource.gallery,
        maxWidth: 1000,
      );
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: img!.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );
      Uint8List imageBytes = await croppedFile?.readAsBytes() as Uint8List;
      //var decoder = pngJpg == "png" ? im.PngDecoder() : im.JpegDecoder();
      var decoder = im.JpegDecoder();
      im.Image? decodedImage = decoder.decode(imageBytes);

      int pixelsPerRow = decodedImage!.width;
      Uint8List dImgList = decodedImage.getBytes();

      List<Pixel> imageList = [];
      Pixel thePixel = Pixel(X: 0, Y: 0, R: 0, G: 0, B: 0, A: 0);
      int i = 0;

      while (i < dImgList.length - 4) {
        thePixel = Pixel(
          X: (i % (pixelsPerRow * 3)) ~/ 3,
          Y: (i ~/ 3) ~/ pixelsPerRow,
          R: dImgList[i],
          G: dImgList[i + 1],
          B: dImgList[i + 2],
          A: 0, //dImgList[i + 3],
        );
        imageList.add(thePixel);
        i = i + 3;
      }

      /// Find Black Pixels
      // for (Pixel pixelSearch in imageList) {
      //   if (pixelSearch.R < 50) {
      //     print(
      //         "Color - X: ${pixelSearch.X}, Y: ${pixelSearch.Y}, R: ${pixelSearch.R} , G: ${pixelSearch.G} , B: ${pixelSearch.B}");
      //   }
      // }

      /// rebuild Image from ROI bytes
      // List<int> allBytes = [];
      //
      // for (Pixel p in roiList) {
      //   allBytes.add(p.R);
      //   allBytes.add(p.G);
      //   allBytes.add(p.B);
      // }

      //theImageBytes = Uint8List.fromList(allBytes);
      int foundPixels = 0;

      // /// find Magentas
      // for (Pixel px in imageList) {
      //   if (px.R > 100 &&
      //       px.G < 100 &&
      //       px.B > 100 &&
      //       (px.R - px.G).abs() > 40) {
      //     //if ((pixelSearch.G - pixelSearch.R).abs() > 40) {
      //     print(
      //         "Pink - X: ${px.X.toString().padLeft(4, "0")}, Y: ${px.Y.toString().padLeft(4, "0")}, R: ${px.R.toString().padLeft(3, "0")} , G: ${px.G.toString().padLeft(3, "0")} , B: ${px.B.toString().padLeft(3, "0")}");
      //     foundPixels++;
      //   }
      // }

      /// find colors
      for (Pixel px in imageList) {
        if (px.R < 100 || px.G < 100 || px.B < 100) {
          print(
              "Pink - X: ${px.X.toString().padLeft(4, "0")}, Y: ${px.Y.toString().padLeft(4, "0")}, R: ${px.R.toString().padLeft(3, "0")} , G: ${px.G.toString().padLeft(3, "0")} , B: ${px.B.toString().padLeft(3, "0")}");
          foundPixels++;
        }
      }

      print("decoded Image: $decodedImage");
      print("pixels Per row: ${decodedImage.width}");
      print("Size of Data in the image: ${imageList.length}");
      print('Number of Pink Pixels found: $foundPixels');

      /// The random locations
      // print(
      //     "Size of the image: ${roiWidth.toInt() + 1} on ${roiHeight.toInt() + 1}");
      // print("Size of Data in the selected ROI: ${cutList.length}");
      //
      // List<Curr> currs = [
      //   Curr(name: "Center", value: cutList.length ~/ 2),
      //   Curr(name: "20", value: 20),
      //   Curr(name: "50", value: 50),
      //   Curr(name: "100", value: 100),
      //   Curr(name: "200", value: 200),
      //   Curr(name: "1500", value: 1500),
      // ];
      // for (Curr curr in currs) {
      //   if (curr.value <= cutList.length) {
      //     print(
      //         "${curr.name} - R: ${cutList[curr.value].R}, G: ${cutList[curr.value].G}, B: ${cutList[curr.value].B}");
      //   } else {
      //     print("${curr.name} is out of range");
      //   }
      // }
      /// The random locations - End
      // int cnsc = 0;
      // for (Pixel px in cutList) {
      //   if (px.R < 50) {
      //     cnsc++;
      //     print(
      //         "Pixel: ${cutList.indexOf(px)} - X: ${px.X}, Y: ${px.Y}, R: ${px.R}, G: ${px.G}, B: ${px.B} : Consecutive: $cnsc");
      //   } else {
      //     if (cnsc > 3) {
      //       print("Pixel: ${cutList.indexOf(px)}");
      //       cnsc = 0;
      //     }
      //   }
      // }
      print("done");
      // for (Pixel pixel in myList) {
      //   if (pixel.R == 0 && pixel.G == 0 && pixel.B == 0 && lastWasBlack) {
      //     blacksInRow++;
      //     print(
      //         "Found Another Black Pixel in Row: ${myList.indexOf(pixel) ~/ pixelsPerRow + 1}, Pixel: ${myList.indexOf(pixel) % pixelsPerRow + 1}, Blacks in Row $blacksInRow");
      //   }
      //
      //   if (pixel.R == 0 && pixel.G == 0 && pixel.B == 0) {
      //     if (!foundFirstPixel) {
      //       print(
      //           "Found the 1st Black Pixel in Row: ${myList.indexOf(pixel) ~/ pixelsPerRow + 1}, Pixel: ${myList.indexOf(pixel) % pixelsPerRow + 1}");
      //       foundFirstPixel = true;
      //       lastWasBlack = true;
      //       blacksInRow++;
      //     }
      //   } else {
      //     lastWasBlack = false;
      //     blacksInRow = 0;
      //   }
      // }
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  /// ////////////////////////////////////////////////////////////
  processImg01(pck.XFile? img, String pngJpg) async {
    try {
      Uint8List imageBytes = await img?.readAsBytes() as Uint8List;

      var decoder = pngJpg == "png" ? im.PngDecoder() : im.JpegDecoder();
      im.Image? decodedImage = decoder.decode(imageBytes);
      print(decodedImage);
      int pixelsPerRow = decodedImage!.width;
      int rows = decodedImage.height;
      bool foundFirstPixel = false;
      bool lastWasBlack = false;
      int blacksInRow = 0;
      Uint8List dImgList = decodedImage.getBytes();

      List<Pixel> myList = [];
      Pixel thePixel = Pixel(X: 0, Y: 0, R: 0, G: 0, B: 0, A: 0);
      int i = 0;

      while (i < dImgList.length - 4) {
        thePixel = Pixel(
          X: 0, Y: 0,
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

    var decoder = im.PngDecoder();
    im.Image? decodedImage = decoder.decode(imageBytes);
    print(decodedImage);
  }

  void processImg04(pck.XFile? img) async {
    Uint8List imageBytes = await img?.readAsBytes() as Uint8List;

    var decoder = im.PngDecoder();
    im.Image? decodedImage = decoder.decode(imageBytes);
    print(decodedImage);
  }

  getFirstBlack(im.Image decodedImage) {}
}
