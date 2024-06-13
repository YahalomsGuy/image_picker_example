import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_example/base/glob.dart';
import 'package:image_picker_example/widgets/open_painter.dart';

enum CursorWork { nothing, move, resizeTop, resizeBottom }

class RoiSizeWidget extends StatefulWidget {
  const RoiSizeWidget({super.key});

  @override
  State<RoiSizeWidget> createState() => _RoiSizeWidgetState();
}

class _RoiSizeWidgetState extends State<RoiSizeWidget> {
  double x = 0.0;
  double y = 0.0;
  double deltaX = 0.0;
  double deltaY = 0.0;
  int downX = 0;
  int downY = 0;
  late Size roiScreenSize;
  CursorWork job = CursorWork.nothing;
  @override
  Widget build(BuildContext context) {
    roiScreenSize = MediaQuery.of(context).size;
    print("WW: ${roiScreenSize.width}");
    print("HH: ${roiScreenSize.height}");
    print(roiLeft);
    print(roiTop);

    return SafeArea(
      child: Stack(
        children: [
          Container(
            width: roiScreenSize.width,
            height: roiScreenSize.width * 1.5,
            color: Colors.transparent,
            child: Listener(
              //onPointerSignal: ,
              onPointerMove: updateLocation,
              onPointerDown: moveResize,
              child: CustomPaint(
                painter: OpenPainter(
                  left: roiLeft,
                  top: roiTop,
                  width: roiWidth,
                  height: roiHeight,
                  screenSize: roiScreenSize,
                ),
              ),
            ),
          ),
          // Positioned(
          //   left: 40,
          //   top: 50,
          //   child: SizedBox(
          //     width: MediaQuery.of(context).size.width - 80,
          //     height: expOpen ? 250 : 80,
          //     child: ExpansionTile(
          //       backgroundColor: Colors.white.withOpacity(0.5),
          //       collapsedBackgroundColor: Colors.transparent,
          //       expansionAnimationStyle: AnimationStyle.noAnimation,
          //       iconColor: Colors.red,
          //       collapsedIconColor: Colors.white,
          //       onExpansionChanged: (open) {
          //         expOpen = open;
          //         setState(() {});
          //       },
          //       title: Text("Position and Size"),
          //       children: [
          //         Slider(
          //             min: -99999,
          //             max: 99999,
          //             value: roiTop.toDouble(),
          //             onChanged: (newTop) {
          //               roiTop = newTop;
          //               setState(() {});
          //             }),
          //         Slider(
          //             min: 0,
          //             max: (240 - roiWidth).toDouble(),
          //             value: roiLeft.toDouble(),
          //             onChanged: (newLeft) {
          //               roiLeft = newLeft;
          //               setState(() {});
          //             }),
          //         Slider(
          //             min: -99999,
          //             max: 9999,
          //             value: roiWidth.toDouble(),
          //             onChanged: (newWidth) {
          //               roiWidth = newWidth;
          //               setState(() {});
          //             }),
          //         Slider(
          //             min: 10,
          //             max: 100,
          //             value: roiHeight.toDouble(),
          //             onChanged: (newHeight) {
          //               roiHeight = newHeight;
          //               setState(() {});
          //             }),
          //       ],
          //     ),
          //   ),
          // ),
          Positioned(
            bottom: -60,
            left: 30,
            child: Column(
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        roiLeft = 140;
                        roiWidth = 200;
                        roiTop = 220;
                        roiHeight = 200;
                      });
                    },
                    icon: const Icon(Icons.recycling, color: Colors.white)),
                SizedBox(
                  width: 200,
                  height: 100,
                  child: Text(
                    "X: ${x.toInt()} , Y: ${y.toInt()}",
                    style: TextStyle(
                        color: chkRed && chkGreen ? Colors.black : Colors.white,
                        fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  updateLocation(PointerEvent details) {
    setState(() {
      x = details.position.dx;
      y = details.position.dy;
      deltaX = details.delta.dx;
      deltaY = details.delta.dy;
      switch (job) {
        case CursorWork.nothing:
          break;
        case CursorWork.move:
          roiLeft += deltaX;
          roiTop += deltaY;
          break;
        case CursorWork.resizeTop:
          roiLeft += deltaX;
          roiTop += deltaY;
          roiWidth -= deltaX;
          roiHeight -= deltaY;
          break;
        case CursorWork.resizeBottom:
          roiWidth += deltaX;
          roiHeight += deltaY;
          break;
      }
    });
  }

  moveResize(PointerEvent details) {
    x = details.position.dx;
    y = details.position.dy;
    int xPoint = x.toInt();
    int yPoint = y.toInt();
    downX = xPoint;
    downY = yPoint;
    if (kDebugMode) print("X: $x , Y: $y");
    if ((xPoint - roiLeft).abs() < tolerance &&
        ((yPoint - roiTop).abs()) < tolerance) {
      if (kDebugMode) print("Caught TopLeft Edge, Stretching top anchor!!!");
      job = CursorWork.resizeTop;
    } else if ((xPoint - (roiLeft + roiWidth)).abs() < tolerance &&
        ((yPoint - (roiTop + roiHeight)).abs()) < tolerance) {
      if (kDebugMode) {
        print("Caught BottomRight Edge, Stretching bottom anchor!!!");
      }
      job = CursorWork.resizeBottom;
    } else {
      if (kDebugMode) print("Did not Catch Edge, Moving !!!");
      job = CursorWork.move;
    }

    setState(() {
      if (kDebugMode) {
        print("Caught X: ${xPoint.toInt()}, Y: ${yPoint.toInt()}");
      }
    });
  }
}
