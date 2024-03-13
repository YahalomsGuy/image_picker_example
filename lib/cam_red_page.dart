import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as im;
import 'package:screen_brightness/screen_brightness.dart';

import 'image_picker_screen.dart';

class CamRedPage extends StatefulWidget {
  const CamRedPage({super.key});
  static const routeName = "/cam_red_page";
  @override
  State<CamRedPage> createState() => _CamRedPageState();
}

class _CamRedPageState extends State<CamRedPage> {
  late CameraController camCtrl;

  bool chkRed = false;
  bool chkGreen = false;
  bool chkBlue = false;
  int roiLeft = 90;
  int roiWidth = 60;
  int roiTop = 220;
  int roiHeight = 60;
  late Size size;
  //Canvas canvas = Canvas();
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color.fromARGB(
          0, chkRed ? 255 : 0, chkGreen ? 255 : 0, chkBlue ? 255 : 0),
      body: Container(
        width: MediaQuery.of(context).size.width,
        color: Color.fromARGB(
            255, chkRed ? 255 : 0, chkGreen ? 255 : 0, chkBlue ? 255 : 0),
        child: FutureBuilder(
            future: initCamera(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    //CameraPreview(camCtrl),
                    //Image.asset('assets/images/redOverlay.png', fit: BoxFit.fill),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // mainAxisSize: MainAxisSize.max,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Align.......",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 24),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                color: chkRed && chkGreen && chkBlue
                                    ? Colors.black
                                    : Colors.white,
                                width: 250,
                                height: 50,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("R"),
                                    Checkbox(
                                        value: chkRed,
                                        onChanged: (checked) {
                                          print(checked);
                                          chkRed = checked!;
                                          setState(() {});
                                        }),
                                    Text("G"),
                                    Checkbox(
                                        value: chkGreen,
                                        onChanged: (checked) {
                                          print(checked);
                                          chkGreen = checked!;
                                          setState(() {});
                                        }),
                                    Text("B"),
                                    Checkbox(
                                        value: chkBlue,
                                        onChanged: (checked) {
                                          print(checked);
                                          chkBlue = checked!;
                                          setState(() {});
                                        }),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => onTakePic(),
                                child: CircleAvatar(
                                  backgroundColor: chkRed && chkGreen && chkBlue
                                      ? Colors.black
                                      : Colors.white,
                                  radius: 30,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    // Canvas().drawRect(rect, paint)
                  ],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }

  initCamera() async {
    try {
      await ScreenBrightness().setScreenBrightness(1);
      var cameras = await availableCameras();
      camCtrl = CameraController(
          cameras[EnumCameraDescription.back.index], ResolutionPreset.low,
          imageFormatGroup: ImageFormatGroup.yuv420);
      await camCtrl.initialize();
    } catch (e) {
      print(e);
    }
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
              title: Text("The QR"),
              content: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: Image.file(File(xFile.path)).image)),
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
          X: (i % 720) ~/ 3,
          Y: (i ~/ 3) ~/ 240,
          R: dImgList[i],
          G: dImgList[i + 1],
          B: dImgList[i + 2],
          A: 0, //dImgList[i + 3],
        );
        myList.add(thePixel);
        i = i + 3;
      }
      int roiLeft = 90;
      int roiWidth = 60;
      int roiTop = 220;
      int roiHeight = 60;

      print(myList.length);
      List<Pixel> cutList = [];
      for (Pixel pixel in myList) {
        if (pixel.X >= roiLeft &&
            pixel.X < roiLeft + roiWidth &&
            pixel.Y >= roiTop &&
            pixel.Y < roiTop + roiHeight) {
          pixel.X = pixel.X - roiLeft;
          pixel.Y = pixel.Y - roiTop;
          cutList.add(pixel);
        }
      }

      print(cutList.length);
      int curr = 1000;
      print(
          "1000 - R: ${cutList[curr].R}, G: ${cutList[curr].G}, B: ${cutList[curr].B}");
      curr = 2000;
      print(
          "3000 - R: ${cutList[curr].R}, G: ${cutList[curr].G}, B: ${cutList[curr].B}");
      curr = 3000;
      print(
          "3000 - R: ${cutList[curr].R}, G: ${cutList[curr].G}, B: ${cutList[curr].B}");

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
