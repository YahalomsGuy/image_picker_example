// import 'dart:ffi';

import 'package:camera/camera.dart';
// import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker_example/base/glob.dart';
import 'package:image_picker_example/models/pixel.dart';
import 'package:image_picker_example/widgets/roi_size_widget.dart';
import 'dart:io';
import 'dart:typed_data';

import 'image_picker_screen.dart';
import 'package:image/image.dart' as im;
import 'package:screen_brightness/screen_brightness.dart';

class CamRedPage extends StatefulWidget {
  const CamRedPage({super.key});
  static const routeName = "/cam_red_page";
  @override
  State<CamRedPage> createState() => _CamRedPageState();
}

class _CamRedPageState extends State<CamRedPage> {
  late CameraController camCtrl;
  late Size size;
  Uint8List theImageBytes = Uint8List(0);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    print("Screen Size: Width - ${size.width}, Height - ${size.height}");
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: size.width,
          color: Color.fromARGB(
              255, chkRed ? 255 : 0, chkGreen ? 255 : 0, chkBlue ? 255 : 0),
          child: FutureBuilder(
              future: initCamera(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      Container(
                          width: size.width,
                          height: size.width * 1.5,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.greenAccent, width: 1)),
                          child: CameraPreview(camCtrl)),
                      const RoiSizeWidget(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // mainAxisSize: MainAxisSize.max,
                          children: [
                            const SizedBox(height: 0),
                            Column(
                              children: [
                                InkWell(
                                  onTap: () => onTakePic(),
                                  child: CircleAvatar(
                                    backgroundColor: chkRed && chkGreen
                                        ? Colors.black
                                        : Colors.white,
                                    radius: 30,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  color: chkRed && chkGreen
                                      ? const Color(0x88000000)
                                      : const Color(0x88FFFFFF),
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildCheckbox("Red: "),
                                      buildCheckbox("Green: "),
                                      buildCheckbox("Blue: "),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      ),
    );
  }

  Widget buildCheckbox(String text) {
    return Row(
      children: [
        Text(text),
        Checkbox(
            value: text == "Blue: "
                ? chkBlue
                : text == "Red: "
                    ? chkRed
                    : chkGreen,
            onChanged: (checked) {
              switch (text) {
                case "Blue: ":
                  chkBlue = checked!;
                  break;
                case "Green: ":
                  chkGreen = checked!;
                  break;
                case "Red: ":
                  chkRed = checked!;
                  break;
              }
              setState(() {});
            }),
      ],
    );
  }

  initCamera() async {
    try {
      List<CameraDescription> cameras = await availableCameras();
      await ScreenBrightness().setScreenBrightness(1);
      camCtrl = CameraController(
          cameras[EnumCameraDescription.front.index], ResolutionPreset.medium,
          imageFormatGroup: ImageFormatGroup.yuv420);
      await camCtrl.initialize();
    } catch (e) {
      print(e);
    }
  }

  onTakePic() async {
    camCtrl.resolutionPreset;
    //camCtrl.setFlashMode(FlashMode.always);
    await camCtrl.takePicture().then((XFile? xFile) async {
      if (mounted) {
        if (xFile != null) {
          print(xFile.path);
          await processImg03(xFile, "jpg");
          im.Image image = im.Image.fromBytes(
              width: 200, height: 200, bytes: theImageBytes.buffer);
          String newFilePath =
              "${xFile.path.substring(0, xFile.path.length - 6)}44.jpg";
          await XFile.fromData(theImageBytes).saveTo(newFilePath);

          //print(newFile.path);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("The QR"),
              content: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Image.file(File(newFilePath)).image,
                  ),
                ),
                //image: Image.file(File(xFile.path)).image)),
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

      print("Size of Data in the image: ${imageList.length}");

      ///Cut ROI from the full image
      List<Pixel> roiList = [];
      for (Pixel pixel in imageList) {
        if (pixel.X >= roiLeft &&
            pixel.X < roiLeft + roiWidth &&
            pixel.Y >= roiTop &&
            pixel.Y < roiTop + roiHeight) {
          // print(
          //     "Index: ${imageList.indexOf(pixel)} Y: ${pixel.Y} , X: ${pixel.X} ");

          pixel.X = pixel.X - roiLeft.toInt();
          pixel.Y = pixel.Y - roiTop.toInt();
          roiList.add(pixel);
        }
      }
      print(
          "Size of the image: ${roiWidth.toInt() + 1} on ${roiHeight.toInt() + 1}");

      /// Iterate roiList
      int someNum = 0;
      // for (Pixel pix in roiList) {
      //   //if (someNum % 1 == 0) {
      //   print(
      //       "X: ${pix.X}, y: ${pix.Y} - R: ${pix.R}, G ${pix.G}, B: ${pix.B}");
      //   //}
      //   someNum++;
      // }

      /// Find Blacks
      for (Pixel pixelSearch in roiList) {
        if (pixelSearch.R < 50) {
          print(
              "Color - X: ${pixelSearch.X}, Y: ${pixelSearch.Y}, R: ${pixelSearch.R} , G: ${pixelSearch.G} , B: ${pixelSearch.B}");
          //return;
        }
      }

      /// rebuild Image from ROI bytes
      List<int> allBytes = [];

      for (Pixel p in roiList) {
        allBytes.add(p.R);
        allBytes.add(p.G);
        allBytes.add(p.B);
      }

      theImageBytes = Uint8List.fromList(allBytes);

      /// find Magentas
      for (Pixel pixelSearch in roiList) {
        //if (pixelSearch.R > 150 && pixelSearch.G < 100 && pixelSearch.B > 150) {
        if ((pixelSearch.G - pixelSearch.R).abs() > 40) {
          print(
              "Pink - X: ${pixelSearch.X}, Y: ${pixelSearch.Y}, R: ${pixelSearch.R} , G: ${pixelSearch.G} , B: ${pixelSearch.B}");
          //return;
        }
      }

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
}

class Curr {
  String name;
  int value;

  Curr({required this.name, required this.value});
}
