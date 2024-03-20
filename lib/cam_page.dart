import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as im;

import 'image_picker_screen.dart';

class CamPage extends StatefulWidget {
  const CamPage({super.key});
  static const routeName = "/cam_page";
  @override
  State<CamPage> createState() => _CamPageState();
}

class _CamPageState extends State<CamPage> {
  late CameraController camCtrl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: initCamera(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                      aspectRatio: 3 / 4, child: CameraPreview(camCtrl)),
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Image.asset('assets/images/camOverlay.png',
                        fit: BoxFit.cover),
                  ),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3),
                      const Text(
                        "align QR with frame",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.38),
                      InkWell(
                        onTap: () => onTakePic(),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                        ),
                      )
                    ],
                  )
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  initCamera() async {
    var cameras = await availableCameras();
    camCtrl = CameraController(
      cameras[EnumCameraDescription.front.index],
      ResolutionPreset.low,
    );
    await camCtrl.initialize();
  }

  onTakePic() async {
    camCtrl.resolutionPreset;
    //camCtrl.setFlashMode(FlashMode.always);
    await camCtrl.takePicture().then((XFile? xFile) {
      if (mounted) {
        if (xFile != null) {
          print(xFile.path);
          processImg03(xFile, "jpg");
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("The QR"),
              content: CircleAvatar(
                radius: 60,
                backgroundImage: Image.file(File(xFile.path)).image,
              ),
            ),
          );
        }
        return;
      }
    });
  }

  processImg03(XFile? img, String pngJpg) async {
    try {
      Uint8List imageBytes = await img?.readAsBytes() as Uint8List;

      var decoder = pngJpg == "png" ? im.PngDecoder() : im.JpegDecoder();
      im.Image? decodedImage = decoder.decode(imageBytes);
      print(decodedImage);
      int pixelsPerRow = decodedImage!.width;
      Uint8List dImgList = decodedImage.getBytes();

      List<Pixel> myList = [];
      Pixel thePixel = Pixel(X: 0, Y: 0, R: 0, G: 0, B: 0, A: 0);
      int i = 0;

      while (i < dImgList.length - 4) {
        thePixel = Pixel(
          X: (i ~/ 3) ~/ 240,
          Y: (i % 720) ~/ 3,
          R: dImgList[i],
          G: dImgList[i + 1],
          B: dImgList[i + 2],
          A: 0, //dImgList[i + 3],
        );
        myList.add(thePixel);
        i = i + 3;
      }
      int roiXStart = 100;
      int roiXEnd = 200;
      int roiYStart = 100;
      int roiYEnd = 200;

      print(myList.length);
      List<Pixel> cutList = [];
      for (Pixel pixel in myList) {
        if (pixel.X > roiXStart &&
            pixel.X < roiXEnd &&
            pixel.Y > roiYStart &&
            pixel.Y < roiYEnd) {}
      }

      print(cutList.length);
      int cnsc = 0;
      for (Pixel px in cutList) {
        if (px.R < 50) {
          cnsc++;
          print(
              "Pixel: ${cutList.indexOf(px)} - X: ${px.X}, Y: ${px.Y}, R: ${px.R}, G: ${px.G}, B: ${px.B} : Consecutive: $cnsc");
        } else {
          if (cnsc > 3) {
            print("Pixel: ${cutList.indexOf(px)}");
            cnsc = 0;
          }
        }
      }
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
}

enum EnumCameraDescription { front, back }
